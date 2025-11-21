// This is a generated file - do not edit.
//
// Generated from sui/rpc/v2/transaction_execution_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use executeTransactionRequestDescriptor instead')
const ExecuteTransactionRequest$json = {
  '1': 'ExecuteTransactionRequest',
  '2': [
    {
      '1': 'transaction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.Transaction',
      '9': 0,
      '10': 'transaction',
      '17': true
    },
    {
      '1': 'signatures',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.sui.rpc.v2.UserSignature',
      '10': 'signatures'
    },
    {
      '1': 'read_mask',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '9': 1,
      '10': 'readMask',
      '17': true
    },
  ],
  '8': [
    {'1': '_transaction'},
    {'1': '_read_mask'},
  ],
};

/// Descriptor for `ExecuteTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executeTransactionRequestDescriptor = $convert.base64Decode(
    'ChlFeGVjdXRlVHJhbnNhY3Rpb25SZXF1ZXN0Ej4KC3RyYW5zYWN0aW9uGAEgASgLMhcuc3VpLn'
    'JwYy52Mi5UcmFuc2FjdGlvbkgAUgt0cmFuc2FjdGlvbogBARI5CgpzaWduYXR1cmVzGAIgAygL'
    'Mhkuc3VpLnJwYy52Mi5Vc2VyU2lnbmF0dXJlUgpzaWduYXR1cmVzEjwKCXJlYWRfbWFzaxgDIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5GaWVsZE1hc2tIAVIIcmVhZE1hc2uIAQFCDgoMX3RyYW5z'
    'YWN0aW9uQgwKCl9yZWFkX21hc2s=');

@$core.Deprecated('Use executeTransactionResponseDescriptor instead')
const ExecuteTransactionResponse$json = {
  '1': 'ExecuteTransactionResponse',
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
  ],
  '8': [
    {'1': '_transaction'},
  ],
};

/// Descriptor for `ExecuteTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executeTransactionResponseDescriptor =
    $convert.base64Decode(
        'ChpFeGVjdXRlVHJhbnNhY3Rpb25SZXNwb25zZRJGCgt0cmFuc2FjdGlvbhgBIAEoCzIfLnN1aS'
        '5ycGMudjIuRXhlY3V0ZWRUcmFuc2FjdGlvbkgAUgt0cmFuc2FjdGlvbogBAUIOCgxfdHJhbnNh'
        'Y3Rpb24=');

@$core.Deprecated('Use simulateTransactionRequestDescriptor instead')
const SimulateTransactionRequest$json = {
  '1': 'SimulateTransactionRequest',
  '2': [
    {
      '1': 'transaction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.Transaction',
      '9': 0,
      '10': 'transaction',
      '17': true
    },
    {
      '1': 'read_mask',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '9': 1,
      '10': 'readMask',
      '17': true
    },
    {
      '1': 'checks',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.sui.rpc.v2.SimulateTransactionRequest.TransactionChecks',
      '9': 2,
      '10': 'checks',
      '17': true
    },
    {
      '1': 'do_gas_selection',
      '3': 4,
      '4': 1,
      '5': 8,
      '9': 3,
      '10': 'doGasSelection',
      '17': true
    },
  ],
  '4': [SimulateTransactionRequest_TransactionChecks$json],
  '8': [
    {'1': '_transaction'},
    {'1': '_read_mask'},
    {'1': '_checks'},
    {'1': '_do_gas_selection'},
  ],
};

@$core.Deprecated('Use simulateTransactionRequestDescriptor instead')
const SimulateTransactionRequest_TransactionChecks$json = {
  '1': 'TransactionChecks',
  '2': [
    {'1': 'ENABLED', '2': 0},
    {'1': 'DISABLED', '2': 1},
  ],
};

