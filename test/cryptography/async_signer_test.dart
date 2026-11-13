import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bcs_dart/utils.dart';
import 'package:sui_dart/sui.dart';
import 'package:test/test.dart';

class _SlowSigner extends AsyncSigner {
  _SlowSigner(this._inner);

  final Keypair _inner;
  var calls = 0;

  @override
  PublicKey getPublicKey() => _inner.getPublicKey();

  @override
  SignatureScheme getKeyScheme() => _inner.getKeyScheme();

  @override
  Future<SignatureWithBytes> signWithIntent(
    Uint8List bytes,
    IntentScope intent,
  ) async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return _inner.signWithIntent(bytes, intent);
  }
}

Transaction _transfer(String sender) {
  final tx = Transaction()
    ..setSender(sender)
    ..setGasPrice(BigInt.from(1000))
    ..setGasBudget(BigInt.from(10000000))
    ..setGasPayment([
      SuiObjectRef(
        toB58(Uint8List.fromList(List.generate(32, (i) => i))),
        normalizeSuiAddress('0x5'),
        7,
      ),
    ]);
  final coin = tx.splitCoins(tx.gas, [tx.pure.u64(BigInt.from(100))]);
  tx.transferObjects([coin], sender);
  return tx;
}

void main() {
  final keypair = Ed25519Keypair.fromSecretKey(
    Uint8List(32)..fillRange(0, 32, 9),
  );
  final address = keypair.getPublicKey().toSuiAddress();

  test('Transaction.sign waits for an async signer', () async {
    final signer = _SlowSigner(keypair);
    final tx = _transfer(address);

    final signed = await tx.sign(SignOptions(signer: signer));

    expect(signer.calls, 1);
    final bytes = base64Decode(signed.bytes);
    expect(
      verifyTransactionSignature(bytes, signed.signature).toSuiAddress(),
      address,
    );
    // Ed25519 is deterministic, so the plain keypair signs the same bytes.
    final direct = await _transfer(address).sign(SignOptions(signer: keypair));
    expect(direct.signature, signed.signature);
  });

  test('personal messages go through the async signer', () async {
    final message = Uint8List.fromList(utf8.encode('hello'));
    final signed = await _SlowSigner(keypair).signPersonalMessage(message);
    expect(
      isValidPersonalMessageSignature(
        message,
        signed.signature,
        address: address,
      ),
      isTrue,
    );
  });

  test('keypairs and sync signers are async signers', () {
    final AsyncSigner fromKeypair = keypair;
    expect(fromKeypair.toSuiAddress(), address);
    expect(keypair.signTransaction(Uint8List(4)).signature, isNotEmpty);
  });
}
