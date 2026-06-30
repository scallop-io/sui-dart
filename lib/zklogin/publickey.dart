import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/cryptography/helper.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/utils/hex.dart';
import 'package:sui_dart/utils/sha.dart';
import 'package:sui_dart/zklogin/jwt_utils.dart';
import 'package:sui_dart/zklogin/types.dart';
import 'package:sui_dart/zklogin/utils.dart';

/// Re-encode `iss_len || iss || seed` with the seed in legacy (unpadded) or
/// current (32-byte padded) big-endian form.
Uint8List _normalizeZkLoginPublicKeyBytes(Uint8List bytes, bool legacyAddress) {
  final issByteLength = bytes[0] + 1;
  final addressSeed = decodeBigIntToUnsigned(
    Uint8List.sublistView(bytes, issByteLength),
  );
  final seedBytes = legacyAddress
      ? toBigEndianBytes(addressSeed, 32)
      : toPaddedBigEndianBytes(addressSeed, 32);
  final data = Uint8List(issByteLength + seedBytes.length);
  data.setRange(0, issByteLength, bytes);
  data.setRange(issByteLength, issByteLength + seedBytes.length, seedBytes);
  return data;
}

class ZkLoginPublicIdentifier with PublicKey {
  late Uint8List _data;
  late bool _legacyAddress;

  ZkLoginPublicIdentifier._(Uint8List value) {
    _data = value;
    // Legacy stored the seed unpadded, so length != canonical `iss_len + 1 + 32`.
    _legacyAddress = _data.length != _data[0] + 1 + 32;
    if (_legacyAddress) {
      _data = _normalizeZkLoginPublicKeyBytes(_data, false);
    }
  }

  factory ZkLoginPublicIdentifier.fromBytes(
    Uint8List bytes, {
    String? address,
    bool? legacyAddress,
  }) {
    ZkLoginPublicIdentifier publicKey;

    if (legacyAddress == true) {
      publicKey = ZkLoginPublicIdentifier._(
        _normalizeZkLoginPublicKeyBytes(bytes, true),
      );
    } else if (legacyAddress == false) {
      publicKey = ZkLoginPublicIdentifier._(
        _normalizeZkLoginPublicKeyBytes(bytes, false),
      );
    } else if (address != null) {
      publicKey = ZkLoginPublicIdentifier._(
        _normalizeZkLoginPublicKeyBytes(bytes, false),
      );

      if (publicKey.toSuiAddress() != address) {
        publicKey = ZkLoginPublicIdentifier._(
          _normalizeZkLoginPublicKeyBytes(bytes, true),
        );
      }
    } else {
      publicKey = ZkLoginPublicIdentifier._(bytes);
    }

    if (address != null && publicKey.toSuiAddress() != address) {
      throw ArgumentError('Public key bytes do not match the provided address');
    }

    return publicKey;
  }

  /// Derive the identifier producing [address] from a proof, trying legacy then current.
  factory ZkLoginPublicIdentifier.fromProof(
    String address,
    ZkLoginSignatureInputs proof,
  ) {
    final iss = extractClaimValue<String>(proof.issBase64Details, 'iss');

    final legacyPublicKey = toZkLoginPublicIdentifier(
      BigInt.parse(proof.addressSeed),
      iss,
      legacyAddress: true,
    );

    if (legacyPublicKey.toSuiAddress() == address) {
      return legacyPublicKey;
    }

    final publicKey = toZkLoginPublicIdentifier(
      BigInt.parse(proof.addressSeed),
      iss,
      legacyAddress: false,
    );

    if (publicKey.toSuiAddress() != address) {
      throw ArgumentError('Proof does not match address');
    }

    return publicKey;
  }

  /// Whether this identifier resolves to the deprecated legacy address.
  bool get legacyAddress => _legacyAddress;

  @override
  Uint8List toRawBytes() {
    return _data;
  }

  @override
  int flag() {
    return SIGNATURE_SCHEME_TO_FLAG.ZkLogin;
  }

  @override
  String toBase64() {
    return base64Encode(toRawBytes());
  }

  String _addressFromBytes(Uint8List rawBytes) {
    final tmp = Uint8List(rawBytes.length + 1);
    tmp[0] = flag();
    tmp.setRange(1, tmp.length, rawBytes);
    final publicKey = Hex.encode(blake2b(tmp));
    return normalizeSuiAddress(publicKey.substring(0, SUI_ADDRESS_LENGTH * 2));
  }

  String _baseToSuiAddress() => _addressFromBytes(_data);

  String _toLegacyAddress() =>
      _addressFromBytes(_normalizeZkLoginPublicKeyBytes(_data, true));

  @override
  String toSuiAddress() {
    if (_legacyAddress) {
      return _toLegacyAddress();
    }
    return _baseToSuiAddress();
  }

  @override
  bool verifyAddress(String address) {
    return address == _baseToSuiAddress() || address == _toLegacyAddress();
  }

  /// Verifies the signature against the provided PersonalMessage.
  @override
  bool verify(Uint8List data, Uint8List signature) {
    throw Exception('does not support');
  }
}

ZkLoginPublicIdentifier toZkLoginPublicIdentifier(
  BigInt addressSeed,
  String iss, {
  bool legacyAddress = false,
}) {
  // Layout: iss_len || iss_bytes || padded_32_byte_address_seed.
  final addressSeedBytesBigEndian = legacyAddress
      ? toBigEndianBytes(addressSeed, 32)
      : toPaddedBigEndianBytes(addressSeed, 32);
  final issBytes = utf8.encode(normalizeZkLoginIssuer(iss));
  final tmp = Uint8List(1 + issBytes.length + addressSeedBytesBigEndian.length);
  tmp[0] = issBytes.length;
  tmp.setAll(1, issBytes);
  tmp.setAll(1 + issBytes.length, addressSeedBytesBigEndian);
  return ZkLoginPublicIdentifier._(tmp);
}
