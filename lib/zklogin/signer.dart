import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/cryptography/intent.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/cryptography/signer.dart';
import 'package:sui_dart/zklogin/jwt_utils.dart';
import 'package:sui_dart/zklogin/publickey.dart';
import 'package:sui_dart/zklogin/signature.dart';
import 'package:sui_dart/zklogin/types.dart';

/// A transport- and provider-agnostic zkLogin signer.
///
/// Wraps an ephemeral [Keypair], turning each ephemeral signature into a zkLogin
/// signature via [inputs] and [maxEpoch]. [sign] throws — use
/// [signTransaction] / [signPersonalMessage].
class ZkLoginSigner extends Signer {
  final Keypair ephemeralSigner;
  final int maxEpoch;
  final ZkLoginSignatureInputs inputs;
  final bool legacyAddress;

  ZkLoginPublicIdentifier? _publicKey;

  /// Creates a zkLogin signer.
  ///
  /// [legacyAddress] selects legacy vs. current derivation. If [address] is
  /// given, the derived address is validated against it and throws on mismatch.
  ZkLoginSigner({
    required this.ephemeralSigner,
    required this.maxEpoch,
    required this.inputs,
    required this.legacyAddress,
    String? address,
  }) {
    if (address != null) {
      final derived = _derivePublicKey().toSuiAddress();
      if (derived != address) {
        throw ArgumentError(
          'zkLogin proof does not match the provided address (derived '
          '$derived, expected $address) — check the `legacyAddress` flag',
        );
      }
    }
  }

  ZkLoginPublicIdentifier _derivePublicKey() {
    return _publicKey ??= toZkLoginPublicIdentifier(
      BigInt.parse(inputs.addressSeed),
      extractClaimValue<String>(inputs.issBase64Details, 'iss'),
      legacyAddress: legacyAddress,
    );
  }

  @override
  PublicKey getPublicKey() => _derivePublicKey();

  @override
  SignatureScheme getKeyScheme() => SignatureScheme.ZkLogin;

  @override
  SignatureWithBytes signWithIntent(Uint8List bytes, IntentScope intent) {
    final ephemeral = ephemeralSigner.signWithIntent(bytes, intent);
    final signature = getZkLoginSignature(
      ZkLoginSignature(
        inputs: inputs,
        maxEpoch: maxEpoch,
        userSignature: base64Decode(ephemeral.signature),
      ),
    );
    return SignatureWithBytes(signature, ephemeral.bytes);
  }

  /// zkLogin signers cannot sign raw bytes directly.
  Never sign(Uint8List data) {
    throw UnsupportedError(
      'ZkLoginSigner does not support signing directly. Use signTransaction '
      'or signPersonalMessage instead',
    );
  }
}
