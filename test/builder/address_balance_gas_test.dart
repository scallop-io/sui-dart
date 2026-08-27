import 'package:sui_dart/grpc/generated/sui/rpc/v2/input.pbenum.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction.pbenum.dart';
import 'package:sui_dart/grpc/types.dart';
import 'package:sui_dart/sui.dart' hide AddressOwner, ObjectData;
import 'package:test/test.dart';

const _owner =
    '0x000000000000000000000000000000000000000000000000000000000000aaaa';
const _fooType =
    '0x00000000000000000000000000000000000000000000000000000000000000ab::foo::FOO';

class _AddressBalanceOnly implements SuiCoreClient {
  @override
  Future<Page<CoinData>> getCoins(
    String a, {
    String coinType = '0x2::sui::SUI',
    String? cursor,
    int? limit,
  }) async => Page(data: const [], hasNextPage: false);
  @override
  Future<Balance> getBalance(
    String a, {
    String coinType = '0x2::sui::SUI',
  }) async => Balance(
    coinType: coinType,
    balance: '30000000',
    coinBalance: '0',
    addressBalance: '30000000',
  );
  @override
  Future<String> getChainIdentifier() async =>
      '4btiuiMPvEENsttpZC7CZ53DruC3MAgfznDbASZ7DR6S';
  @override
  Future<SystemState> getCurrentSystemState() async =>
      const SystemState(epoch: '1231', referenceGasPrice: '750');
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

void main() {
  test('a funds withdrawal survives a BCS round trip into gRPC', () async {
    final tx = Transaction();
    tx.setSender(_owner);
    final coin = tx.add(coinWithBalance(type: _fooType, balance: 20000000));
    tx.transferObjects([coin], _owner);
    await tx.prepareForSerialization(
      SerializeTransactionOptions(client: _AddressBalanceOnly()),
    );

    // Round-tripping is what the gas-budget dry run does; BCS reads a u64 back
    // as BigInt, which the gRPC conversion used to reject.
    final parsed = Transaction.fromKind(
      await tx.build(BuildOptions(onlyTransactionKind: true)),
    );
    final grpc = parsed.toGrpcTransaction();

    final withdrawal = grpc.kind.programmableTransaction.inputs
        .where((i) => i.kind == Input_InputKind.FUNDS_WITHDRAWAL)
        .single;
    expect(withdrawal.fundsWithdrawal.amount.toInt(), 20000000);
    expect(withdrawal.fundsWithdrawal.coinType, contains('foo::FOO'));
  });

  test(
    'address-balance gas carries a ValidDuring expiration into gRPC',
    () async {
      final tx = Transaction();
      tx.setSender(_owner);
      tx.setGasPrice(BigInt.from(750));
      tx.setGasBudget(BigInt.from(10000000));
      tx.transferObjects([tx.gas], _owner);

      await tx.build(BuildOptions(client: _AddressBalanceOnly()));

      expect(tx.getData().gasData.payment, isEmpty);
      final grpc = tx.toGrpcTransaction();
      expect(
        grpc.expiration.kind,
        TransactionExpiration_TransactionExpirationKind.VALID_DURING,
      );
      expect(grpc.expiration.minEpoch.toInt(), 1231);
      expect(grpc.expiration.epoch.toInt(), 1232);
      expect(grpc.expiration.nonce, isNonZero);
    },
  );
}
