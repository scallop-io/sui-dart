// This is a generated file - do not edit.
//
// Generated from sui/forking/v1alpha/forking_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class AdvanceClockRequest extends $pb.GeneratedMessage {
  factory AdvanceClockRequest({
    $fixnum.Int64? durationMs,
  }) {
    final result = create();
    if (durationMs != null) result.durationMs = durationMs;
    return result;
  }

  AdvanceClockRequest._();

  factory AdvanceClockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AdvanceClockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdvanceClockRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'sui.forking.v1alpha'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'durationMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceClockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceClockRequest copyWith(void Function(AdvanceClockRequest) updates) =>
      super.copyWith((message) => updates(message as AdvanceClockRequest))
          as AdvanceClockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdvanceClockRequest create() => AdvanceClockRequest._();
  @$core.override
  AdvanceClockRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AdvanceClockRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdvanceClockRequest>(create);
  static AdvanceClockRequest? _defaultInstance;

  /// Duration in milliseconds to advance the clock. Defaults to 1 if unset.
  @$pb.TagNumber(1)
  $fixnum.Int64 get durationMs => $_getI64(0);
  @$pb.TagNumber(1)
  set durationMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDurationMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearDurationMs() => $_clearField(1);
}

class AdvanceClockResponse extends $pb.GeneratedMessage {
  factory AdvanceClockResponse({
    $fixnum.Int64? timestampMs,
    $core.String? txDigest,
  }) {
    final result = create();
    if (timestampMs != null) result.timestampMs = timestampMs;
    if (txDigest != null) result.txDigest = txDigest;
    return result;
  }

  AdvanceClockResponse._();

  factory AdvanceClockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AdvanceClockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdvanceClockResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'sui.forking.v1alpha'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'timestampMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'txDigest')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceClockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceClockResponse copyWith(void Function(AdvanceClockResponse) updates) =>
      super.copyWith((message) => updates(message as AdvanceClockResponse))
          as AdvanceClockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdvanceClockResponse create() => AdvanceClockResponse._();
  @$core.override
  AdvanceClockResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AdvanceClockResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdvanceClockResponse>(create);
  static AdvanceClockResponse? _defaultInstance;

  /// Clock timestamp after advancing (milliseconds since Unix epoch).
  @$pb.TagNumber(1)
  $fixnum.Int64 get timestampMs => $_getI64(0);
  @$pb.TagNumber(1)
  set timestampMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestampMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestampMs() => $_clearField(1);

  /// Digest of the ConsensusCommitPrologue transaction that advanced the clock.
  @$pb.TagNumber(2)
  $core.String get txDigest => $_getSZ(1);
  @$pb.TagNumber(2)
  set txDigest($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxDigest() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxDigest() => $_clearField(2);
}

class AdvanceCheckpointRequest extends $pb.GeneratedMessage {
  factory AdvanceCheckpointRequest() => create();

  AdvanceCheckpointRequest._();

  factory AdvanceCheckpointRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AdvanceCheckpointRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdvanceCheckpointRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'sui.forking.v1alpha'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceCheckpointRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceCheckpointRequest copyWith(
          void Function(AdvanceCheckpointRequest) updates) =>
      super.copyWith((message) => updates(message as AdvanceCheckpointRequest))
          as AdvanceCheckpointRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdvanceCheckpointRequest create() => AdvanceCheckpointRequest._();
  @$core.override
  AdvanceCheckpointRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AdvanceCheckpointRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdvanceCheckpointRequest>(create);
  static AdvanceCheckpointRequest? _defaultInstance;
}

class AdvanceCheckpointResponse extends $pb.GeneratedMessage {
  factory AdvanceCheckpointResponse({
    $fixnum.Int64? checkpointSequenceNumber,
    $fixnum.Int64? timestampMs,
  }) {
    final result = create();
    if (checkpointSequenceNumber != null)
      result.checkpointSequenceNumber = checkpointSequenceNumber;
    if (timestampMs != null) result.timestampMs = timestampMs;
    return result;
  }

  AdvanceCheckpointResponse._();

