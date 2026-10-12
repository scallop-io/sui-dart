import 'package:grpc/grpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/effects.pb.dart' as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/executed_transaction.pb.dart'
    as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/execution_status.pb.dart'
    as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/name_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction_execution_service.pbgrpc.dart';
import 'package:sui_dart/grpc/sui_grpc_client.dart';
import 'package:sui_dart/sui.dart'
    show
        CLIENT_PROTOCOL_VERSION_HEADER,
        MAX_PROTOCOL_VERSION,
        MOCKED_GAS_OBJECT_ID,
        Transaction,
        normalizeSuiAddress;
import 'package:test/test.dart';

class _NameService extends NameServiceBase {
  GrpcError? error;
  Map<String, String>? lastMetadata;

  @override
  Future<LookupNameResponse> lookupName(
    ServiceCall call,
    LookupNameRequest request,
  ) async {
    lastMetadata = call.clientMetadata;
    throw error!;
  }

  @override
  Future<ReverseLookupNameResponse> reverseLookupName(
    ServiceCall call,
    ReverseLookupNameRequest request,
  ) async {
    lastMetadata = call.clientMetadata;
    throw error!;
  }
}

class _ExecutionService extends TransactionExecutionServiceBase {
  String gasObjectId = MOCKED_GAS_OBJECT_ID;
  List<String>? lastReadMask;

  @override
  Future<ExecuteTransactionResponse> executeTransaction(
    ServiceCall call,
    ExecuteTransactionRequest request,
  ) => throw UnimplementedError();

  @override
  Future<SimulateTransactionResponse> simulateTransaction(
    ServiceCall call,
    SimulateTransactionRequest request,
  ) async {
    lastReadMask = request.readMask.paths.toList();
    return SimulateTransactionResponse(
      transaction: pb.ExecutedTransaction(
        effects: pb.TransactionEffects(
          status: pb.ExecutionStatus(success: false),
          gasObject: pb.ChangedObject(objectId: gasObjectId),
        ),
      ),
    );
  }
}

void main() {
  late Server server;
  late SuiGrpcClient client;
  final names = _NameService();
  final execution = _ExecutionService();

  setUpAll(() async {
    server = Server.create(services: [names, execution]);
    await server.serve(address: 'localhost', port: 0);
    client = SuiGrpcClient(
      SuiGrpcClientOptions(
        baseUrl: 'localhost',
        port: server.port!,
        customChannel: ClientChannel(
          'localhost',
          port: server.port!,
          options: const ChannelOptions(
            credentials: ChannelCredentials.insecure(),
          ),
        ),
      ),
    );
  });

  tearDownAll(() => server.shutdown());

  test('every call carries the client protocol version', () async {
    names.error = const GrpcError.notFound('no record');
    await client.core.resolveNameServiceAddress('a.sui');

    expect(
      names.lastMetadata![CLIENT_PROTOCOL_VERSION_HEADER],
      '$MAX_PROTOCOL_VERSION',
    );
  });

  group('name service', () {
    test('an unregistered or expired name reads as null', () async {
      for (final error in [
        const GrpcError.notFound('no record'),
        GrpcError.custom(StatusCode.resourceExhausted, 'name has expired'),
      ]) {
        names.error = error;
        expect(await client.core.resolveNameServiceAddress('a.sui'), isNull);
        expect(await client.core.defaultNameServiceName('0x1'), isNull);
      }
    });

    test('a transport failure or throttling still throws', () async {
      for (final error in [
        const GrpcError.unavailable('node down'),
        const GrpcError.resourceExhausted('rate limited'),
      ]) {
        names.error = error;
        await expectLater(
          client.core.resolveNameServiceAddress('a.sui'),
          throwsA(isA<GrpcError>()),
        );
        await expectLater(
          client.core.defaultNameServiceName('0x1'),
          throwsA(isA<GrpcError>()),
        );
      }
    });
  });

  group('simulateTransaction', () {
    Transaction tx() => Transaction()..setSender(normalizeSuiAddress('0xa'));

    test('reports a failed status without include.effects', () async {
      final result = await client.core.simulateTransaction(tx());

      expect(execution.lastReadMask, contains('transaction.effects.status'));
      expect(result.status.success, isFalse);
    });

    test('reports whether the node mocked the gas coin', () async {
      execution.gasObjectId = MOCKED_GAS_OBJECT_ID;
      final mocked = await client.core.simulateTransaction(tx());
      expect(
        execution.lastReadMask,
        contains('transaction.effects.gas_object.object_id'),
      );
      expect(mocked.gasPaymentMocked, isTrue);

      execution.gasObjectId = normalizeSuiAddress('0x5');
      final real = await client.core.simulateTransaction(tx());
      expect(real.gasPaymentMocked, isFalse);
    });
  });
}
