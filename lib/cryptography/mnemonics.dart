import 'dart:typed_data';

import 'package:bip39_plus/bip39_plus.dart' as bip39;
import 'package:sui_dart/cryptography/helper.dart';

/// [purpose] is 44 for Ed25519, 94 for ML-DSA-65.
bool isValidHardenedPath(String path, [int purpose = 44]) {
  return RegExp("^m/$purpose'/784'/[0-9]+'/[0-9]+'/[0-9]+'+\$").hasMatch(path);
}

/// Parse and validate a path that is compliant to BIP-32 in form m/54'/784'/{account_index}'/{change_index}/{address_index}
/// for Secp256k1 and m/74'/784'/{account_index}'/{change_index}/{address_index} for Secp256r1.
///
/// Note that the purpose for Secp256k1 is registered as 54, to differentiate from Ed25519 with purpose 44.
/// @param path path string (e.g. `m/54'/784'/0'/0/0`).
bool isValidBIP32Path(String path) {
  if (!RegExp(r"^m/(54|74)'/784'/[0-9]+'/[0-9]+/[0-9]+$").hasMatch(path)) {
    return false;
  }
  return true;
}

/// Uses KDF to derive 64 bytes of key data from mnemonic with empty password.
Uint8List mnemonicToSeed(String mnemonics) {
  if (!isValidMnemonics(mnemonics)) {
    throw ArgumentError("Invalid mnemonics");
  }

  return bip39.mnemonicToSeed(mnemonics, passphrase: "");
}

/// Derive the seed in hex format from mnemonic with empty password.
String mnemonicToSeedHex(String mnemonics) {
  if (!isValidMnemonics(mnemonics)) {
    throw ArgumentError("Invalid mnemonics");
  }

  return bip39.mnemonicToSeedHex(mnemonics, passphrase: "");
}

String generateMnemonic({int strength = 128}) {
  return bip39.generateMnemonic(
    strength: strength,
    randomBytes: getRandom().nextBytes,
  );
}

bool isValidMnemonics(String mnemonics) {
  return bip39.validateMnemonic(mnemonics);
}
