// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:typed_data';

import 'package:pqcrypto/pqcrypto.dart' show DilithiumParams, MlDsa;
import 'package:sui_dart/cryptography/helper.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/mldsa65_publickey.dart';
import 'package:sui_dart/cryptography/mnemonics.dart';
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/utils/ed25519_hd_key.dart' as hd_key;
import 'package:sui_dart/utils/hex.dart';

const DEFAULT_MLDSA65_DERIVATION_PATH = "m/94'/784'/0'/0'/0'";
const MLDSA65_SLIP10_MASTER_KEY = 'ML-DSA-65 seed';

/// Secret key is the 32-byte FIPS 204 seed; signing is hedged (randomized).
class MLDSA65Keypair with Keypair {
  final Uint8List _seed;
  late final Uint8List _secretKey;
  late final MLDSA65PublicKey _publicKey;

  MLDSA65Keypair._(Uint8List seed) : _seed = Uint8List.fromList(seed) {
    final (pk, sk) = MlDsa.generateKeyPairSeeded(
      DilithiumParams.mlDsa65,
      _seed,
    );
    _publicKey = MLDSA65PublicKey(pk);
    _secretKey = sk;
  }

  factory MLDSA65Keypair() => MLDSA65Keypair._(
    Uint8List.fromList(getRandom().nextBytes(PRIVATE_KEY_SIZE)),
  );

  factory MLDSA65Keypair.fromSecretKey(Uint8List secretKey) {
    if (secretKey.length != PRIVATE_KEY_SIZE) {
      throw ArgumentError(
        "Wrong secretKey size. Expected $PRIVATE_KEY_SIZE bytes, got ${secretKey.length}.",
      );
    }
    return MLDSA65Keypair._(secretKey);
  }

  factory MLDSA65Keypair.fromSeed(Uint8List seed) =>
      MLDSA65Keypair.fromSecretKey(seed);

  /// [path] must be m/94'/784'/{account}'/{change}'/{address}'.
  static MLDSA65Keypair deriveKeypair(String mnemonics, [String? path]) {
    return deriveKeypairFromSeed(mnemonicToSeedHex(mnemonics), path);
  }

  static MLDSA65Keypair deriveKeypairFromSeed(String seedHex, [String? path]) {
    path ??= DEFAULT_MLDSA65_DERIVATION_PATH;
    if (!isValidHardenedPath(path, 94)) {
      throw ArgumentError('Invalid derivation path');
    }
    final node = hd_key.derivePath(
      path,
      Hex.trimHex(seedHex),
      masterKey: MLDSA65_SLIP10_MASTER_KEY,
    );
    return MLDSA65Keypair._(node.key!);
  }

  static MLDSA65Keypair fromMnemonics(
    String mnemonics, {
    int accountIndex = 0,
    int addressIndex = 0,
    int changeIndex = 0,
  }) => deriveKeypair(
    mnemonics,
    "m/94'/784'/$accountIndex'/$changeIndex'/$addressIndex'",
  );

  @override
  SignatureScheme getKeyScheme() => SignatureScheme.MLDSA65;

  @override
  Uint8List getSecretKey() => Uint8List.fromList(_seed);

  @override
  MLDSA65PublicKey getPublicKey() => _publicKey;

  @override
  Uint8List signData(Uint8List data) =>
      MlDsa.sign(_secretKey, data, DilithiumParams.mlDsa65);

  @override
  bool verify(Uint8List data, Uint8List signature, Uint8List publicKey) =>
      MLDSA65PublicKey(publicKey).verify(data, signature);

  @override
  bool verifySerialized(
    Uint8List message,
    String signature,
    Uint8List publicKey,
  ) => MLDSA65PublicKey(publicKey).verify(message, base64Decode(signature));
}