  factory AdvanceCheckpointResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AdvanceCheckpointResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdvanceCheckpointResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'sui.forking.v1alpha'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'checkpointSequenceNumber',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'timestampMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceCheckpointResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceCheckpointResponse copyWith(
          void Function(AdvanceCheckpointResponse) updates) =>
      super.copyWith((message) => updates(message as AdvanceCheckpointResponse))
          as AdvanceCheckpointResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdvanceCheckpointResponse create() => AdvanceCheckpointResponse._();
  @$core.override
  AdvanceCheckpointResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AdvanceCheckpointResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdvanceCheckpointResponse>(create);
  static AdvanceCheckpointResponse? _defaultInstance;

  /// Sequence number of the newly created checkpoint.
  @$pb.TagNumber(1)
  $fixnum.Int64 get checkpointSequenceNumber => $_getI64(0);
  @$pb.TagNumber(1)
  set checkpointSequenceNumber($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCheckpointSequenceNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearCheckpointSequenceNumber() => $_clearField(1);

  /// Timestamp embedded in the checkpoint (milliseconds since Unix epoch).
  @$pb.TagNumber(2)
  $fixnum.Int64 get timestampMs => $_getI64(1);
  @$pb.TagNumber(2)
  set timestampMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestampMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestampMs() => $_clearField(2);
}

class GetStatusRequest extends $pb.GeneratedMessage {
  factory GetStatusRequest() => create();

  GetStatusRequest._();

  factory GetStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatusRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'sui.forking.v1alpha'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusRequest copyWith(void Function(GetStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetStatusRequest))
          as GetStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatusRequest create() => GetStatusRequest._();
  @$core.override
  GetStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatusRequest>(create);
  static GetStatusRequest? _defaultInstance;
}

class GetStatusResponse extends $pb.GeneratedMessage {
  factory GetStatusResponse({
    $fixnum.Int64? epoch,
    $fixnum.Int64? checkpointSequenceNumber,
    $fixnum.Int64? timestampMs,
    $fixnum.Int64? forkedAtCheckpoint,
  }) {
    final result = create();
    if (epoch != null) result.epoch = epoch;
    if (checkpointSequenceNumber != null)
      result.checkpointSequenceNumber = checkpointSequenceNumber;
    if (timestampMs != null) result.timestampMs = timestampMs;
    if (forkedAtCheckpoint != null)
      result.forkedAtCheckpoint = forkedAtCheckpoint;
    return result;
  }

  GetStatusResponse._();

  factory GetStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatusResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'sui.forking.v1alpha'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'epoch', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'checkpointSequenceNumber',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'timestampMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'forkedAtCheckpoint', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusResponse copyWith(void Function(GetStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetStatusResponse))
          as GetStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatusResponse create() => GetStatusResponse._();
  @$core.override
  GetStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatusResponse>(create);
  static GetStatusResponse? _defaultInstance;

  /// Current epoch of the forked network.
  @$pb.TagNumber(1)
  $fixnum.Int64 get epoch => $_getI64(0);
  @$pb.TagNumber(1)
  set epoch($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEpoch() => $_has(0);
  @$pb.TagNumber(1)
  void clearEpoch() => $_clearField(1);

  /// Latest checkpoint sequence number.
  @$pb.TagNumber(2)
  $fixnum.Int64 get checkpointSequenceNumber => $_getI64(1);
  @$pb.TagNumber(2)
  set checkpointSequenceNumber($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCheckpointSequenceNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearCheckpointSequenceNumber() => $_clearField(2);

  /// Current clock timestamp (milliseconds since Unix epoch).
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestampMs => $_getI64(2);
  @$pb.TagNumber(3)
  set timestampMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestampMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestampMs() => $_clearField(3);

  /// The upstream checkpoint at which the fork was created.
  @$pb.TagNumber(4)
  $fixnum.Int64 get forkedAtCheckpoint => $_getI64(3);
  @$pb.TagNumber(4)
  set forkedAtCheckpoint($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasForkedAtCheckpoint() => $_has(3);
  @$pb.TagNumber(4)
  void clearForkedAtCheckpoint() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
