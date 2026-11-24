import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/epoch.pb.dart' as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/ledger_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/system_state.pb.dart' as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/bcs.pb.dart' as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/state_service.pbgrpc.dart';
import 'package:sui_dart/grpc/sui_grpc_client.dart';
import 'package:test/test.dart';

class _StateService extends StateServiceBase {
  List<String>? lastReadMask;

  @override
  Future<ListDynamicFieldsResponse> listDynamicFields(
    ServiceCall call,
    ListDynamicFieldsRequest request,
  ) async {
    lastReadMask = request.readMask.paths.toList();
    final asked = lastReadMask!.contains('value');
    return ListDynamicFieldsResponse(
      dynamicFields: [
        DynamicField(
          kind: DynamicField_DynamicFieldKind.FIELD,
          fieldId: '0x1',
          name: pb.Bcs(name: 'u64', value: [7]),
          valueType: 'bool',
          value: asked ? pb.Bcs(name: 'bool', value: [1]) : null,
        ),
        DynamicField(
          kind: DynamicField_DynamicFieldKind.FIELD,
          fieldId: '0x2',
          valueType: 'bool',
        ),
        DynamicField(
          kind: DynamicField_DynamicFieldKind.OBJECT,
          fieldId: '0x3',
          childId: '0x4',
          valueType: '0x2::coin::Coin<0x2::sui::SUI>',
          value: asked ? pb.Bcs(value: [9, 9]) : null,
        ),
      ],
    );
  }

  @override
  Future<GetCoinInfoResponse> getCoinInfo(
    ServiceCall call,
    GetCoinInfoRequest request,
  ) async => throw const GrpcError.notFound('Coin type not found');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LedgerService extends LedgerServiceBase {
  List<String>? lastReadMask;

  @override
  Future<GetEpochResponse> getEpoch(
    ServiceCall call,
    GetEpochRequest request,
  ) async {
    lastReadMask = request.readMask.paths.toList();
    return GetEpochResponse(
      epoch: pb.Epoch(
        epoch: Int64(9),
        referenceGasPrice: Int64(750),
        start: Timestamp(seconds: Int64(1763800000), nanos: 123000000),
        systemState: pb.SystemState(protocolVersion: Int64(141)),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Server server;
  late SuiGrpcClient client;
  final state = _StateService();
  final ledger = _LedgerService();

  setUpAll(() async {
    server = Server.create(services: [state, ledger]);
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

  tearDownAll(() async {
    await client.shutdown();
    await server.shutdown();
  });

  test('values are left out by default', () async {
    final page = await client.getDynamicFields('0xabc');
    expect(state.lastReadMask, isNot(contains('value')));
    expect(page.data.map((f) => f.value), everyElement(isNull));
  });

  test('includeValue returns the value bytes of plain fields', () async {
    final page = await client.getDynamicFields('0xabc', includeValue: true);
    expect(state.lastReadMask, contains('value'));
    expect(page.data[0].value, Uint8List.fromList([1]));
    expect(page.data[1].value, isNull);
    expect(page.data[2].value, isNull);
    expect(page.data[2].objectId, '0x4');
  });

  test('an unregistered coin type has no metadata', () async {
    expect(await client.core.getCoinMetadata('0x2::nope::NOPE'), isNull);
  });

  test('system state is in ms and keyed by field name', () async {
    final state = await client.core.getCurrentSystemState();
    expect(state.epochStartTimestampMs, '1763800000123');
    expect(state.systemState!['protocolVersion'], '141');
    expect(ledger.lastReadMask, isNot(contains('system_state')));
  });
}
