// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'dart:math';

import 'package:bcs_dart/bcs.dart';
import 'package:sui_dart/builder/commands.dart';
import 'package:sui_dart/builder/inputs.dart';
import 'package:sui_dart/builder/transaction.dart';
import 'package:sui_dart/builder/transaction_block_data.dart';
import 'package:sui_dart/core/sui_core_client.dart';
import 'package:sui_dart/grpc/types.dart' show CoinData;
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/types/objects.dart';

const COIN_WITH_BALANCE = 'CoinWithBalance';
final SUI_TYPE = normalizeStructTagString('0x2::sui::SUI');

/// A function added to a transaction with `tx.add(...)`. Invoked with the
/// transaction, it registers the resolver, appends the intent command, and
/// returns the resulting coin argument.
typedef CoinWithBalanceBuilder = TransactionResult Function(Transaction tx);

/// Returns a coin of [type] holding exactly [balance], selecting and merging the
/// sender's coins at build time. For SUI, the gas coin is used unless
/// [useGasCoin] is `false`. Requires a client and a sender on the transaction.
CoinWithBalanceBuilder coinWithBalance({
  required dynamic balance,
  String? type,
  bool useGasCoin = true,
}) {
  return _intent(
    balance: balance,
    type: type,
    useGasCoin: useGasCoin,
    outputKind: 'coin',
  );
}

/// Like [coinWithBalance] but yields a `Balance<T>` instead of a `Coin<T>`.
CoinWithBalanceBuilder createBalance({
  required dynamic balance,
  String? type,
  bool useGasCoin = true,
}) {
  return _intent(
    balance: balance,
    type: type,
    useGasCoin: useGasCoin,
    outputKind: 'balance',
  );
}

CoinWithBalanceBuilder _intent({
  required dynamic balance,
  required String? type,
  required bool useGasCoin,
  required String outputKind,
}) {
  TransactionResult? cached;
  return (Transaction tx) {
    if (cached != null) return cached!;

    tx.addIntentResolver(COIN_WITH_BALANCE, resolveCoinBalance);

    final rawType = type ?? SUI_TYPE;
    final coinType = rawType == 'gas'
        ? rawType
        : normalizeStructTagString(rawType);

    cached = tx.add(
      Commands.intent(
        name: COIN_WITH_BALANCE,
        data: {
          'type': coinType == SUI_TYPE && useGasCoin ? 'gas' : coinType,
          'balance': BigInt.parse(balance.toString()),
          'outputKind': outputKind,
        },
      ),
    );
    return cached!;
  };
}

typedef _IntentInfo = ({BigInt balance, String outputKind});

