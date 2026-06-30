import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/cryptography/intent.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/cryptography/signer.dart';
import 'package:sui_dart/multisig/multsig_publickey.dart';

/// A [Signer] combining member keypairs of a [MultiSigPublicKey]. [sign] throws;
/// use [signTransaction] / [signPersonalMessage] to collect and combine member signatures.
class MultiSigSigner extends Signer {
  final MultiSigPublicKey _pubkey;
  final List<Keypair> _signers;

  MultiSigSigner(this._pubkey, [List<Keypair> signers = const []])
      : _signers = signers {
    final uniqueKeys = <String>{};
    var combinedWeight = 0;

    final weights = _pubkey
        .getPublicKeys()
        .map((w) => (weight: w.weight, address: w.publicKey.toSuiAddress()))
        .toList();

    for (final signer in signers) {
      final address = signer.getPublicKey().toSuiAddress();
      if (uniqueKeys.contains(address)) {
        throw ArgumentError("Can't create MultiSigSigner with duplicate signers");
      }
      uniqueKeys.add(address);

      final match = weights.where((w) => w.address == address);
      if (match.isEmpty) {
        throw ArgumentError(
          'Signer $address is not part of the MultiSig public key',
        );
      }
      combinedWeight += match.first.weight;
    }

    if (combinedWeight < _pubkey.getThreshold()) {
      throw ArgumentError('Combined weight of signers is less than threshold');
    }
  }

  @override
  PublicKey getPublicKey() => _pubkey;

  @override
  SignatureScheme getKeyScheme() => SignatureScheme.MultiSig;

  @override
  SignatureWithBytes signWithIntent(Uint8List bytes, IntentScope intent) {
    final signatures = _signers
        .map((signer) => signer.signWithIntent(bytes, intent).signature)
        .toList();
    final combined = _pubkey.combinePartialSignatures(signatures);
    return SignatureWithBytes(combined, base64Encode(bytes));
  }

  /// MultiSig signers cannot sign raw bytes directly.
  Never sign(Uint8List data) {
    throw UnsupportedError(
      'MultiSigSigner does not support signing directly. Use signTransaction '
      'or signPersonalMessage instead',
    );
  }
}
