// This is a generated file - do not edit.
//
// Generated from sui/rpc/v2/input.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use inputDescriptor instead')
const Input$json = {
  '1': 'Input',
  '2': [
    {
      '1': 'kind',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.sui.rpc.v2.Input.InputKind',
      '9': 0,
      '10': 'kind',
      '17': true
    },
    {'1': 'pure', '3': 2, '4': 1, '5': 12, '9': 1, '10': 'pure', '17': true},
    {
      '1': 'object_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'objectId',
      '17': true
    },
    {
      '1': 'version',
      '3': 4,
      '4': 1,
      '5': 4,
      '9': 3,
      '10': 'version',
      '17': true
    },
    {'1': 'digest', '3': 5, '4': 1, '5': 9, '9': 4, '10': 'digest', '17': true},
    {
      '1': 'mutable',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 5,
      '10': 'mutable',
      '17': true
    },
    {
      '1': 'literal',
      '3': 1000,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Value',
      '9': 6,
      '10': 'literal',
      '17': true
    },
  ],
  '4': [Input_InputKind$json],
  '8': [
    {'1': '_kind'},
    {'1': '_pure'},
    {'1': '_object_id'},
    {'1': '_version'},
    {'1': '_digest'},
    {'1': '_mutable'},
    {'1': '_literal'},
  ],
};

@$core.Deprecated('Use inputDescriptor instead')
const Input_InputKind$json = {
  '1': 'InputKind',
  '2': [
    {'1': 'INPUT_KIND_UNKNOWN', '2': 0},
    {'1': 'PURE', '2': 1},
    {'1': 'IMMUTABLE_OR_OWNED', '2': 2},
    {'1': 'SHARED', '2': 3},
    {'1': 'RECEIVING', '2': 4},
  ],
};

/// Descriptor for `Input`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputDescriptor = $convert.base64Decode(
    'CgVJbnB1dBI0CgRraW5kGAEgASgOMhsuc3VpLnJwYy52Mi5JbnB1dC5JbnB1dEtpbmRIAFIEa2'
    'luZIgBARIXCgRwdXJlGAIgASgMSAFSBHB1cmWIAQESIAoJb2JqZWN0X2lkGAMgASgJSAJSCG9i'
    'amVjdElkiAEBEh0KB3ZlcnNpb24YBCABKARIA1IHdmVyc2lvbogBARIbCgZkaWdlc3QYBSABKA'
    'lIBFIGZGlnZXN0iAEBEh0KB211dGFibGUYBiABKAhIBVIHbXV0YWJsZYgBARI2CgdsaXRlcmFs'
    'GOgHIAEoCzIWLmdvb2dsZS5wcm90b2J1Zi5WYWx1ZUgGUgdsaXRlcmFsiAEBImAKCUlucHV0S2'
    'luZBIWChJJTlBVVF9LSU5EX1VOS05PV04QABIICgRQVVJFEAESFgoSSU1NVVRBQkxFX09SX09X'
    'TkVEEAISCgoGU0hBUkVEEAMSDQoJUkVDRUlWSU5HEARCBwoFX2tpbmRCBwoFX3B1cmVCDAoKX2'
    '9iamVjdF9pZEIKCghfdmVyc2lvbkIJCgdfZGlnZXN0QgoKCF9tdXRhYmxlQgoKCF9saXRlcmFs');
