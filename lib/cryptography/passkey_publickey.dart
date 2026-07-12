// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/bcs/sui_bcs.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/secp256.dart';
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/utils/hex.dart';
import 'package:sui_dart/utils/sha.dart';

const PASSKEY_PUBLIC_KEY_SIZE = 33;
const PASSKEY_UNCOMPRESSED_PUBLIC_KEY_SIZE = 65;
const PASSKEY_SIGNATURE_SIZE = 64;

/// Fixed DER `SubjectPublicKeyInfo` header for a secp256r1 (P-256) public key,
/// up to and including the `BIT STRING` tag and its leading zero byte. The
/// uncompressed point (`0x04 || x || y`) follows.
final _secp256r1SpkiHeader = Uint8List.fromList([
  0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, //
  0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, //
  0x03, 0x01, 0x07, 0x03, 0x42, 0x00,
]);

/// Parses a DER `SubjectPublicKeyInfo` into the uncompressed point
/// (`0x04 || x || y`), verifying the curve is secp256r1 (P-256).
Uint8List parseDerSPKI(Uint8List der) {
  if (der.length !=
      _secp256r1SpkiHeader.length + PASSKEY_UNCOMPRESSED_PUBLIC_KEY_SIZE) {
    throw ArgumentError('Invalid DER length');
  }
  for (var i = 0; i < _secp256r1SpkiHeader.length; i++) {
    if (der[i] != _secp256r1SpkiHeader[i]) {
      throw ArgumentError('Invalid SPKI header');
    }
  }
  if (der[_secp256r1SpkiHeader.length] != 0x04) {
    throw ArgumentError('Invalid point marker');
  }
  return Uint8List.sublistView(der, _secp256r1SpkiHeader.length);
}

/// A passkey (WebAuthn) public key. The underlying key is a 33-byte compressed
/// secp256r1 point; signatures are produced by an authenticator over the
/// WebAuthn signing payload rather than over the message directly.
class PasskeyPublicKey with PublicKey {
  final Uint8List _data;

  PasskeyPublicKey(Uint8List value) : _data = Uint8List.fromList(value) {
    if (_data.length != PASSKEY_PUBLIC_KEY_SIZE) {
      throw ArgumentError(
        "Invalid public key input. Expected $PASSKEY_PUBLIC_KEY_SIZE bytes, got ${_data.length}",
      );
    }
  }

  factory PasskeyPublicKey.fromString(String publicKeyBase64) {
    return PasskeyPublicKey(base64Decode(publicKeyBase64));
  }

  @override
  Uint8List toRawBytes() => _data;

  @override
  String toBase64() => base64Encode(toRawBytes());

  @override
  String toString() => toBase64();

  @override
  int flag() => SIGNATURE_SCHEME_TO_FLAG.Passkey;

  @override
  String toSuiAddress() {
    final tmp = Uint8List(PASSKEY_PUBLIC_KEY_SIZE + 1);
    tmp[0] = flag();
    tmp.setAll(1, toRawBytes());
    final publicKey = Hex.encode(blake2b(tmp));
    return normalizeSuiAddress(publicKey.substring(0, SUI_ADDRESS_LENGTH * 2));
  }

  @override
  bool verify(Uint8List data, Uint8List signature) {
    try {
      final parsed = parseSerializedPasskeySignature(signature);

      final clientData = jsonDecode(parsed.clientDataJson);
      if (clientData is! Map || clientData['type'] != 'webauthn.get') {
        return false;
      }

      // WebAuthn carries the message to sign in the base64url `challenge` field.
      final challenge = base64Url.decode(
        base64Url.normalize(clientData['challenge'] as String),
      );
      if (!bytesEqual(data, challenge)) return false;

      // The key embedded in the signature must be the one this object represents.
      if (!bytesEqual(toRawBytes(), parsed.publicKey)) return false;

      // The authenticator signs sha256(authenticatorData || sha256(clientDataJson)).
      final clientDataHash = sha256(utf8.encode(parsed.clientDataJson));
      final payload = Uint8List.fromList([
        ...parsed.authenticatorData,
        ...clientDataHash,
      ]);

      return Secp256.fromSecp256r1().verifySignature(
        sha256(payload),
        SignatureData.fromBytes(parsed.signature),
        parsed.publicKey,
      );
    } catch (_) {
      return false;
    }
  }
}

class ParsedPasskeySignature {
  final SignatureScheme signatureScheme;

  /// The full flag-prefixed serialized signature.
  final Uint8List bytes;
  final Uint8List authenticatorData;
  final String clientDataJson;

  /// The inner secp256r1 signature serialized as `flag || sig(64) || pk(33)`.
  final Uint8List userSignature;

  /// The 64-byte raw secp256r1 signature (`r || s`).
  final Uint8List signature;

  /// The 33-byte compressed secp256r1 public key.
  final Uint8List publicKey;

  ParsedPasskeySignature({
    required this.signatureScheme,
    required this.bytes,
    required this.authenticatorData,
    required this.clientDataJson,
    required this.userSignature,
    required this.signature,
    required this.publicKey,
  });
}

/// Parses a serialized passkey signature (`flag 0x06 || BCS(PasskeyAuthenticator)`),
/// from raw bytes or a base64 string, into its component fields.
ParsedPasskeySignature parseSerializedPasskeySignature(dynamic signature) {
  final bytes = signature is String
      ? base64Decode(signature)
      : signature as Uint8List;

  if (bytes.isEmpty || bytes[0] != SIGNATURE_SCHEME_TO_FLAG.Passkey) {
    throw ArgumentError("Invalid signature scheme");
  }

  final dec = SuiBcs.PasskeyAuthenticator.parse(
    Uint8List.sublistView(bytes, 1),
  );
  final userSignature = Uint8List.fromList(
    (dec['userSignature'] as List).cast<int>(),
  );
  const userSignatureSize =
      1 + PASSKEY_SIGNATURE_SIZE + PASSKEY_PUBLIC_KEY_SIZE;
  if (userSignature.length != userSignatureSize ||
      userSignature[0] != SIGNATURE_SCHEME_TO_FLAG.Secp256r1) {
    throw ArgumentError('Invalid passkey user signature');
  }

  return ParsedPasskeySignature(
    signatureScheme: SignatureScheme.Passkey,
    bytes: Uint8List.fromList(bytes),
    authenticatorData: Uint8List.fromList(
      (dec['authenticatorData'] as List).cast<int>(),
    ),
    clientDataJson: dec['clientDataJson'] as String,
    userSignature: userSignature,
    signature: Uint8List.sublistView(
      userSignature,
      1,
      1 + PASSKEY_SIGNATURE_SIZE,
    ),
    publicKey: Uint8List.sublistView(userSignature, 1 + PASSKEY_SIGNATURE_SIZE),
  );
}