/// Resolves all [COIN_WITH_BALANCE] intents in [transactionData] into concrete
/// merge/split commands.
///
/// This selects and merges the sender's owned coins (or the gas coin for SUI)
/// and splits the exact requested amounts. It does not use the address-balance
/// withdrawal path (`coin::redeem_funds` / `coin::send_funds`); any surplus
/// stays as an owned coin with the sender. Coins are merged rather than left as
/// dust.
Future<void> resolveCoinBalance(
  TransactionBlockDataBuilder transactionData,
  BuildOptions options,
  Future<void> Function() next,
) async {
  final sender = transactionData.sender;
  if (sender == null) {
    throw ArgumentError('Sender must be set to resolve CoinWithBalance');
  }

  final totalByType = <String, BigInt>{};
  final intentsByType = <String, List<_IntentInfo>>{};

  bool isCoinWithBalance(dynamic command) =>
      command['\$kind'] == '\$Intent' &&
      command['\$Intent']['name'] == COIN_WITH_BALANCE;

  ({String type, BigInt balance, String outputKind}) parse(dynamic data) => (
    type: data['type'] as String,
    balance: BigInt.parse(data['balance'].toString()),
    outputKind: (data['outputKind'] as String?) ?? 'coin',
  );

  // First pass: collect per-type totals; resolve zero-balance intents in place.
  for (var i = 0; i < transactionData.commands.length; i++) {
    final command = transactionData.commands[i];
    if (!isCoinWithBalance(command)) continue;

    final intent = parse(command['\$Intent']['data']);

    if (intent.balance == BigInt.zero) {
      final coinType = intent.type == 'gas' ? SUI_TYPE : intent.type;
      transactionData.replaceCommand(
        i,
        Commands.moveCall({
          'target': intent.outputKind == 'balance'
              ? '0x2::balance::zero'
              : '0x2::coin::zero',
          'typeArguments': [coinType],
        }),
      );
      continue;
    }

    totalByType[intent.type] =
        (totalByType[intent.type] ?? BigInt.zero) + intent.balance;
    (intentsByType[intent.type] ??= []).add((
      balance: intent.balance,
      outputKind: intent.outputKind,
    ));
  }

  if (totalByType.isEmpty) return next();

  if (totalByType.containsKey('gas') && totalByType.containsKey(SUI_TYPE)) {
    throw ArgumentError(
      'Cannot mix SUI CoinWithBalance intents that use the gas coin with ones '
      'that do not (useGasCoin: false). Use one or the other.',
    );
  }

  final client = expectClient(options);

  final usedIds = <String>{};
  for (final input in transactionData.inputs) {
    final objectId =
        input['Object']?['ImmOrOwnedObject']?['objectId'] ??
        input['UnresolvedObject']?['objectId'];
    if (objectId != null) usedIds.add(normalizeSuiAddress(objectId));
  }

  // Load coins for every non-gas type up front.
  final coinsByType = <String, List<CoinData>>{};
  for (final entry in totalByType.entries) {
    if (entry.key == 'gas') continue;
    coinsByType[entry.key] = await _loadCoins(
      client,
      sender,
      entry.key,
      entry.value,
      usedIds,
    );
  }

  // Per-type split results, computed when the first intent of a type is seen.
  final typeResults = <String, List<dynamic>>{};
  final typeNextIntent = <String, int>{};
  final mergedCoins = <String, dynamic>{};
  final exactBalanceByType = <String, bool>{};

  var index = 0;
  while (index < transactionData.commands.length) {
    final command = transactionData.commands[index];
    if (!isCoinWithBalance(command)) {
      index++;
      continue;
    }

    final intent = parse(command['\$Intent']['data']);
    final type = intent.type;
    final coinType = type == 'gas' ? SUI_TYPE : type;
    final commands = <dynamic>[];

    if (!typeResults.containsKey(type)) {
      final intents = intentsByType[type]!;
      final sources = <dynamic>[];

      if (type == 'gas') {
        sources.add({'\$kind': 'GasCoin', 'GasCoin': true});
      } else {
        final coins = coinsByType[type]!;
        final loaded = coins.fold(
          BigInt.zero,
          (sum, c) => sum + BigInt.parse(c.balance),
        );
        exactBalanceByType[type] = loaded == totalByType[type];
        for (final coin in coins) {
          sources.add(
            transactionData.addInput(
              'object',
              Inputs.objectRef(
                SuiObjectRef(coin.digest, coin.objectId, coin.version),
              ),
            ),
          );
        }
      }

      final baseCoin = sources.first;
      final rest = sources.sublist(1);
      for (var i = 0; i < rest.length; i += 500) {
        commands.add(
          Commands.mergeCoins(
            baseCoin,
            rest.sublist(i, min(i + 500, rest.length)),
          ),
        );
      }
      mergedCoins[type] = baseCoin;

      final splitCmdIndex = index + commands.length;
      commands.add(
        Commands.splitCoins(
          baseCoin,
          intents
              .map(
                (i) => transactionData.addInput(
                  'pure',
                  Inputs.pure(Bcs.u64().serialize(i.balance)),
                ),
              )
              .toList(),
        ),
      );

      final results = <dynamic>[];
      for (var i = 0; i < intents.length; i++) {
        final splitResult = {
          '\$kind': 'NestedResult',
          'NestedResult': [splitCmdIndex, i],
        };
        if (intents[i].outputKind == 'balance') {
          commands.add(
            Commands.moveCall({
              'target': '0x2::coin::into_balance',
              'typeArguments': [coinType],
              'arguments': [splitResult],
            }),
          );
          results.add({
            '\$kind': 'NestedResult',
            'NestedResult': [index + commands.length - 1, 0],
          });
        } else {
          results.add(splitResult);
        }
      }
      typeResults[type] = results;
      typeNextIntent[type] = 0;
    }

    final intentResult = typeResults[type]![typeNextIntent[type]!];
    typeNextIntent[type] = typeNextIntent[type]! + 1;

    transactionData.replaceCommand(index, commands, intentResult);
    index += commands.length;
  }

  // Remainder: a merged non-gas coin that exactly matched is now zero — destroy
  // it. Surplus coins (and the gas coin) are left owned by the sender.
  for (final entry in mergedCoins.entries) {
    if (entry.key == 'gas') continue;
    if (exactBalanceByType[entry.key] == true) {
      final coinType = entry.key;
      transactionData.commands.add(
        Commands.moveCall({
          'target': '0x2::coin::destroy_zero',
          'typeArguments': [coinType],
          'arguments': [entry.value],
        }),
      );
    }
  }

  return next();
}

Future<List<CoinData>> _loadCoins(
  SuiCoreClient client,
  String owner,
  String coinType,
  BigInt needed,
  Set<String> usedIds,
) async {
  final coins = <CoinData>[];
  var loaded = BigInt.zero;
  String? cursor;

  while (true) {
    final page = await client.getCoins(
      owner,
      coinType: coinType,
      cursor: cursor,
    );
    for (final coin in page.data) {
      if (usedIds.contains(normalizeSuiAddress(coin.objectId))) continue;
      coins.add(coin);
      loaded += BigInt.parse(coin.balance);
    }
    if (loaded >= needed || !page.hasNextPage) break;
    cursor = page.nextCursor;
  }

  if (loaded < needed) {
    throw ArgumentError(
      'Insufficient balance of $coinType for $owner. '
      'Required: $needed, available: $loaded',
    );
  }
  return coins;
}
