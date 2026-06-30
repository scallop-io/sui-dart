import "dart:typed_data";
import "package:sui_dart/cryptography/keypair.dart";
import "package:sui_dart/utils/hex.dart";

/// Flag-prefixed base64 ephemeral public key expected by the proving service.
String getExtendedEphemeralPublicKey(PublicKey publicKey) {
  return publicKey.toSuiPublicKey();
}

int findFirstNonZeroIndex(Uint8List bytes) {
  for (int i = 0; i < bytes.length; i++) {
    if (bytes[i] != 0) {
      return i;
    }
  }
  return -1;
}

/// Big-endian bytes of [num], left-padded with zeros to [width].
Uint8List toPaddedBigEndianBytes(BigInt num, int width) {
  String hex = num.toRadixString(16);
  String paddedHex = hex.padLeft(width * 2, '0');
  return Hex.decode(paddedHex.substring(paddedHex.length - width * 2));
}

/// Big-endian bytes of [num] with leading zeros stripped.
Uint8List toBigEndianBytes(BigInt num, int width) {
  Uint8List bytes = toPaddedBigEndianBytes(num, width);

  int firstNonZeroIndex = findFirstNonZeroIndex(bytes);

  if (firstNonZeroIndex == -1) {
    return Uint8List.fromList([0]);
  }

  return bytes.sublist(firstNonZeroIndex);
}

/// Normalize a zkLogin issuer: `accounts.google.com` -> `https://accounts.google.com`.
String normalizeZkLoginIssuer(String iss) {
  if (iss == 'accounts.google.com') {
    return 'https://accounts.google.com';
  }
  return iss;
}
