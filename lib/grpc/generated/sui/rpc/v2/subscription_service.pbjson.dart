// This is a generated file - do not edit.
//
// Generated from sui/rpc/v2/subscription_service.proto.

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

@$core.Deprecated('Use subscribeCheckpointsRequestDescriptor instead')
const SubscribeCheckpointsRequest$json = {
  '1': 'SubscribeCheckpointsRequest',
  '2': [
    {
      '1': 'read_mask',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '9': 0,
      '10': 'readMask',
      '17': true
    },
    {
      '1': 'filter',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.TransactionFilter',
      '9': 1,
      '10': 'filter',
      '17': true
    },
  ],
  '8': [
    {'1': '_read_mask'},
    {'1': '_filter'},
  ],
};

/// Descriptor for `SubscribeCheckpointsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeCheckpointsRequestDescriptor = $convert.base64Decode(
    'ChtTdWJzY3JpYmVDaGVja3BvaW50c1JlcXVlc3QSPAoJcmVhZF9tYXNrGAEgASgLMhouZ29vZ2'
    'xlLnByb3RvYnVmLkZpZWxkTWFza0gAUghyZWFkTWFza4gBARI6CgZmaWx0ZXIYAiABKAsyHS5z'
    'dWkucnBjLnYyLlRyYW5zYWN0aW9uRmlsdGVySAFSBmZpbHRlcogBAUIMCgpfcmVhZF9tYXNrQg'
    'kKB19maWx0ZXI=');

@$core.Deprecated('Use subscribeCheckpointsResponseDescriptor instead')
const SubscribeCheckpointsResponse$json = {
  '1': 'SubscribeCheckpointsResponse',
  '2': [
    {'1': 'cursor', '3': 1, '4': 1, '5': 4, '9': 0, '10': 'cursor', '17': true},
    {
      '1': 'checkpoint',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.Checkpoint',
      '9': 1,
      '10': 'checkpoint',
      '17': true
    },
  ],
  '8': [
    {'1': '_cursor'},
    {'1': '_checkpoint'},
  ],
};

/// Descriptor for `SubscribeCheckpointsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeCheckpointsResponseDescriptor =
    $convert.base64Decode(
        'ChxTdWJzY3JpYmVDaGVja3BvaW50c1Jlc3BvbnNlEhsKBmN1cnNvchgBIAEoBEgAUgZjdXJzb3'
        'KIAQESOwoKY2hlY2twb2ludBgCIAEoCzIWLnN1aS5ycGMudjIuQ2hlY2twb2ludEgBUgpjaGVj'
        'a3BvaW50iAEBQgkKB19jdXJzb3JCDQoLX2NoZWNrcG9pbnQ=');

@$core.Deprecated('Use subscribeTransactionsRequestDescriptor instead')
const SubscribeTransactionsRequest$json = {
  '1': 'SubscribeTransactionsRequest',
  '2': [
    {
      '1': 'read_mask',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '9': 0,
      '10': 'readMask',
      '17': true
    },
    {
      '1': 'filter',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.TransactionFilter',
      '9': 1,
      '10': 'filter',
      '17': true
    },
  ],
  '8': [
    {'1': '_read_mask'},
    {'1': '_filter'},
  ],
};

/// Descriptor for `SubscribeTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeTransactionsRequestDescriptor = $convert.base64Decode(
    'ChxTdWJzY3JpYmVUcmFuc2FjdGlvbnNSZXF1ZXN0EjwKCXJlYWRfbWFzaxgBIAEoCzIaLmdvb2'
    'dsZS5wcm90b2J1Zi5GaWVsZE1hc2tIAFIIcmVhZE1hc2uIAQESOgoGZmlsdGVyGAIgASgLMh0u'
    'c3VpLnJwYy52Mi5UcmFuc2FjdGlvbkZpbHRlckgBUgZmaWx0ZXKIAQFCDAoKX3JlYWRfbWFza0'
    'IJCgdfZmlsdGVy');

@$core.Deprecated('Use subscribeTransactionsResponseDescriptor instead')
const SubscribeTransactionsResponse$json = {
  '1': 'SubscribeTransactionsResponse',
  '2': [
    {
      '1': 'transaction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.ExecutedTransaction',
      '9': 0,
      '10': 'transaction',
      '17': true
    },
    {
      '1': 'watermark',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.Watermark',
      '9': 1,
      '10': 'watermark',
      '17': true
    },
  ],
  '8': [
    {'1': '_transaction'},
    {'1': '_watermark'},
  ],
};

/// Descriptor for `SubscribeTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeTransactionsResponseDescriptor = $convert.base64Decode(
    'Ch1TdWJzY3JpYmVUcmFuc2FjdGlvbnNSZXNwb25zZRJGCgt0cmFuc2FjdGlvbhgBIAEoCzIfLn'
    'N1aS5ycGMudjIuRXhlY3V0ZWRUcmFuc2FjdGlvbkgAUgt0cmFuc2FjdGlvbogBARI4Cgl3YXRl'
    'cm1hcmsYAiABKAsyFS5zdWkucnBjLnYyLldhdGVybWFya0gBUgl3YXRlcm1hcmuIAQFCDgoMX3'
    'RyYW5zYWN0aW9uQgwKCl93YXRlcm1hcms=');

@$core.Deprecated('Use subscribeEventsRequestDescriptor instead')
const SubscribeEventsRequest$json = {
  '1': 'SubscribeEventsRequest',
  '2': [
    {
      '1': 'read_mask',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '9': 0,
      '10': 'readMask',
      '17': true
    },
    {
      '1': 'filter',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.EventFilter',
      '9': 1,
      '10': 'filter',
      '17': true
    },
  ],
  '8': [
    {'1': '_read_mask'},
    {'1': '_filter'},
  ],
};

/// Descriptor for `SubscribeEventsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeEventsRequestDescriptor = $convert.base64Decode(
    'ChZTdWJzY3JpYmVFdmVudHNSZXF1ZXN0EjwKCXJlYWRfbWFzaxgBIAEoCzIaLmdvb2dsZS5wcm'
    '90b2J1Zi5GaWVsZE1hc2tIAFIIcmVhZE1hc2uIAQESNAoGZmlsdGVyGAIgASgLMhcuc3VpLnJw'
    'Yy52Mi5FdmVudEZpbHRlckgBUgZmaWx0ZXKIAQFCDAoKX3JlYWRfbWFza0IJCgdfZmlsdGVy');

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse$json = {
  '1': 'SubscribeEventsResponse',
  '2': [
    {
      '1': 'event',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.Event',
      '9': 0,
      '10': 'event',
      '17': true
    },
    {
      '1': 'watermark',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.Watermark',
      '9': 1,
      '10': 'watermark',
      '17': true
    },
  ],
  '8': [
    {'1': '_event'},
    {'1': '_watermark'},
  ],
};

/// Descriptor for `SubscribeEventsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeEventsResponseDescriptor = $convert.base64Decode(
    'ChdTdWJzY3JpYmVFdmVudHNSZXNwb25zZRIsCgVldmVudBgBIAEoCzIRLnN1aS5ycGMudjIuRX'
    'ZlbnRIAFIFZXZlbnSIAQESOAoJd2F0ZXJtYXJrGAIgASgLMhUuc3VpLnJwYy52Mi5XYXRlcm1h'
    'cmtIAVIJd2F0ZXJtYXJriAEBQggKBl9ldmVudEIMCgpfd2F0ZXJtYXJr');
