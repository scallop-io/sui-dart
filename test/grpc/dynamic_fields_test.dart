import 'dart:typed_data';

import 'package:grpc/grpc.dart';
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Server server;
  late SuiGrpcClient client;
  final state = _StateService();

  setUpAll(() async {
    server = Server.create(services: [state]);
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
}
