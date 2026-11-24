import 'dart:convert';
import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:sui_dart/grpc/types.dart';
import 'package:sui_dart/sui.dart' hide AddressOwner, ObjectData;
import 'package:test/test.dart';

const _owner =
    '0x000000000000000000000000000000000000000000000000000000000000aaaa';
const _recipient =
    '0x000000000000000000000000000000000000000000000000000000000000bbbb';
const _fooType =
    '0x00000000000000000000000000000000000000000000000000000000000000ab::foo::FOO';

CoinData _coin(String id, String balance, [String type = _fooType]) {
  return CoinData(
    objectId: id,
    version: '1',
    digest: 'Bfm2Z4dXysM9Vu1X5p8oR4z7mFs2pT8w9X1y2Z3a4B5c',
    owner: const AddressOwner(_owner),
    type: type,
    balance: balance,
  );
}

/// Returns coins from a fixed pool; no network.
class _FakeClient implements SuiCoreClient {
  @override
  TransactionPlugin resolveTransactionPlugin() => simulationResolvePlugin(this);

  final List<CoinData> pool;
  final BigInt addressBalance;
  _FakeClient(this.pool, {BigInt? addressBalance})
    : addressBalance = addressBalance ?? BigInt.zero;

  @override
  Future<Balance> getBalance(
    String address, {
    String coinType = '0x2::sui::SUI',
  }) async {
    final normalized = normalizeStructTagString(coinType);
    final coinBalance = pool
        .where((c) => normalizeStructTagString(c.type) == normalized)
        .fold(BigInt.zero, (sum, c) => sum + BigInt.parse(c.balance));
    return Balance(
      coinType: coinType,
      balance: (coinBalance + addressBalance).toString(),
      coinBalance: coinBalance.toString(),
      addressBalance: addressBalance.toString(),
    );
  }

