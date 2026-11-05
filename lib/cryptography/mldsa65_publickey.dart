// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:typed_data';

import 'package:pqcrypto/pqcrypto.dart' show DilithiumParams, MlDsa;
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/utils/hex.dart';
import 'package:sui_dart/utils/sha.dart';

const MLDSA65_PUBLIC_KEY_SIZE = 1952;
const MLDSA65_SIGNATURE_SIZE = 3309;

class MLDSA65PublicKey with PublicKey {
  final Uint8List _data;

  MLDSA65PublicKey(List<int> bytes) : _data = Uint8List.fromList(bytes) {
    if (_data.length != MLDSA65_PUBLIC_KEY_SIZE) {
      throw ArgumentError(
        "Invalid public key input. Expected $MLDSA65_PUBLIC_KEY_SIZE bytes, got ${_data.length}",
      );
    }
  }

  factory MLDSA65PublicKey.fromString(String publicKeyBase64) =>
      MLDSA65PublicKey(base64Decode(publicKeyBase64));

  @override
  Uint8List toRawBytes() => _data;

  @override
  String toBase64() => base64Encode(_data);

  @override
  String toString() => toBase64();

  @override
  int flag() => SIGNATURE_SCHEME_TO_FLAG.MLDSA65;

  @override
  String toSuiAddress() =>
      normalizeSuiAddress(Hex.encode(blake2b(toSuiBytes())));

  /// Pure ML-DSA-65 with an empty context; [signature] is raw or serialized.
  @override
  bool verify(Uint8List data, Uint8List signature) {
    if (signature.length ==
        1 + MLDSA65_SIGNATURE_SIZE + MLDSA65_PUBLIC_KEY_SIZE) {
      final parsed = parseSerializedSignature(base64Encode(signature));
      if (parsed.signatureScheme != SignatureScheme.MLDSA65) {
        throw ArgumentError('Invalid signature scheme');
      }
      if (!bytesEqual(_data, parsed.pubKey!.toRawBytes())) {
        throw ArgumentError('Signature does not match public key');
      }
      signature = parsed.signature;
    }
    if (signature.length != MLDSA65_SIGNATURE_SIZE) return false;
    return MlDsa.verify(_data, data, signature, DilithiumParams.mlDsa65);
  }
}
