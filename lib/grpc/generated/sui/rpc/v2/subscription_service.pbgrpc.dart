// This is a generated file - do not edit.
//
// Generated from sui/rpc/v2/subscription_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'subscription_service.pb.dart' as $0;

export 'subscription_service.pb.dart';

/// SubscriptionService provides filtered, real-time streams of checkpoints,
/// transactions, and events.
///
/// Each Subscribe API pairs with the LedgerService List API of the same name:
/// requests take the same filter message, and responses carry the same item
/// and watermark shapes with identical cursor semantics.
///
/// Subscriptions do not support resumption. A new subscription always begins
/// at the current tip of the chain as seen by the server (the latest executed
/// checkpoint). To recover data missed between subscriptions, replay the gap
/// with the paired List API: pass the last received `Watermark.cursor` as
/// `options.after` on the List request (for checkpoints, pass the last
/// received `cursor + 1` as `start_checkpoint`). The List scan reads from the
/// indexed tip, which may trail the subscription's start position; repeat the
/// List call as the index advances until the replay reaches the position
/// established by the subscription's first frame.
///
/// A subscription behaves like an unbounded ascending scan: every frame
/// carries the subscriber's resume point, and progress advances as
/// checkpoints are fully covered. Two delivery guarantees keep sparse
/// filters live: the first frame on a filtered subscription is a
/// progress-only frame establishing the stream's start position, and
/// progress continues to advance with bounded staleness even when no item
/// matches.
///
/// Subscription streams have no successful end: they run until cancelled by
/// the client or terminated by the server with a gRPC status.
@$pb.GrpcServiceName('sui.rpc.v2.SubscriptionService')
class SubscriptionServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SubscriptionServiceClient(super.channel, {super.options, super.interceptors});

  /// Subscribe to the stream of checkpoints.
  ///
  /// The stream begins at the latest executed checkpoint as seen by the
  /// server and yields checkpoints matching the filter as they are executed.
  /// A checkpoint matches if any transaction it contains satisfies the
  /// filter.
  $grpc.ResponseStream<$0.SubscribeCheckpointsResponse> subscribeCheckpoints(
    $0.SubscribeCheckpointsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$subscribeCheckpoints, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Subscribe to the stream of transactions.
  ///
  /// The stream begins at the latest executed checkpoint as seen by the
  /// server and yields transactions matching the filter as they are executed.
  $grpc.ResponseStream<$0.SubscribeTransactionsResponse> subscribeTransactions(
    $0.SubscribeTransactionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$subscribeTransactions, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Subscribe to the stream of events.
  ///
  /// The stream begins at the latest executed checkpoint as seen by the
  /// server and yields events matching the filter as they are emitted.
  $grpc.ResponseStream<$0.SubscribeEventsResponse> subscribeEvents(
    $0.SubscribeEventsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$subscribeEvents, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$subscribeCheckpoints = $grpc.ClientMethod<
          $0.SubscribeCheckpointsRequest, $0.SubscribeCheckpointsResponse>(
      '/sui.rpc.v2.SubscriptionService/SubscribeCheckpoints',
      ($0.SubscribeCheckpointsRequest value) => value.writeToBuffer(),
      $0.SubscribeCheckpointsResponse.fromBuffer);
  static final _$subscribeTransactions = $grpc.ClientMethod<
          $0.SubscribeTransactionsRequest, $0.SubscribeTransactionsResponse>(
      '/sui.rpc.v2.SubscriptionService/SubscribeTransactions',
      ($0.SubscribeTransactionsRequest value) => value.writeToBuffer(),
      $0.SubscribeTransactionsResponse.fromBuffer);
  static final _$subscribeEvents =
      $grpc.ClientMethod<$0.SubscribeEventsRequest, $0.SubscribeEventsResponse>(
          '/sui.rpc.v2.SubscriptionService/SubscribeEvents',
          ($0.SubscribeEventsRequest value) => value.writeToBuffer(),
          $0.SubscribeEventsResponse.fromBuffer);
}

@$pb.GrpcServiceName('sui.rpc.v2.SubscriptionService')
abstract class SubscriptionServiceBase extends $grpc.Service {
  $core.String get $name => 'sui.rpc.v2.SubscriptionService';

  SubscriptionServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SubscribeCheckpointsRequest,
            $0.SubscribeCheckpointsResponse>(
        'SubscribeCheckpoints',
        subscribeCheckpoints_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.SubscribeCheckpointsRequest.fromBuffer(value),
        ($0.SubscribeCheckpointsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubscribeTransactionsRequest,
            $0.SubscribeTransactionsResponse>(
        'SubscribeTransactions',
        subscribeTransactions_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.SubscribeTransactionsRequest.fromBuffer(value),
        ($0.SubscribeTransactionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubscribeEventsRequest,
            $0.SubscribeEventsResponse>(
        'SubscribeEvents',
        subscribeEvents_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.SubscribeEventsRequest.fromBuffer(value),
        ($0.SubscribeEventsResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.SubscribeCheckpointsResponse> subscribeCheckpoints_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SubscribeCheckpointsRequest> $request) async* {
    yield* subscribeCheckpoints($call, await $request);
  }

  $async.Stream<$0.SubscribeCheckpointsResponse> subscribeCheckpoints(
      $grpc.ServiceCall call, $0.SubscribeCheckpointsRequest request);

  $async.Stream<$0.SubscribeTransactionsResponse> subscribeTransactions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SubscribeTransactionsRequest> $request) async* {
    yield* subscribeTransactions($call, await $request);
  }

  $async.Stream<$0.SubscribeTransactionsResponse> subscribeTransactions(
      $grpc.ServiceCall call, $0.SubscribeTransactionsRequest request);

  $async.Stream<$0.SubscribeEventsResponse> subscribeEvents_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SubscribeEventsRequest> $request) async* {
    yield* subscribeEvents($call, await $request);
  }

  $async.Stream<$0.SubscribeEventsResponse> subscribeEvents(
      $grpc.ServiceCall call, $0.SubscribeEventsRequest request);
}