  @override
  Future<Page<CoinData>> getCoins(
    String address, {
    String coinType = '0x2::sui::SUI',
    String? cursor,
    int? limit,
  }) async {
    final normalized = normalizeStructTagString(coinType);
    final data = pool
        .where((c) => normalizeStructTagString(c.type) == normalized)
        .toList();
    return Page(data: data, hasNextPage: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '${invocation.memberName} is not needed by this fixture',
  );
}

Future<List<dynamic>> _resolve(
  Transaction tx,
  List<CoinData> pool, {
  BigInt? addressBalance,
}) async {
  tx.setSender(_owner);
  await tx.build(
    BuildOptions(
      client: _FakeClient(pool, addressBalance: addressBalance),
      onlyTransactionKind: true,
    ),
  );
  return tx.getData().commands!;
}

bool _hasIntent(List<dynamic> commands) =>
    commands.any((c) => c['\$kind'] == '\$Intent');

void main() {
  group('coinWithBalance resolver', () {
    test('merges and splits owned coins for a custom type', () async {
      final tx = Transaction();
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 100));
      tx.transferObjects([coin], _recipient);

      final commands = await _resolve(tx, [
        _coin('0x1', '60'),
        _coin('0x2', '60'),
      ]);

      expect(_hasIntent(commands), isFalse);
      final kinds = commands.map((c) => c['\$kind']).toList();
      expect(kinds, ['MergeCoins', 'SplitCoins', 'TransferObjects']);
      // Transfer references the split output (NestedResult of the split command).
      expect(commands[2]['TransferObjects']['objects'][0]['NestedResult'], [
        1,
        0,
      ]);
    });

    test('combines multiple intents of the same type into one split', () async {
      final tx = Transaction();
      final a = tx.add(coinWithBalance(type: _fooType, balance: 30));
      final b = tx.add(coinWithBalance(type: _fooType, balance: 70));
      tx.transferObjects([a, b], _recipient);

      final commands = await _resolve(tx, [_coin('0x1', '500')]);

      expect(_hasIntent(commands), isFalse);
      final splits = commands
          .where((c) => c['\$kind'] == 'SplitCoins')
          .toList();
      expect(splits.length, 1);
      expect(splits[0]['SplitCoins']['amounts'].length, 2);
    });

    test(
      'zero balance resolves to coin::zero without querying coins',
      () async {
        final tx = Transaction();
        final coin = tx.add(coinWithBalance(type: _fooType, balance: 0));
        tx.transferObjects([coin], _recipient);

        final commands = await _resolve(tx, []);

        expect(_hasIntent(commands), isFalse);
        final move = commands.firstWhere((c) => c['\$kind'] == 'MoveCall');
        expect(move['MoveCall']['module'], 'coin');
        expect(move['MoveCall']['function'], 'zero');
      },
    );

    test('createBalance wraps the split in coin::into_balance', () async {
      final tx = Transaction();
      tx.add(createBalance(type: _fooType, balance: 50));

      final commands = await _resolve(tx, [_coin('0x1', '100')]);

      expect(_hasIntent(commands), isFalse);
      final intoBalance = commands.firstWhere(
        (c) =>
            c['\$kind'] == 'MoveCall' &&
            c['MoveCall']['function'] == 'into_balance',
      );
      expect(intoBalance['MoveCall']['module'], 'coin');
    });

    test('destroys the dust coin when the balance matches exactly', () async {
      final tx = Transaction();
      tx.add(coinWithBalance(type: _fooType, balance: 100));

      final commands = await _resolve(tx, [_coin('0x1', '100')]);

      expect(
        commands.any(
          (c) =>
              c['\$kind'] == 'MoveCall' &&
              c['MoveCall']['function'] == 'destroy_zero',
        ),
        isTrue,
      );
    });

    test('destroys the dust coin before later commands', () async {
      final tx = Transaction();
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 100));
      tx.transferObjects([coin], _recipient);

      final commands = await _resolve(tx, [_coin('0x1', '100')]);

      // Nothing may follow a Random MoveCall, so cleanup must not trail.
      final destroyIndex = commands.indexWhere(
        (c) =>
            c['\$kind'] == 'MoveCall' &&
            c['MoveCall']['function'] == 'destroy_zero',
      );
      final transferIndex = commands.indexWhere(
        (c) => c['\$kind'] == 'TransferObjects',
      );
      expect(destroyIndex, greaterThanOrEqualTo(0));
      expect(destroyIndex, lessThan(transferIndex));
    });

    test('uses the gas coin for SUI', () async {
      final tx = Transaction();
      final coin = tx.add(coinWithBalance(balance: 100));
      tx.transferObjects([coin], _recipient);

      // No coins in the pool: SUI must source from the gas coin, not a query.
      final commands = await _resolve(tx, []);

      expect(_hasIntent(commands), isFalse);
      final split = commands.firstWhere((c) => c['\$kind'] == 'SplitCoins');
      expect(split['SplitCoins']['coin']['\$kind'], 'GasCoin');
    });

    test(
      'withdraws from the address balance when it covers the amount',
      () async {
        final tx = Transaction();
        final coin = tx.add(coinWithBalance(type: _fooType, balance: 20000000));
        tx.transferObjects([coin], _recipient);

        final commands = await _resolve(tx, [
          _coin('0x1', '636508'),
        ], addressBalance: BigInt.from(30000000));

        expect(_hasIntent(commands), isFalse);
        final targets = commands
            .where((c) => c['\$kind'] == 'MoveCall')
            .map((c) => c['MoveCall']['function'])
            .toList();
        expect(targets, contains('redeem_funds'));
        expect(targets, contains('send_funds'));
        expect(commands.any((c) => c['\$kind'] == 'MergeCoins'), isFalse);
      },
    );

    test('tops up a coin shortfall from the address balance', () async {
      final tx = Transaction();
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 150));
      tx.transferObjects([coin], _recipient);

      final commands = await _resolve(tx, [
        _coin('0x1', '100'),
      ], addressBalance: BigInt.from(80));

      final kinds = commands.map((c) => c['\$kind']).toList();
      // Redeem the missing 50, merge it into the coin, split, return the rest.
      expect(kinds, [
        'MoveCall',
        'MergeCoins',
        'SplitCoins',
        'MoveCall',
        'TransferObjects',
      ]);
      expect(commands[0]['MoveCall']['function'], 'redeem_funds');
      expect(commands[3]['MoveCall']['function'], 'send_funds');
    });

    test(
      'throws when coins and the address balance together fall short',
      () async {
        final tx = Transaction();
        tx.add(coinWithBalance(type: _fooType, balance: 1000));

        expect(
          () => _resolve(tx, [
            _coin('0x1', '120'),
          ], addressBalance: BigInt.from(80)),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('throws when the balance is insufficient', () async {
      final tx = Transaction();
      tx.add(coinWithBalance(type: _fooType, balance: 1000));

      expect(
        () => _resolve(tx, [_coin('0x1', '120')]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('later arguments after an intent expands', () {
    final pool = [_coin('0x1', '60'), _coin('0x2', '60')];

    test('a result used twice is shifted once', () async {
      final tx = Transaction();
      tx.add(coinWithBalance(type: _fooType, balance: 100));
      final split = tx.splitCoins(tx.gas, [1, 2]);
      final a = split[0];
      tx.mergeCoins(a, [split[1]]);
      tx.transferObjects([a], _recipient);

      final commands = await _resolve(tx, pool);
      final splitAt = commands.lastIndexWhere(
        (c) => c['\$kind'] == 'SplitCoins',
      );
      final merge = commands.lastWhere((c) => c['\$kind'] == 'MergeCoins');
      final transfer = commands.last['TransferObjects'];
      expect(merge['MergeCoins']['destination']['NestedResult'], [splitAt, 0]);
      expect(merge['MergeCoins']['sources'][0]['NestedResult'], [splitAt, 1]);
      expect(transfer['objects'][0]['NestedResult'], [splitAt, 0]);
    });

    test('a whole result passed on is shifted, not crashed on', () async {
      final tx = Transaction();
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 100));
      final value = tx.moveCall(
        '0x2::coin::value',
        typeArguments: [_fooType],
        arguments: [coin],
      );
      tx.moveCall('0x2::foo::bar', arguments: [value]);
      tx.splitCoins(value, [1]);

      final commands = await _resolve(tx, pool);
      final valueAt = commands.indexWhere(
        (c) => c['MoveCall']?['function'] == 'value',
      );
      final bar = commands.firstWhere(
        (c) => c['MoveCall']?['function'] == 'bar',
      );
      expect(bar['MoveCall']['arguments'][0]['Result'], valueAt);
      expect(commands.last['SplitCoins']['coin']['Result'], valueAt);
    });

    test('resolving a copy leaves the original alone', () async {
      final original = Transaction();
      final coin = original.add(coinWithBalance(type: _fooType, balance: 100));
      original.transferObjects([coin], _recipient);
      final before = original.getData().commands!.length;

      final copy = Transaction(original);
      copy.addIntentResolver(COIN_WITH_BALANCE, resolveCoinBalance);
      await _resolve(copy, pool);
      copy.moveCall('0x2::foo::bar');

      expect(original.getData().commands, hasLength(before));
      expect(_hasIntent(original.getData().commands!), isTrue);
    });
  });

  group('arguments and restored transactions', () {
    Future<List<int>> kind(Transaction tx) {
      tx.setSender(_owner);
      return tx.build(
        BuildOptions(
          onlyTransactionKind: true,
          assumeSufficientAddressBalances: true,
        ),
      );
    }

    test('moveCall and splitCoins take serialized values', () async {
      final tx = Transaction();
      tx.moveCall('0x2::m::f', arguments: [Bcs.u64().serialize(5)]);
      expect(
        base64Encode(await kind(tx)),
        'AAEACAUAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgFtAWYAAQEAAA==',
      );

      final split = Transaction();
      final amount = split.moveCall('0x2::m::amt');
      split.splitCoins(split.gas, [Bcs.u64().serialize(7), amount, 3]);
      final amounts = split.getData().commands!.last['SplitCoins']['amounts'];
      expect(amounts.map((a) => a[r'$kind']), ['Input', 'Result', 'Input']);
    });

    test('a thunk argument runs on the transaction', () async {
      final tx = Transaction();
      tx.moveCall(
        '0x2::m::f',
        typeArguments: [_fooType],
        arguments: [coinWithBalance(type: _fooType, balance: 5)],
      );
      final commands = tx.getData().commands!;
      expect(commands.first[r'$kind'], r'$Intent');
      expect(commands.last['MoveCall']['arguments'].single, {
        r'$kind': 'Result',
        'Result': 0,
      });
    });

    test('JSON without \$kind keeps intents and argument links', () async {
      final direct = Transaction();
      final coin = direct.add(coinWithBalance(type: _fooType, balance: 100));
      final opened = direct.moveCall('0x2::m::open', arguments: [coin]);
      direct.moveCall('0x2::m::a', arguments: [opened[0]]);
      direct.setSender(_owner);

      dynamic strip(dynamic v) => v is Map
          ? {
              for (final e in v.entries)
                if (e.key != r'$kind') e.key: strip(e.value),
            }
          : v is List
          ? v.map(strip).toList()
          : v;
      final json = jsonEncode(strip(jsonDecode(direct.toJson())));
      expect(json, isNot(contains(r'$kind')));

      final restored = Transaction.from(json);
      expect(await kind(restored), await kind(direct));
    });

    test('an Input argument with a type and no \$kind is tagged', () {
      final restored = Transaction.from(
        jsonEncode({
          'version': 2,
          'sender': _owner,
          'expiration': null,
          'gasData': <String, dynamic>{},
          'inputs': [
            {
              'Pure': {'bytes': 'CQAAAAAAAAA='},
            },
          ],
          'commands': [
            {
              'MoveCall': {
                'package': '0x2',
                'module': 'm',
                'function': 'f',
                'typeArguments': [],
                'arguments': [
                  {'Input': 0, 'type': 'pure'},
                ],
              },
            },
          ],
        }),
      );
      final data = restored.getData();
      expect(data.inputs!.single[r'$kind'], 'Pure');
      expect(data.commands!.single[r'$kind'], 'MoveCall');
      expect(
        data.commands!.single['MoveCall']['arguments'].single[r'$kind'],
        'Input',
      );
    });

    test('raw bytes become a pure argument', () {
      final tx = Transaction();
      tx.moveCall(
        '0x2::m::f',
        arguments: [
          Uint8List.fromList([9, 0, 0, 0, 0, 0, 0, 0]),
        ],
      );
      expect(tx.getData().inputs!.single[r'$kind'], 'Pure');
    });

    test('a copy keeps the intent resolver', () async {
      final tx = Transaction();
      tx.add(coinWithBalance(type: _fooType, balance: 100));
      await kind(Transaction(tx));
    });

    test('v1 JSON restores to plain lists and maps', () {
      final tx = Transaction();
      final split = tx.splitCoins(tx.gas, [1]);
      tx.transferObjects([split], _recipient);
      tx.setSender(_owner);
      // ignore: deprecated_member_use_from_same_package
      final restored = Transaction.from(tx.serialize());
      expect(jsonDecode(restored.toJson())['commands'], hasLength(2));
      restored.toGrpcTransaction();
    });
  });

  group('existing withdrawals', () {
    test(
      'an intent does not spend funds another withdrawal reserved',
      () async {
        final tx = Transaction();
        tx.object(
          Inputs.fundsWithdrawal(
            maxAmount: BigInt.from(900),
            coinType: _fooType,
          ),
        );
        final coin = tx.add(coinWithBalance(type: _fooType, balance: 200));
        tx.transferObjects([coin], _recipient);

        await _resolve(tx, [
          _coin('0x1', '500'),
        ], addressBalance: BigInt.from(1000));
        expect(
          jsonEncode(tx.getData().inputs),
          contains(normalizeSuiAddress('0x1')),
          reason: 'the coin object must be used',
        );
      },
    );

    test('throw when they exceed the address balance', () async {
      final tx = Transaction();
      tx.object(
        Inputs.fundsWithdrawal(
          maxAmount: BigInt.from(1500),
          coinType: _fooType,
        ),
      );
      tx.add(coinWithBalance(type: _fooType, balance: 1));
      await expectLater(
        _resolve(tx, [_coin('0x1', '500')], addressBalance: BigInt.from(1000)),
        throwsArgumentError,
      );
    });
  });

  group('remainder handling', () {
    List<String> calls(List<dynamic> commands) => commands
        .where((c) => c['\$kind'] == 'MoveCall')
        .map((c) => '${c['MoveCall']['module']}::${c['MoveCall']['function']}')
        .toList();

    Map<String, dynamic> call(List<dynamic> commands, String function) =>
        commands.firstWhere(
          (c) =>
              c['\$kind'] == 'MoveCall' &&
              c['MoveCall']['function'] == function,
        )['MoveCall'];

    void sendBalance(Transaction tx, dynamic balance, [String? type]) {
      tx.moveCall(
        '0x2::balance::send_funds',
        typeArguments: [type ?? _fooType],
        arguments: [tx.object(balance), tx.pure.address(_recipient)],
      );
    }

    test('a balance intent sends the change to the sender', () async {
      final tx = Transaction();
      sendBalance(tx, tx.add(createBalance(type: _fooType, balance: 60)));

      final commands = await _resolve(tx, [_coin('0x1', '100')]);

      expect(commands.map((c) => c['\$kind']), [
        'SplitCoins',
        'MoveCall',
        'MoveCall',
        'MoveCall',
      ]);
      expect(calls(commands), [
        'coin::into_balance',
        'coin::send_funds',
        'balance::send_funds',
      ]);
      // the split coin is the one swept, so none survives
      final swept = call(commands, 'send_funds')['arguments'];
      expect(swept[0], commands[0]['SplitCoins']['coin']);
      expect(
        tx.getData().inputs![swept[1]['Input']]['Pure'],
        Inputs.pure(SuiBcs.Address.serialize(_owner))['Pure'],
      );
      expect(commands[3]['MoveCall']['arguments'][0]['NestedResult'], [1, 0]);
    });

    test('an exact balance intent does not call destroy_zero', () async {
      final tx = Transaction();
      sendBalance(tx, tx.add(createBalance(type: _fooType, balance: 100)));

      final commands = await _resolve(tx, [_coin('0x1', '100')]);

      expect(calls(commands), [
        'coin::into_balance',
        'coin::send_funds',
        'balance::send_funds',
      ]);
    });

    test('a balance intent merges several coins and sweeps the base', () async {
      final tx = Transaction();
      sendBalance(tx, tx.add(createBalance(type: _fooType, balance: 150)));

      final commands = await _resolve(tx, [
        _coin('0x1', '60'),
        _coin('0x2', '60'),
        _coin('0x3', '60'),
      ]);

      expect(commands.map((c) => c['\$kind']), [
        'MergeCoins',
        'SplitCoins',
        'MoveCall',
        'MoveCall',
        'MoveCall',
      ]);
      final merge = commands[0]['MergeCoins'];
      expect(merge['sources'].length, 2);
      expect(commands[1]['SplitCoins']['coin'], merge['destination']);
      expect(
        call(commands, 'send_funds')['arguments'][0],
        merge['destination'],
      );
      expect(calls(commands), isNot(contains('coin::destroy_zero')));
    });

    test('a balance intent funded by coins and the address balance', () async {
      final tx = Transaction();
      sendBalance(tx, tx.add(createBalance(type: _fooType, balance: 150)));

      final commands = await _resolve(tx, [
        _coin('0x1', '100'),
      ], addressBalance: BigInt.from(80));

      expect(commands.map((c) => c['\$kind']), [
        'MoveCall',
        'MergeCoins',
        'SplitCoins',
        'MoveCall',
        'MoveCall',
        'MoveCall',
      ]);
      expect(calls(commands), [
        'coin::redeem_funds',
        'coin::into_balance',
        'coin::send_funds',
        'balance::send_funds',
      ]);
      expect(commands[5]['MoveCall']['arguments'][0]['NestedResult'], [3, 0]);
    });

    test('a SUI balance intent leaves the gas coin remainder alone', () async {
      final tx = Transaction();
      sendBalance(tx, tx.add(createBalance(balance: 100)), '0x2::sui::SUI');

      final commands = await _resolve(tx, []);

      expect(commands[0]['SplitCoins']['coin']['\$kind'], 'GasCoin');
      expect(calls(commands), ['coin::into_balance', 'balance::send_funds']);
    });

    test('a SUI balance intent from the address balance cleans up', () async {
      final tx = Transaction();
      sendBalance(tx, tx.add(createBalance(balance: 100)), '0x2::sui::SUI');

      final commands = await _resolve(tx, [], addressBalance: BigInt.from(500));

      expect(calls(commands), ['balance::redeem_funds', 'balance::send_funds']);
    });

    test(
      'balance intents covered by the address balance withdraw directly',
      () async {
        final tx = Transaction();
        sendBalance(tx, tx.add(createBalance(type: _fooType, balance: 60)));
        sendBalance(tx, tx.add(createBalance(type: _fooType, balance: 40)));

        final commands = await _resolve(tx, [
          _coin('0x1', '1000'),
        ], addressBalance: BigInt.from(100));

        expect(calls(commands), [
          'balance::redeem_funds',
          'balance::send_funds',
          'balance::redeem_funds',
          'balance::send_funds',
        ]);
        final inputs = tx.getData().inputs!;
        expect(inputs.where((i) => i['Object'] != null), isEmpty);
        expect(
          inputs
              .where((i) => i['FundsWithdrawal'] != null)
              .map((i) => i['FundsWithdrawal']['reservation']['MaxAmountU64']),
          ['60', '40'],
        );
        expect(commands[1]['MoveCall']['arguments'].first['NestedResult'], [
          0,
          0,
        ]);
        expect(commands[3]['MoveCall']['arguments'].first['NestedResult'], [
          2,
          0,
        ]);
      },
    );

    test(
      'a coin intent beside a balance intent still merges and splits',
      () async {
        final tx = Transaction();
        sendBalance(tx, tx.add(createBalance(type: _fooType, balance: 60)));
        tx.transferObjects([
          tx.add(coinWithBalance(type: _fooType, balance: 40)),
        ], _recipient);

        final commands = await _resolve(
          tx,
          [],
          addressBalance: BigInt.from(100),
        );

        expect(calls(commands), [
          'coin::redeem_funds',
          'coin::into_balance',
          'coin::send_funds',
          'balance::send_funds',
        ]);
      },
    );

    test('a coin intent keeps its surplus in the coin', () async {
      final tx = Transaction();
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 60));
      tx.transferObjects([coin], _recipient);

      final commands = await _resolve(tx, [_coin('0x1', '100')]);

      expect(commands.map((c) => c['\$kind']), [
        'SplitCoins',
        'TransferObjects',
      ]);
    });

    test('an exact coin intent still destroys the empty coin', () async {
      final tx = Transaction();
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 100));
      tx.transferObjects([coin], _recipient);

      final commands = await _resolve(tx, [_coin('0x1', '100')]);

      expect(calls(commands), ['coin::destroy_zero']);
    });

    test('coin and balance intents of one type keep their results', () async {
      final tx = Transaction();
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 30));
      final balance = tx.add(createBalance(type: _fooType, balance: 70));
      tx.transferObjects([coin], _recipient);
      sendBalance(tx, balance);

      final commands = await _resolve(tx, [_coin('0x1', '500')]);

      expect(commands.map((c) => c['\$kind']), [
        'SplitCoins',
        'MoveCall',
        'MoveCall',
        'TransferObjects',
        'MoveCall',
      ]);
      expect(calls(commands), [
        'coin::into_balance',
        'coin::send_funds',
        'balance::send_funds',
      ]);
      expect(commands[1]['MoveCall']['arguments'][0]['NestedResult'], [0, 1]);
      expect(commands[3]['TransferObjects']['objects'][0]['NestedResult'], [
        0,
        0,
      ]);
      expect(commands[4]['MoveCall']['arguments'][0]['NestedResult'], [1, 0]);
    });
  });

  group('async serialization', () {
    test('isPreparedForSerialization reflects unresolved intents', () {
      final tx = Transaction();
      tx.add(coinWithBalance(type: _fooType, balance: 100));

      expect(tx.isPreparedForSerialization(), isFalse);
      expect(
        tx.isPreparedForSerialization(supportedIntents: ['CoinWithBalance']),
        isTrue,
      );
    });

    test('toJsonAsync resolves intents and round-trips', () async {
      final tx = Transaction();
      tx.setSender(_owner);
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 100));
      tx.transferObjects([coin], _recipient);

      final json = await tx.toJsonAsync(
        SerializeTransactionOptions(client: _FakeClient([_coin('0x1', '500')])),
      );

      expect(json.contains('\$Intent'), isFalse);
      expect(json.contains('SplitCoins'), isTrue);
      // The JSON is valid and rebuildable.
      final restored = Transaction.from(json);
      expect(restored.isPreparedForSerialization(), isTrue);
    });

    test('supportedIntents leaves the intent for the recipient', () async {
      final tx = Transaction();
      tx.add(coinWithBalance(type: _fooType, balance: 100));

      // No client needed: the intent is not resolved.
      final json = await tx.toJsonAsync(
        SerializeTransactionOptions(supportedIntents: ['CoinWithBalance']),
      );

      expect(json.contains('\$Intent'), isTrue);
    });

    test('prepareForSerialization throws when a resolver is missing', () {
      final tx = Transaction();
      // Raw intent command with no registered resolver.
      tx.add(Commands.intent(name: 'SomethingCustom', data: {}));

      expect(() => tx.prepareForSerialization(), throwsA(isA<ArgumentError>()));
    });
  });

  group('assumeSufficientAddressBalances', () {
    final offline = BuildOptions(assumeSufficientAddressBalances: true);

    Transaction windowed() {
      final tx = Transaction();
      tx.setSender(_owner);
      tx.setGasPrice(BigInt.from(1000));
      tx.setGasBudget(BigInt.from(2000000));
      tx.setTransactionExpiration(
        TransactionExpiration(
          validDuring: {
            'minEpoch': '1',
            'maxEpoch': '2',
            'minTimestamp': null,
            'maxTimestamp': null,
            'chain': '4btiuiMPvEENsttpZC7CZ53DruC3MAgfznDbASZ7DR6S',
            'nonce': 7,
          },
        ),
      );
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 50));
      tx.transferObjects([coin], _recipient);
      return tx;
    }

    test(
      'builds with no client and pays gas from the address balance',
      () async {
        final tx = windowed();
        final bytes = await tx.build(offline);

        expect(tx.getData().gasData.payment, isEmpty);
        final withdrawal = tx.getData().inputs!.singleWhere(
          (input) => input['FundsWithdrawal'] != null,
        )['FundsWithdrawal'];
        expect(withdrawal['reservation']['MaxAmountU64'], '50');
        expect(await Transaction.fromBytes(bytes).build(), bytes);
      },
    );

    test('a kind-only build needs no client either', () async {
      final tx = Transaction();
      tx.setSender(_owner);
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 50));
      tx.transferObjects([coin], _recipient);

      await tx.build(
        BuildOptions(
          onlyTransactionKind: true,
          assumeSufficientAddressBalances: true,
        ),
      );

      final targets = tx
          .getData()
          .commands!
          .where((c) => c['MoveCall'] != null)
          .map((c) => c['MoveCall']['function'])
          .toList();
      expect(targets, ['redeem_funds', 'send_funds']);
    });

    test('a transaction that uses tx.gas still needs a client', () async {
      final tx = windowed();
      tx.splitCoins(tx.gas, [tx.pure.u64(BigInt.one)]);

      await expectLater(tx.build(offline), throwsArgumentError);
      expect(tx.getData().gasData.payment, isNull);
    });

    test('an epoch expiration does not count as a window', () async {
      final tx = windowed()..setExpiration(5);

      await expectLater(tx.build(offline), throwsArgumentError);
      expect(tx.getData().gasData.payment, isNull);
    });
  });
}
