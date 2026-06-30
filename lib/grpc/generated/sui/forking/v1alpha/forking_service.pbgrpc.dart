// This is a generated file - do not edit.
//
// Generated from sui/forking/v1alpha/forking_service.proto.

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

import 'forking_service.pb.dart' as $0;

export 'forking_service.pb.dart';

/// Administrative service for controlling a forked Sui network.
@$pb.GrpcServiceName('sui.forking.v1alpha.ForkingService')
class ForkingServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ForkingServiceClient(super.channel, {super.options, super.interceptors});

  /// Advance the forked network's clock by a given duration.
  $grpc.ResponseFuture<$0.AdvanceClockResponse> advanceClock(
    $0.AdvanceClockRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$advanceClock, request, options: options);
  }

  /// Seal pending transactions into a new checkpoint.
  $grpc.ResponseFuture<$0.AdvanceCheckpointResponse> advanceCheckpoint(
    $0.AdvanceCheckpointRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$advanceCheckpoint, request, options: options);
  }

  /// Return the current state of the forked network.
  $grpc.ResponseFuture<$0.GetStatusResponse> getStatus(
    $0.GetStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStatus, request, options: options);
  }

  // method descriptors

  static final _$advanceClock =
      $grpc.ClientMethod<$0.AdvanceClockRequest, $0.AdvanceClockResponse>(
          '/sui.forking.v1alpha.ForkingService/AdvanceClock',
          ($0.AdvanceClockRequest value) => value.writeToBuffer(),
          $0.AdvanceClockResponse.fromBuffer);
  static final _$advanceCheckpoint = $grpc.ClientMethod<
          $0.AdvanceCheckpointRequest, $0.AdvanceCheckpointResponse>(
      '/sui.forking.v1alpha.ForkingService/AdvanceCheckpoint',
      ($0.AdvanceCheckpointRequest value) => value.writeToBuffer(),
      $0.AdvanceCheckpointResponse.fromBuffer);
  static final _$getStatus =
      $grpc.ClientMethod<$0.GetStatusRequest, $0.GetStatusResponse>(
          '/sui.forking.v1alpha.ForkingService/GetStatus',
          ($0.GetStatusRequest value) => value.writeToBuffer(),
          $0.GetStatusResponse.fromBuffer);
}

@$pb.GrpcServiceName('sui.forking.v1alpha.ForkingService')
abstract class ForkingServiceBase extends $grpc.Service {
  $core.String get $name => 'sui.forking.v1alpha.ForkingService';

  ForkingServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.AdvanceClockRequest, $0.AdvanceClockResponse>(
            'AdvanceClock',
            advanceClock_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AdvanceClockRequest.fromBuffer(value),
            ($0.AdvanceClockResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AdvanceCheckpointRequest,
            $0.AdvanceCheckpointResponse>(
        'AdvanceCheckpoint',
        advanceCheckpoint_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AdvanceCheckpointRequest.fromBuffer(value),
        ($0.AdvanceCheckpointResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetStatusRequest, $0.GetStatusResponse>(
        'GetStatus',
        getStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetStatusRequest.fromBuffer(value),
        ($0.GetStatusResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.AdvanceClockResponse> advanceClock_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AdvanceClockRequest> $request) async {
    return advanceClock($call, await $request);
  }

  $async.Future<$0.AdvanceClockResponse> advanceClock(
      $grpc.ServiceCall call, $0.AdvanceClockRequest request);

  $async.Future<$0.AdvanceCheckpointResponse> advanceCheckpoint_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AdvanceCheckpointRequest> $request) async {
    return advanceCheckpoint($call, await $request);
  }

  $async.Future<$0.AdvanceCheckpointResponse> advanceCheckpoint(
      $grpc.ServiceCall call, $0.AdvanceCheckpointRequest request);

  $async.Future<$0.GetStatusResponse> getStatus_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetStatusRequest> $request) async {
    return getStatus($call, await $request);
  }

  $async.Future<$0.GetStatusResponse> getStatus(
      $grpc.ServiceCall call, $0.GetStatusRequest request);
}
