// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/cryptography/ed25519_publickey.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/mnemonics.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/utils/ed25519_hd_key.dart' as ed25519_hd_key_lib;

const DEFAULT_ED25519_DERIVATION_PATH = "m/44'/784'/0'/0'/0'";

class Ed25519Keypair with Keypair {
  late ed25519.KeyPair _signingKeypair;

  /// Create an Ed25519 keypair; random if [secretKey] is omitted.
  Ed25519Keypair([Uint8List? secretKey]) {
    if (secretKey != null) {
      final privateKey = ed25519.PrivateKey(secretKey);
      final publicKey = ed25519.PublicKey(privateKey.bytes.sublist(32));
      _signingKeypair = ed25519.KeyPair(privateKey, publicKey);
    } else {
      _signingKeypair = ed25519.generateKey();
    }
  }

  @override
  SignatureScheme getKeyScheme() {
    return SignatureScheme.Ed25519;
  }

  @override
  Uint8List getSecretKey() {
    return Uint8List.fromList(_signingKeypair.privateKey.bytes.sublist(0, 32));
  }

  Uint8List publicKeyBytes() {
    return Uint8List.fromList(_signingKeypair.publicKey.bytes);
  }

  ed25519.KeyPair keyPair() {
    return _signingKeypair;
  }

  /// Create an Ed25519 keypair from a raw secret key; throws on invalid key
  /// unless [skipValidation].
  factory Ed25519Keypair.fromSecretKey(
    Uint8List secretKey, {
    bool skipValidation = false,
  }) {
    if (secretKey.length == 32) {
      return Ed25519Keypair.fromSeed(secretKey);
    }
    if (secretKey.length != 64) {
      throw ArgumentError(
        "Wrong secretKey size. Expected 64 bytes, got ${secretKey.length}.",
      );
    }

    final privateKey = ed25519.PrivateKey(secretKey);
    final publicKey = ed25519.public(privateKey);

    if (!skipValidation) {
      final msg = Uint8List.fromList(utf8.encode('sui validation'));
      final signature = ed25519.sign(privateKey, msg);
      if (!ed25519.verify(publicKey, msg, signature)) {
        throw ArgumentError('provided secretKey is invalid');
      }
    }
    return Ed25519Keypair(secretKey);
  }

  /// Generate a Ed25519 keypair from a 32 byte seed.
  factory Ed25519Keypair.fromSeed(Uint8List seed) {
    if (seed.length != 32) {
      throw ArgumentError(
        "Wrong secretKey size. Expected 32 bytes, got ${seed.length}.",
      );
    }

    final privateKey = ed25519.newKeyFromSeed(seed);
    return Ed25519Keypair(Uint8List.fromList(privateKey.bytes));
  }

  /// Generate a keypair from [mnemonics] string.
  static Ed25519Keypair fromMnemonics(
    String mnemonics, {
    int accountIndex = 0,
    int addressIndex = 0,
    int changeIndex = 0,
  }) {
    String path = "m/44'/784'/$accountIndex'/$changeIndex'/$addressIndex'";
    return deriveKeypair(path, mnemonics);
  }

  /// The public key for this Ed25519 keypair
  @override
  Ed25519PublicKey getPublicKey() {
    return Ed25519PublicKey.fromBytes(_signingKeypair.publicKey.bytes);
  }

  /// Return the signature for the provided data using Ed25519.
  @override
  Uint8List signData(Uint8List data) {
    Uint8List signature = ed25519.sign(_signingKeypair.privateKey, data);
    return signature;
  }

  /// Derive an Ed25519 keypair from mnemonics and a SLIP-0010 hardened [path]
  /// (m/44'/784'/{account}'/{change}'/{address}').
  static Ed25519Keypair deriveKeypair(String path, String mnemonics) {
    if (!isValidHardenedPath(path)) {
      throw ArgumentError('Invalid derivation path');
    }

    final normalizeMnemonics = mnemonics
        .trim()
        .split(r"\s+")
        .map((part) => part.toLowerCase())
        .join(" ");

    if (!isValidMnemonics(mnemonics)) {
      throw ArgumentError('Invalid mnemonics');
    }

    final key = ed25519_hd_key_lib
        .derivePath(path, mnemonicToSeedHex(normalizeMnemonics))
        .key!;
    final pubkey = ed25519_hd_key_lib.getPublicKey(key, false);

    final fullPrivateKey = Uint8List(64);
    fullPrivateKey.setAll(0, key);
    fullPrivateKey.setAll(32, pubkey);

    return Ed25519Keypair(Uint8List.fromList(fullPrivateKey));
  }

  /// Derive an Ed25519 keypair from hex [seedHex] and SLIP-0010 hardened [path]
  /// (defaults to [DEFAULT_ED25519_DERIVATION_PATH]).
  static Ed25519Keypair deriveKeypairFromSeed(String seedHex, [String? path]) {
    path ??= DEFAULT_ED25519_DERIVATION_PATH;
    if (!isValidHardenedPath(path)) {
      throw ArgumentError('Invalid derivation path');
    }

    final key = ed25519_hd_key_lib.derivePath(path, seedHex).key!;
    final pubkey = ed25519_hd_key_lib.getPublicKey(key, false);

    final fullPrivateKey = Uint8List(64);
    fullPrivateKey.setAll(0, key);
    fullPrivateKey.setAll(32, pubkey);

    return Ed25519Keypair(Uint8List.fromList(fullPrivateKey));
  }

  @override
  bool verify(Uint8List data, Uint8List signature, Uint8List publicKey) {
    return ed25519.verify(ed25519.PublicKey(publicKey), data, signature);
  }

  @override
  bool verifySerialized(
    Uint8List message,
    String signature,
    Uint8List publicKey,
  ) {
    final parsed = parseSerializedSignature(signature);
    if (parsed.signatureScheme != SignatureScheme.Ed25519) {
      throw ArgumentError('Invalid signature scheme');
    }

    if (base64Encode(publicKey) != parsed.pubKey!.toBase64()) {
      throw ArgumentError('Signature does not match public key');
    }

    return verify(message, parsed.signature, publicKey);
  }
}