/// Descriptor for `SimulateTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simulateTransactionRequestDescriptor = $convert.base64Decode(
    'ChpTaW11bGF0ZVRyYW5zYWN0aW9uUmVxdWVzdBI+Cgt0cmFuc2FjdGlvbhgBIAEoCzIXLnN1aS'
    '5ycGMudjIuVHJhbnNhY3Rpb25IAFILdHJhbnNhY3Rpb26IAQESPAoJcmVhZF9tYXNrGAIgASgL'
    'MhouZ29vZ2xlLnByb3RvYnVmLkZpZWxkTWFza0gBUghyZWFkTWFza4gBARJVCgZjaGVja3MYAy'
    'ABKA4yOC5zdWkucnBjLnYyLlNpbXVsYXRlVHJhbnNhY3Rpb25SZXF1ZXN0LlRyYW5zYWN0aW9u'
    'Q2hlY2tzSAJSBmNoZWNrc4gBARItChBkb19nYXNfc2VsZWN0aW9uGAQgASgISANSDmRvR2FzU2'
    'VsZWN0aW9uiAEBIi4KEVRyYW5zYWN0aW9uQ2hlY2tzEgsKB0VOQUJMRUQQABIMCghESVNBQkxF'
    'RBABQg4KDF90cmFuc2FjdGlvbkIMCgpfcmVhZF9tYXNrQgkKB19jaGVja3NCEwoRX2RvX2dhc1'
    '9zZWxlY3Rpb24=');

@$core.Deprecated('Use simulateTransactionResponseDescriptor instead')
const SimulateTransactionResponse$json = {
  '1': 'SimulateTransactionResponse',
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
      '1': 'command_outputs',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.sui.rpc.v2.CommandResult',
      '10': 'commandOutputs'
    },
  ],
  '8': [
    {'1': '_transaction'},
  ],
};

/// Descriptor for `SimulateTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simulateTransactionResponseDescriptor = $convert.base64Decode(
    'ChtTaW11bGF0ZVRyYW5zYWN0aW9uUmVzcG9uc2USRgoLdHJhbnNhY3Rpb24YASABKAsyHy5zdW'
    'kucnBjLnYyLkV4ZWN1dGVkVHJhbnNhY3Rpb25IAFILdHJhbnNhY3Rpb26IAQESQgoPY29tbWFu'
    'ZF9vdXRwdXRzGAIgAygLMhkuc3VpLnJwYy52Mi5Db21tYW5kUmVzdWx0Ug5jb21tYW5kT3V0cH'
    'V0c0IOCgxfdHJhbnNhY3Rpb24=');

@$core.Deprecated('Use commandResultDescriptor instead')
const CommandResult$json = {
  '1': 'CommandResult',
  '2': [
    {
      '1': 'return_values',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.sui.rpc.v2.CommandOutput',
      '10': 'returnValues'
    },
    {
      '1': 'mutated_by_ref',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.sui.rpc.v2.CommandOutput',
      '10': 'mutatedByRef'
    },
  ],
};

/// Descriptor for `CommandResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandResultDescriptor = $convert.base64Decode(
    'Cg1Db21tYW5kUmVzdWx0Ej4KDXJldHVybl92YWx1ZXMYASADKAsyGS5zdWkucnBjLnYyLkNvbW'
    '1hbmRPdXRwdXRSDHJldHVyblZhbHVlcxI/Cg5tdXRhdGVkX2J5X3JlZhgCIAMoCzIZLnN1aS5y'
    'cGMudjIuQ29tbWFuZE91dHB1dFIMbXV0YXRlZEJ5UmVm');

@$core.Deprecated('Use commandOutputDescriptor instead')
const CommandOutput$json = {
  '1': 'CommandOutput',
  '2': [
    {
      '1': 'argument',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.Argument',
      '9': 0,
      '10': 'argument',
      '17': true
    },
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.Bcs',
      '9': 1,
      '10': 'value',
      '17': true
    },
    {
      '1': 'json',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Value',
      '9': 2,
      '10': 'json',
      '17': true
    },
  ],
  '8': [
    {'1': '_argument'},
    {'1': '_value'},
    {'1': '_json'},
  ],
};

/// Descriptor for `CommandOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandOutputDescriptor = $convert.base64Decode(
    'Cg1Db21tYW5kT3V0cHV0EjUKCGFyZ3VtZW50GAEgASgLMhQuc3VpLnJwYy52Mi5Bcmd1bWVudE'
    'gAUghhcmd1bWVudIgBARIqCgV2YWx1ZRgCIAEoCzIPLnN1aS5ycGMudjIuQmNzSAFSBXZhbHVl'
    'iAEBEi8KBGpzb24YAyABKAsyFi5nb29nbGUucHJvdG9idWYuVmFsdWVIAlIEanNvbogBAUILCg'
    'lfYXJndW1lbnRCCAoGX3ZhbHVlQgcKBV9qc29u');
