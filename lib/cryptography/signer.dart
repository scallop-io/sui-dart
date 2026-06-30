import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:sui_dart/cryptography/intent.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/signature.dart';

/// A transport-agnostic signer. Keypairs sign directly; composite signers
/// (e.g. [MultiSigSigner], [ZkLoginSigner]) override [signWithIntent], through
/// which every signing method funnels.
abstract class Signer {
  /// The public key for this signer.
  PublicKey getPublicKey();

  /// The signature scheme of this signer.
  SignatureScheme getKeyScheme();

  /// Sign [bytes] with the given intent; returns serialized signature and base64 bytes.
  SignatureWithBytes signWithIntent(Uint8List bytes, IntentScope intent);

  /// Sign transaction [bytes].
  SignatureWithBytes signTransaction(Uint8List bytes) {
    return signWithIntent(bytes, IntentScope.transactionData);
  }

  /// Sign a personal message.
  SignatureWithBytes signPersonalMessage(Uint8List bytes) {
    return signWithIntent(
      Bcs.vector(Bcs.u8()).serialize(bytes).toBytes(),
      IntentScope.personalMessage,
    );
  }

  /// The Sui address associated with this signer.
  String toSuiAddress() => getPublicKey().toSuiAddress();
}
