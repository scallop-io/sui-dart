import 'package:sui_dart/sui.dart';
import 'package:test/test.dart';

const _owner =
    '0x000000000000000000000000000000000000000000000000000000000000aaaa';
const _recipient =
    '0x000000000000000000000000000000000000000000000000000000000000bbbb';
const _fooType =
    '0x00000000000000000000000000000000000000000000000000000000000000ab::foo::FOO';

CoinStruct _coin(String id, String balance, [String type = _fooType]) {
  return CoinStruct.fromJson({
    'coinType': type,
    'coinObjectId': id,
    'version': '1',
    'digest': 'Bfm2Z4dXysM9Vu1X5p8oR4z7mFs2pT8w9X1y2Z3a4B5c',
    'balance': balance,
    'previousTransaction': 'Bfm2Z4dXysM9Vu1X5p8oR4z7mFs2pT8w9X1y2Z3a4B5c',
  });
}

/// Returns coins from a fixed pool; no network.
class _FakeClient extends SuiClient {
  final List<CoinStruct> pool;
  _FakeClient(this.pool) : super('https://fullnode.testnet.sui.io:443');

  @override
  Future<PaginatedCoins> getCoins(
    String owner, {
    String? coinType,
    String? cursor,
    int? limit,
  }) async {
    final normalized = normalizeStructTagString(coinType!);
    final data = pool
        .where((c) => normalizeStructTagString(c.coinType) == normalized)
        .toList();
    return PaginatedCoins(data, null, false);
  }
}

Future<List<dynamic>> _resolve(Transaction tx, List<CoinStruct> pool) async {
  tx.setSender(_owner);
  await tx.build(
    BuildOptions(
      client: _FakeClient(pool),
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
      expect(
        commands[2]['TransferObjects']['objects'][0]['NestedResult'],
        [1, 0],
      );
    });

    test('combines multiple intents of the same type into one split', () async {
      final tx = Transaction();
      final a = tx.add(coinWithBalance(type: _fooType, balance: 30));
      final b = tx.add(coinWithBalance(type: _fooType, balance: 70));
      tx.transferObjects([a, b], _recipient);

      final commands = await _resolve(tx, [_coin('0x1', '500')]);

      expect(_hasIntent(commands), isFalse);
      final splits = commands.where((c) => c['\$kind'] == 'SplitCoins').toList();
      expect(splits.length, 1);
      expect(splits[0]['SplitCoins']['amounts'].length, 2);
    });

    test('zero balance resolves to coin::zero without querying coins', () async {
      final tx = Transaction();
      final coin = tx.add(coinWithBalance(type: _fooType, balance: 0));
      tx.transferObjects([coin], _recipient);

      final commands = await _resolve(tx, []);

      expect(_hasIntent(commands), isFalse);
      final move = commands.firstWhere((c) => c['\$kind'] == 'MoveCall');
      expect(move['MoveCall']['module'], 'coin');
      expect(move['MoveCall']['function'], 'zero');
    });

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

      expect(
        () => tx.prepareForSerialization(),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
