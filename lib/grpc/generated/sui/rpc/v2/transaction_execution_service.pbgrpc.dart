// This is a generated file - do not edit.
//
// Generated from sui/rpc/v2/transaction_execution_service.proto.

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

import 'transaction_execution_service.pb.dart' as $0;

export 'transaction_execution_service.pb.dart';

@$pb.GrpcServiceName('sui.rpc.v2.TransactionExecutionService')
class TransactionExecutionServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TransactionExecutionServiceClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ExecuteTransactionResponse> executeTransaction(
    $0.ExecuteTransactionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.SimulateTransactionResponse> simulateTransaction(
    $0.SimulateTransactionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$simulateTransaction, request, options: options);
  }

  // method descriptors

  static final _$executeTransaction = $grpc.ClientMethod<
          $0.ExecuteTransactionRequest, $0.ExecuteTransactionResponse>(
      '/sui.rpc.v2.TransactionExecutionService/ExecuteTransaction',
      ($0.ExecuteTransactionRequest value) => value.writeToBuffer(),
      $0.ExecuteTransactionResponse.fromBuffer);
  static final _$simulateTransaction = $grpc.ClientMethod<
          $0.SimulateTransactionRequest, $0.SimulateTransactionResponse>(
      '/sui.rpc.v2.TransactionExecutionService/SimulateTransaction',
      ($0.SimulateTransactionRequest value) => value.writeToBuffer(),
      $0.SimulateTransactionResponse.fromBuffer);
}

@$pb.GrpcServiceName('sui.rpc.v2.TransactionExecutionService')
abstract class TransactionExecutionServiceBase extends $grpc.Service {
  $core.String get $name => 'sui.rpc.v2.TransactionExecutionService';

  TransactionExecutionServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ExecuteTransactionRequest,
            $0.ExecuteTransactionResponse>(
        'ExecuteTransaction',
        executeTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ExecuteTransactionRequest.fromBuffer(value),
        ($0.ExecuteTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SimulateTransactionRequest,
            $0.SimulateTransactionResponse>(
        'SimulateTransaction',
        simulateTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SimulateTransactionRequest.fromBuffer(value),
        ($0.SimulateTransactionResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ExecuteTransactionResponse> executeTransaction_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ExecuteTransactionRequest> $request) async {
    return executeTransaction($call, await $request);
  }

  $async.Future<$0.ExecuteTransactionResponse> executeTransaction(
      $grpc.ServiceCall call, $0.ExecuteTransactionRequest request);

  $async.Future<$0.SimulateTransactionResponse> simulateTransaction_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SimulateTransactionRequest> $request) async {
    return simulateTransaction($call, await $request);
  }

  $async.Future<$0.SimulateTransactionResponse> simulateTransaction(
      $grpc.ServiceCall call, $0.SimulateTransactionRequest request);
}
