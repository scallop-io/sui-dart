import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/checkpoint.pb.dart' as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/checkpoint_summary.pb.dart'
    as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/effects.pb.dart' as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/event.pb.dart' as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/executed_transaction.pb.dart'
    as pb;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/subscription_service.pbgrpc.dart';
import 'package:sui_dart/grpc/sui_grpc_client.dart';
import 'package:test/test.dart';

const _sender =
    '0x936accb491f0facaac668baaedcf4d0cfc6da1120b66f77fa6a43af718669973';

class _FakeNode extends SubscriptionServiceBase {
  SubscribeTransactionsRequest? txRequest;
  SubscribeEventsRequest? eventRequest;
  SubscribeCheckpointsRequest? checkpointRequest;
  final cancelled = Completer<void>();

  @override
  Stream<SubscribeTransactionsResponse> subscribeTransactions(
    ServiceCall call,
    SubscribeTransactionsRequest request,
  ) {
    txRequest = request;
    var n = 0;
    late final StreamController<SubscribeTransactionsResponse> out;
    out = StreamController(
      onListen: () => Timer.periodic(const Duration(milliseconds: 5), (t) {
        if (out.isClosed) return t.cancel();
        out.add(
          SubscribeTransactionsResponse(
            transaction: pb.ExecutedTransaction(
              digest: 'tx${n++}',
              checkpoint: Int64(7),
              effects: pb.TransactionEffects(
                epoch: Int64(9),
                changedObjects: [
                  pb.ChangedObject(objectId: '0xa', objectType: '0x2::c::C'),
                  pb.ChangedObject(objectId: '0xb'),
                ],
              ),
            ),
          ),
        );
      }),
      onCancel: () {
        if (!cancelled.isCompleted) cancelled.complete();
      },
    );
    return out.stream;
  }

  @override
  Stream<SubscribeEventsResponse> subscribeEvents(
    ServiceCall call,
    SubscribeEventsRequest request,
  ) async* {
    eventRequest = request;
    yield SubscribeEventsResponse(); // watermark-only frame, no event
    yield SubscribeEventsResponse(
      event: pb.Event(
        packageId: '0x2',
        module: 'coin',
        sender: _sender,
        eventType: '0x2::coin::Deposit',
        transactionDigest: 'tx0',
        eventIndex: 3,
      ),
    );
  }

  @override
  Stream<SubscribeCheckpointsResponse> subscribeCheckpoints(
    ServiceCall call,
    SubscribeCheckpointsRequest request,
  ) async* {
    checkpointRequest = request;
    yield SubscribeCheckpointsResponse(
      cursor: Int64(100),
      checkpoint: pb.Checkpoint(
        sequenceNumber: Int64(100),
        digest: 'cp100',
        summary: pb.CheckpointSummary(
          epoch: Int64(5),
          timestamp: Timestamp(seconds: Int64(1700000000), nanos: 250000000),
          previousDigest: 'cp99',
          totalNetworkTransactions: Int64(42),
        ),
        transactions: [pb.ExecutedTransaction(digest: 'tx9')],
      ),
    );
    yield SubscribeCheckpointsResponse(cursor: Int64(101));
  }
}

void main() {
  late Server server;
  late _FakeNode node;
  late SuiGrpcClient client;

  setUp(() async {
    node = _FakeNode();
    server = Server.create(services: [node]);
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

  tearDown(() async {
    await client.shutdown();
    await server.shutdown();
  });

  test('transactions stream in, and cancelling closes the call', () async {
    final txs = await client
        .subscribeTransactions(
          filter: const TransactionFilter(sender: _sender),
          include: TransactionIncludeOptions(effects: true),
        )
        .take(3)
        .toList();

    expect(txs.map((t) => t.digest), ['tx0', 'tx1', 'tx2']);
    expect(txs.first.checkpoint, '7');
    expect(node.txRequest!.hasFilter(), isTrue);
    expect(node.txRequest!.readMask.paths, contains('effects'));
    await node.cancelled.future.timeout(const Duration(seconds: 5));
  });

  test('transactions carry epoch and object types', () async {
    final tx = await client
        .subscribeTransactions(
          include: TransactionIncludeOptions(objectTypes: true),
        )
        .first;

    expect(tx.epoch, '9');
    expect(tx.objectTypes, {'0xa': '0x2::c::C'});
    expect(
      node.txRequest!.readMask.paths,
      containsAll(['effects.epoch', 'effects.changed_objects.object_type']),
    );
  });

  test('events skip frames without an event', () async {
    final events = await client
        .subscribeEvents(filter: const EventFilter(sender: _sender))
        .toList();

    expect(events, hasLength(1));
    expect(events.single.eventType, '0x2::coin::Deposit');
    expect(events.single.transactionDigest, 'tx0');
    expect(events.single.eventIndex, 3);
    expect(node.eventRequest!.hasFilter(), isTrue);
  });

  test('checkpoints map the summary and skip progress frames', () async {
    final cps = await client
        .subscribeCheckpoints(
          transactions: TransactionIncludeOptions(effects: true),
        )
        .toList();

    expect(cps, hasLength(1));
    expect(cps.first.sequenceNumber, '100');
    expect(cps.first.digest, 'cp100');
    expect(cps.first.epoch, '5');
    expect(cps.first.timestampMs, '1700000000250');
    expect(cps.first.previousDigest, 'cp99');
    expect(cps.first.totalNetworkTransactions, '42');
    expect(cps.first.transactions!.single.digest, 'tx9');
    expect(
      node.checkpointRequest!.readMask.paths,
      containsAll(['summary.epoch', 'transactions.effects']),
    );
  });

  test('checkpoints leave out transactions unless asked', () async {
    final cps = await client.subscribeCheckpoints().toList();
    expect(cps.first.transactions, isNull);
    expect(
      node.checkpointRequest!.readMask.paths.where(
        (p) => p.startsWith('transactions'),
      ),
      isEmpty,
    );
  });
}
