// This is a generated file - do not edit.
//
// Generated from sui/forking/v1alpha/forking_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use advanceClockRequestDescriptor instead')
const AdvanceClockRequest$json = {
  '1': 'AdvanceClockRequest',
  '2': [
    {
      '1': 'duration_ms',
      '3': 1,
      '4': 1,
      '5': 4,
      '9': 0,
      '10': 'durationMs',
      '17': true
    },
  ],
  '8': [
    {'1': '_duration_ms'},
  ],
};

/// Descriptor for `AdvanceClockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List advanceClockRequestDescriptor = $convert.base64Decode(
    'ChNBZHZhbmNlQ2xvY2tSZXF1ZXN0EiQKC2R1cmF0aW9uX21zGAEgASgESABSCmR1cmF0aW9uTX'
    'OIAQFCDgoMX2R1cmF0aW9uX21z');

@$core.Deprecated('Use advanceClockResponseDescriptor instead')
const AdvanceClockResponse$json = {
  '1': 'AdvanceClockResponse',
  '2': [
    {'1': 'timestamp_ms', '3': 1, '4': 1, '5': 4, '10': 'timestampMs'},
    {'1': 'tx_digest', '3': 2, '4': 1, '5': 9, '10': 'txDigest'},
  ],
};

/// Descriptor for `AdvanceClockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List advanceClockResponseDescriptor = $convert.base64Decode(
    'ChRBZHZhbmNlQ2xvY2tSZXNwb25zZRIhCgx0aW1lc3RhbXBfbXMYASABKARSC3RpbWVzdGFtcE'
    '1zEhsKCXR4X2RpZ2VzdBgCIAEoCVIIdHhEaWdlc3Q=');

@$core.Deprecated('Use advanceCheckpointRequestDescriptor instead')
const AdvanceCheckpointRequest$json = {
  '1': 'AdvanceCheckpointRequest',
};

/// Descriptor for `AdvanceCheckpointRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List advanceCheckpointRequestDescriptor =
    $convert.base64Decode('ChhBZHZhbmNlQ2hlY2twb2ludFJlcXVlc3Q=');

@$core.Deprecated('Use advanceCheckpointResponseDescriptor instead')
const AdvanceCheckpointResponse$json = {
  '1': 'AdvanceCheckpointResponse',
  '2': [
    {
      '1': 'checkpoint_sequence_number',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'checkpointSequenceNumber'
    },
    {'1': 'timestamp_ms', '3': 2, '4': 1, '5': 4, '10': 'timestampMs'},
  ],
};

/// Descriptor for `AdvanceCheckpointResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List advanceCheckpointResponseDescriptor = $convert.base64Decode(
    'ChlBZHZhbmNlQ2hlY2twb2ludFJlc3BvbnNlEjwKGmNoZWNrcG9pbnRfc2VxdWVuY2VfbnVtYm'
    'VyGAEgASgEUhhjaGVja3BvaW50U2VxdWVuY2VOdW1iZXISIQoMdGltZXN0YW1wX21zGAIgASgE'
    'Ugt0aW1lc3RhbXBNcw==');

@$core.Deprecated('Use getStatusRequestDescriptor instead')
const GetStatusRequest$json = {
  '1': 'GetStatusRequest',
};

/// Descriptor for `GetStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatusRequestDescriptor =
    $convert.base64Decode('ChBHZXRTdGF0dXNSZXF1ZXN0');

@$core.Deprecated('Use getStatusResponseDescriptor instead')
const GetStatusResponse$json = {
  '1': 'GetStatusResponse',
  '2': [
    {'1': 'epoch', '3': 1, '4': 1, '5': 4, '10': 'epoch'},
    {
      '1': 'checkpoint_sequence_number',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'checkpointSequenceNumber'
    },
    {'1': 'timestamp_ms', '3': 3, '4': 1, '5': 4, '10': 'timestampMs'},
    {
      '1': 'forked_at_checkpoint',
      '3': 4,
      '4': 1,
      '5': 4,
      '10': 'forkedAtCheckpoint'
    },
  ],
};

/// Descriptor for `GetStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatusResponseDescriptor = $convert.base64Decode(
    'ChFHZXRTdGF0dXNSZXNwb25zZRIUCgVlcG9jaBgBIAEoBFIFZXBvY2gSPAoaY2hlY2twb2ludF'
    '9zZXF1ZW5jZV9udW1iZXIYAiABKARSGGNoZWNrcG9pbnRTZXF1ZW5jZU51bWJlchIhCgx0aW1l'
    'c3RhbXBfbXMYAyABKARSC3RpbWVzdGFtcE1zEjAKFGZvcmtlZF9hdF9jaGVja3BvaW50GAQgAS'
    'gEUhJmb3JrZWRBdENoZWNrcG9pbnQ=');
