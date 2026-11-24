import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/sui.dart';
import 'package:test/test.dart';

void main() {
  final ed = Ed25519Keypair.fromSecretKey(Uint8List(32)..fillRange(0, 32, 9));
  final k1 = Secp256k1Keypair.fromSecretKey(Uint8List(32)..fillRange(0, 32, 7));
  final message = Uint8List.fromList(utf8.encode('hello'));
  final other = '0x${'b' * 64}';

  test('signPersonalMessage returns the raw message as bytes', () {
    for (final Keypair keypair in [ed, k1]) {
      final signed = keypair.signPersonalMessage(message);
      expect(signed.bytes, base64Encode(message));
      expect(
        isValidPersonalMessageSignature(
          message,
          signed.signature,
          address: keypair.toSuiAddress(),
        ),
        isTrue,
      );
    }
  });

  test('secp256 verify returns false for a signature that fits no key', () {
    final flipped = Uint8List.fromList(k1.signData(message))..[31] ^= 1;
    expect(k1.getPublicKey().verify(message, flipped), isFalse);
    expect(k1.getPublicKey().verify(message, Uint8List(64)), isFalse);
  });

  test('publicKeyFromRawBytes checks the address for every scheme', () {
    final raw = ed.getPublicKey().toRawBytes();
    final upper = ed.toSuiAddress().toUpperCase().replaceFirst('0X', '0x');
    expect(
      publicKeyFromRawBytes('Ed25519', raw, address: upper).toSuiAddress(),
      ed.toSuiAddress(),
    );
    expect(
      () => publicKeyFromRawBytes('Ed25519', raw, address: other),
      throwsArgumentError,
    );
    expect(
      () => publicKeyFromRawBytes(
        'Secp256k1',
        k1.getPublicKey().toRawBytes(),
        address: other,
      ),
      throwsArgumentError,
    );
  });

  test('a shared object keeps NonExclusiveWrite through BCS', () {
    final bytes = SuiBcs.SharedObjectRef.serialize({
      'objectId': '0x6',
      'initialSharedVersion': 1,
      'mutable': false,
      'mutability': 'NonExclusiveWrite',
    }).toBytes();
    expect(bytes.last, 2);
    final parsed = SuiBcs.SharedObjectRef.parse(bytes);
    expect(parsed['mutable'], isFalse);
    expect(parsed['mutability'], 'NonExclusiveWrite');
    expect(SuiBcs.SharedObjectRef.serialize(parsed).toBytes(), bytes);
    expect(
      SuiBcs.SharedObjectRef.serialize({
        'objectId': '0x6',
        'initialSharedVersion': 1,
        'mutable': true,
      }).toBytes().last,
      1,
    );
  });

  test('SuiObjectRef serializes on its own', () {
    expect(
      SuiBcs.SuiObjectRef.serialize({
        'objectId': '0x2',
        'version': 5,
        'digest': '11111111111111111111111111111111',
      }).toBytes(),
      hasLength(73),
    );
  });
}
