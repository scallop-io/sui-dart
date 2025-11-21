// This is a generated file - do not edit.
//
// Generated from sui/rpc/v2/name_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'name_service.pb.dart' as $0;

export 'name_service.pb.dart';

@$pb.GrpcServiceName('sui.rpc.v2.NameService')
class NameServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  NameServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.LookupNameResponse> lookupName(
    $0.LookupNameRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$lookupName, request, options: options);
  }

  $grpc.ResponseFuture<$0.ReverseLookupNameResponse> reverseLookupName(
    $0.ReverseLookupNameRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$reverseLookupName, request, options: options);
  }

  // method descriptors

  static final _$lookupName =
      $grpc.ClientMethod<$0.LookupNameRequest, $0.LookupNameResponse>(
          '/sui.rpc.v2.NameService/LookupName',
          ($0.LookupNameRequest value) => value.writeToBuffer(),
          $0.LookupNameResponse.fromBuffer);
  static final _$reverseLookupName = $grpc.ClientMethod<
          $0.ReverseLookupNameRequest, $0.ReverseLookupNameResponse>(
      '/sui.rpc.v2.NameService/ReverseLookupName',
      ($0.ReverseLookupNameRequest value) => value.writeToBuffer(),
      $0.ReverseLookupNameResponse.fromBuffer);
}

@$pb.GrpcServiceName('sui.rpc.v2.NameService')
abstract class NameServiceBase extends $grpc.Service {
  $core.String get $name => 'sui.rpc.v2.NameService';

  NameServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LookupNameRequest, $0.LookupNameResponse>(
        'LookupName',
        lookupName_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LookupNameRequest.fromBuffer(value),
        ($0.LookupNameResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReverseLookupNameRequest,
            $0.ReverseLookupNameResponse>(
        'ReverseLookupName',
        reverseLookupName_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ReverseLookupNameRequest.fromBuffer(value),
        ($0.ReverseLookupNameResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.LookupNameResponse> lookupName_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LookupNameRequest> $request) async {
    return lookupName($call, await $request);
  }

  $async.Future<$0.LookupNameResponse> lookupName(
      $grpc.ServiceCall call, $0.LookupNameRequest request);

  $async.Future<$0.ReverseLookupNameResponse> reverseLookupName_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ReverseLookupNameRequest> $request) async {
    return reverseLookupName($call, await $request);
  }

  $async.Future<$0.ReverseLookupNameResponse> reverseLookupName(
      $grpc.ServiceCall call, $0.ReverseLookupNameRequest request);
}
