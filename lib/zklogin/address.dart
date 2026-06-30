import 'dart:convert';
import 'dart:typed_data';

import 'package:bcs_dart/hex.dart';
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/utils/sha.dart';
import 'package:sui_dart/zklogin/utils.dart';

String computeZkLoginAddressFromSeed(
  BigInt addressSeed,
  String iss, {
  bool legacyAddress = false,
}) {
  // Legacy: unpadded big-endian seed; current: 32-byte padded. Not interchangeable.
  final addressSeedBytesBigEndian = legacyAddress
      ? toBigEndianBytes(addressSeed, 32)
      : toPaddedBigEndianBytes(addressSeed, 32);
  final addressParamBytes = utf8.encode(normalizeZkLoginIssuer(iss));
  final tmp = Uint8List(
    2 + addressSeedBytesBigEndian.length + addressParamBytes.length,
  );

  tmp.setAll(0, [SIGNATURE_SCHEME_TO_FLAG.ZkLogin]);
  tmp.setAll(1, [addressParamBytes.length]);
  tmp.setAll(2, addressParamBytes);
  tmp.setAll(2 + addressParamBytes.length, addressSeedBytesBigEndian);

  return normalizeSuiAddress(
    Hex.encode(blake2b(tmp)).substring(0, SUI_ADDRESS_LENGTH * 2),
  );
}
