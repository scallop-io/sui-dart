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
import 'package:sui_dart/bcs/sui_bcs.dart';

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
/// A shortfall in owned coins is redeemed from the sender's address balance and
/// the remainder returns there; a coin-only surplus stays as an owned coin.
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

  final coinsByType = <String, List<CoinData>>{};
  final addressBalanceByType = <String, BigInt>{};
  for (final entry in totalByType.entries) {
    final isGas = entry.key == 'gas';
    final source = await _loadSources(
      client,
      sender,
      isGas ? SUI_TYPE : entry.key,
      entry.value,
      usedIds,
      withCoins: !isGas,
    );
    addressBalanceByType[entry.key] = source.addressBalance;
    if (!isGas) coinsByType[entry.key] = source.coins;
  }

  // Per-type split results, computed when the first intent of a type is seen.
  final typeResults = <String, List<dynamic>>{};
  final typeNextIntent = <String, int>{};
  final exactBalanceByType = <String, bool>{};
  final usedAddressBalance = <String>{};

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

      final totalRequired = totalByType[type]!;
      final addressBalance = addressBalanceByType[type] ?? BigInt.zero;

      if (addressBalance >= totalRequired) {
        // covers it alone, so no coin object (or the gas coin) is touched.
        usedAddressBalance.add(type);
        commands.add(_redeemFunds(transactionData, coinType, totalRequired));
        sources.add(<String, dynamic>{
          '\$kind': 'Result',
          'Result': index + commands.length - 1,
        });
      } else if (type == 'gas') {
        sources.add(<String, dynamic>{'\$kind': 'GasCoin', 'GasCoin': true});
      } else {
        final coins = coinsByType[type]!;
        final loaded = coins.fold(
          BigInt.zero,
          (sum, c) => sum + BigInt.parse(c.balance),
        );
        final shortfall = totalRequired > loaded
            ? totalRequired - loaded
            : BigInt.zero;
        exactBalanceByType[type] = loaded + shortfall == totalRequired;
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
        if (shortfall > BigInt.zero) {
          usedAddressBalance.add(type);
          commands.add(_redeemFunds(transactionData, coinType, shortfall));
          sources.add(<String, dynamic>{
            '\$kind': 'Result',
            'Result': index + commands.length - 1,
          });
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
        final splitResult = <String, dynamic>{
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
          results.add(<String, dynamic>{
            '\$kind': 'NestedResult',
            'NestedResult': [index + commands.length - 1, 0],
          });
        } else {
          results.add(splitResult);
        }
      }
      // Cleanup goes here, not appended: nothing may follow a Random MoveCall.
      if (usedAddressBalance.contains(type)) {
        // a redeemed coin can't dangle; send_funds also takes a zero remainder.
        commands.add(
          Commands.moveCall({
            'target': '0x2::coin::send_funds',
            'typeArguments': [coinType],
            'arguments': [
              baseCoin,
              transactionData.addInput(
                'pure',
                Inputs.pure(SuiBcs.Address.serialize(sender)),
              ),
            ],
          }),
        );
      } else if (type != 'gas' && exactBalanceByType[type] == true) {
        commands.add(
          Commands.moveCall({
            'target': '0x2::coin::destroy_zero',
            'typeArguments': [coinType],
            'arguments': [baseCoin],
          }),
        );
      }

      typeResults[type] = results;
      typeNextIntent[type] = 0;
    }

    final intentResult = typeResults[type]![typeNextIntent[type]!];
    typeNextIntent[type] = typeNextIntent[type]! + 1;

    transactionData.replaceCommand(index, commands, intentResult);
    index += commands.length;
  }

  return next();
}

Map<String, dynamic> _redeemFunds(
  TransactionBlockDataBuilder transactionData,
  String coinType,
  BigInt amount,
) {
  return Commands.moveCall({
    'target': '0x2::coin::redeem_funds',
    'typeArguments': [coinType],
    'arguments': [
      transactionData.addInput(
        'withdrawal',
        Inputs.fundsWithdrawal(maxAmount: amount, coinType: coinType),
      ),
    ],
  });
}

Future<({List<CoinData> coins, BigInt addressBalance})> _loadSources(
  SuiCoreClient client,
  String owner,
  String coinType,
  BigInt needed,
  Set<String> usedIds, {
  bool withCoins = true,
}) async {
  final balance = await client.getBalance(owner, coinType: coinType);
  final addressBalance = BigInt.tryParse(balance.addressBalance) ?? BigInt.zero;

  // the gas coin isn't in a balance query and covers any shortfall itself.
  if (!withCoins) return (coins: <CoinData>[], addressBalance: addressBalance);

  final total = BigInt.tryParse(balance.balance) ?? BigInt.zero;
  if (total < needed) {
    throw ArgumentError(
      'Insufficient balance of $coinType for $owner. '
      'Required: $needed, available: $total',
    );
  }
  if (addressBalance >= needed) {
    return (coins: <CoinData>[], addressBalance: addressBalance);
  }

  final fromCoins = needed - addressBalance;
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
    if (loaded >= fromCoins || !page.hasNextPage) break;
    cursor = page.nextCursor;
  }

  if (loaded + addressBalance < needed) {
    throw ArgumentError(
      'Insufficient balance of $coinType for $owner. '
      'Required: $needed, available: ${loaded + addressBalance}',
    );
  }
  return (coins: coins, addressBalance: addressBalance);
}
