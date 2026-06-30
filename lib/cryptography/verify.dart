import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/multisig/multsig_publickey.dart';
import 'package:sui_dart/zklogin/publickey.dart';

/// Reconstruct the [PublicKey] from a serialized (base64) signature, dispatching
/// on its embedded scheme flag.
PublicKey _publicKeyFromSignature(String signature) {
  final parsed = parseSerializedSignature(signature);
  switch (parsed.signatureScheme) {
    case SignatureScheme.MultiSig:
      return MultiSigPublicKey(parsed.multisig!.multisigPK);
    case SignatureScheme.ZkLogin:
      final zk = parsed.zkLogin!;
      return toZkLoginPublicIdentifier(
        zk["addressSeed"],
        zk["iss"],
        legacyAddress: false,
      );
    default:
      return parsed.pubKey!;
  }
}

/// Decode a flag-prefixed public key (base64 or raw bytes); inverse of
/// [PublicKey.toSuiPublicKey].
PublicKey publicKeyFromSuiBytes(dynamic publicKey, {String? address}) {
  final bytes = publicKey is String
      ? base64Decode(publicKey)
      : publicKey as Uint8List;
  final scheme = SIGNATURE_SCHEME_TO_FLAG.flagToScheme(bytes[0]);
  return publicKeyFromRawBytes(
    scheme.name,
    Uint8List.sublistView(bytes, 1),
    address: address,
  );
}

/// Whether [signature] is valid over [bytes] (and matches [address] if given).
/// Returns `false` instead of throwing on malformed/invalid signatures.
bool isValidSignature(Uint8List bytes, String signature, {String? address}) {
  try {
    final publicKey = _publicKeyFromSignature(signature);
    if (!publicKey.verify(bytes, base64Decode(signature))) return false;
    return address == null ? true : publicKey.verifyAddress(address);
  } catch (_) {
    return false;
  }
}

/// Like [isValidSignature], for a personal message.
bool isValidPersonalMessageSignature(
  Uint8List message,
  String signature, {
  String? address,
}) {
  try {
    final publicKey = _publicKeyFromSignature(signature);
    if (!publicKey.verifyPersonalMessage(message, signature)) return false;
    return address == null ? true : publicKey.verifyAddress(address);
  } catch (_) {
    return false;
  }
}

/// Like [isValidSignature], for transaction bytes.
bool isValidTransactionSignature(
  Uint8List transaction,
  String signature, {
  String? address,
}) {
  try {
    final publicKey = _publicKeyFromSignature(signature);
    if (!publicKey.verifyTransaction(transaction, signature)) return false;
    return address == null ? true : publicKey.verifyAddress(address);
  } catch (_) {
    return false;
  }
}

/// Verify [signature] over [bytes], returning the recovered [PublicKey].
/// Throws if invalid or mismatched with [address].
PublicKey verifySignature(
  Uint8List bytes,
  String signature, {
  String? address,
}) {
  final publicKey = _publicKeyFromSignature(signature);
  if (!isValidSignature(bytes, signature)) {
    throw ArgumentError('Signature is not valid for the provided data');
  }
  if (address != null && !publicKey.verifyAddress(address)) {
    throw ArgumentError('Signature is not valid for the provided address');
  }
  return publicKey;
}

/// Like [verifySignature], for a personal message.
PublicKey verifyPersonalMessageSignature(
  Uint8List message,
  String signature, {
  String? address,
}) {
  final publicKey = _publicKeyFromSignature(signature);
  if (!isValidPersonalMessageSignature(message, signature)) {
    throw ArgumentError('Signature is not valid for the provided message');
  }
  if (address != null && !publicKey.verifyAddress(address)) {
    throw ArgumentError('Signature is not valid for the provided address');
  }
  return publicKey;
}

/// Like [verifySignature], for transaction bytes.
PublicKey verifyTransactionSignature(
  Uint8List transaction,
  String signature, {
  String? address,
}) {
  final publicKey = _publicKeyFromSignature(signature);
  if (!isValidTransactionSignature(transaction, signature)) {
    throw ArgumentError('Signature is not valid for the provided Transaction');
  }
  if (address != null && !publicKey.verifyAddress(address)) {
    throw ArgumentError('Signature is not valid for the provided address');
  }
  return publicKey;
}
