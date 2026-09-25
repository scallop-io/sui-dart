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
      limits: {'maxPureArgumentSize': 16 * 1024},
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
