import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:sui_dart/cryptography/intent.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/signature.dart';

/// May answer later (hardware wallet, remote signer). Implement [getPublicKey],
/// [getKeyScheme] and [signWithIntent]; await every signing method.
abstract class AsyncSigner {
  PublicKey getPublicKey();

  SignatureScheme getKeyScheme();

  /// Serialized signature plus the signed [bytes] in base64.
  FutureOr<SignatureWithBytes> signWithIntent(
    Uint8List bytes,
    IntentScope intent,
  );

  FutureOr<SignatureWithBytes> signTransaction(Uint8List bytes) =>
      signWithIntent(bytes, IntentScope.transactionData);

  /// Returns the raw message as `bytes`, not the BCS form that is signed.
  FutureOr<SignatureWithBytes> signPersonalMessage(Uint8List bytes) {
    final signed = signWithIntent(
      Bcs.vector(Bcs.u8()).serialize(bytes).toBytes(),
      IntentScope.personalMessage,
    );
    SignatureWithBytes raw(SignatureWithBytes s) =>
        SignatureWithBytes(s.signature, base64Encode(bytes));
    return signed is Future<SignatureWithBytes>
        ? signed.then(raw)
        : raw(signed);
  }

  String toSuiAddress() => getPublicKey().toSuiAddress();
}

/// Signs at once; composite signers override [signWithIntent].
abstract class Signer extends AsyncSigner {
  @override
  SignatureWithBytes signWithIntent(Uint8List bytes, IntentScope intent);

  @override
  SignatureWithBytes signTransaction(Uint8List bytes) =>
      signWithIntent(bytes, IntentScope.transactionData);

  @override
  SignatureWithBytes signPersonalMessage(Uint8List bytes) {
    final signed = signWithIntent(
      Bcs.vector(Bcs.u8()).serialize(bytes).toBytes(),
      IntentScope.personalMessage,
    );
    return SignatureWithBytes(signed.signature, base64Encode(bytes));
  }
}
