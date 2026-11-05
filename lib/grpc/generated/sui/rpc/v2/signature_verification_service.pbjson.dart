// This is a generated file - do not edit.
//
// Generated from sui/rpc/v2/signature_verification_service.proto.

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

@$core.Deprecated('Use verifySignatureRequestDescriptor instead')
const VerifySignatureRequest$json = {
  '1': 'VerifySignatureRequest',
  '2': [
    {
      '1': 'message',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.Bcs',
      '9': 0,
      '10': 'message',
      '17': true
    },
    {
      '1': 'signature',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.sui.rpc.v2.UserSignature',
      '9': 1,
      '10': 'signature',
      '17': true
    },
    {
      '1': 'address',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'address',
      '17': true
    },
    {
      '1': 'jwks',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.sui.rpc.v2.ActiveJwk',
      '10': 'jwks'
    },
    {
      '1': 'check_address_aliases',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 3,
      '10': 'checkAddressAliases',
      '17': true
    },
  ],
  '8': [
    {'1': '_message'},
    {'1': '_signature'},
    {'1': '_address'},
    {'1': '_check_address_aliases'},
  ],
};

/// Descriptor for `VerifySignatureRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifySignatureRequestDescriptor = $convert.base64Decode(
    'ChZWZXJpZnlTaWduYXR1cmVSZXF1ZXN0Ei4KB21lc3NhZ2UYASABKAsyDy5zdWkucnBjLnYyLk'
    'Jjc0gAUgdtZXNzYWdliAEBEjwKCXNpZ25hdHVyZRgCIAEoCzIZLnN1aS5ycGMudjIuVXNlclNp'
    'Z25hdHVyZUgBUglzaWduYXR1cmWIAQESHQoHYWRkcmVzcxgDIAEoCUgCUgdhZGRyZXNziAEBEi'
    'kKBGp3a3MYBCADKAsyFS5zdWkucnBjLnYyLkFjdGl2ZUp3a1IEandrcxI3ChVjaGVja19hZGRy'
    'ZXNzX2FsaWFzZXMYBiABKAhIA1ITY2hlY2tBZGRyZXNzQWxpYXNlc4gBAUIKCghfbWVzc2FnZU'
    'IMCgpfc2lnbmF0dXJlQgoKCF9hZGRyZXNzQhgKFl9jaGVja19hZGRyZXNzX2FsaWFzZXM=');

@$core.Deprecated('Use verifySignatureResponseDescriptor instead')
const VerifySignatureResponse$json = {
  '1': 'VerifySignatureResponse',
  '2': [
    {
      '1': 'is_valid',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'isValid',
      '17': true
    },
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'reason', '17': true},
    {
      '1': 'address_aliases_checked',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 2,
      '10': 'addressAliasesChecked',
      '17': true
    },
  ],
  '8': [
    {'1': '_is_valid'},
    {'1': '_reason'},
    {'1': '_address_aliases_checked'},
  ],
};

/// Descriptor for `VerifySignatureResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifySignatureResponseDescriptor = $convert.base64Decode(
    'ChdWZXJpZnlTaWduYXR1cmVSZXNwb25zZRIeCghpc192YWxpZBgBIAEoCEgAUgdpc1ZhbGlkiA'
    'EBEhsKBnJlYXNvbhgCIAEoCUgBUgZyZWFzb26IAQESOwoXYWRkcmVzc19hbGlhc2VzX2NoZWNr'
    'ZWQYAyABKAhIAlIVYWRkcmVzc0FsaWFzZXNDaGVja2VkiAEBQgsKCV9pc192YWxpZEIJCgdfcm'
    'Vhc29uQhoKGF9hZGRyZXNzX2FsaWFzZXNfY2hlY2tlZA==');
