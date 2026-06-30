import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/sui.dart';
import 'package:test/test.dart';

void main() {
  group('PasskeyPublicKey', () {
    // Known-answer vector produced by a reference (Rust) authenticator.
    const rustSig =
        'BiVYDmenOnqS+thmz5m5SrZnWaKXZLVxgh+rri6LHXs25B0AAAAAgwF7InR5cGUiOiJ3ZWJhdXRobi5nZXQiLCJjaGFsbGVuZ2UiOiJ4NkszMGNvSGlGMF9iczVVVjNzOEVfcGNPNkhMZ0xBb1A3ZE1uU0U5eERNIiwib3JpZ2luIjoiaHR0cHM6Ly93d3cuc3VpLmlvIiwiY3Jvc3NPcmlnaW4iOmZhbHNlfWICAJqKTgco/tSNg4BuVg/f3x+I8NLYN6QqvxHahKNe0PIhBe3EuhfZf8OL4hReW8acT1TVwmPMcnv4SWiAHaX2dAKBYTKkrLK2zLcfP/hD1aiAn/E0L3XLC4epejnzGRhTuA==';
    const rustTx =
        'AAABACACAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgEBAQABAAAt3HtjT61oHCWWztGfhSC2ianNwi6LL2eOLPvZTdJWMgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAIMqiyOLCIblSqii0TkS8PjMoj3tmA7S24hBMyonz2Op/Ldx7Y0+taBwlls7Rn4UgtompzcIuiy9njiz72U3SVjLoAwAAAAAAAICWmAAAAAAAAA==';

    // Known-answer vector from a real iPhone passkey (Safari/WebAuthn).
    const realSig =
        'BiVJlg3liA6MaHQ0Fw9kdmBbj+SuuaKGMseZXPO6gx2XYx0AAAAAhgF7InR5cGUiOiJ3ZWJhdXRobi5nZXQiLCJjaGFsbGVuZ2UiOiJZRG9vQ2RGRnRLLVJBZ3JzaUZqM1hpU1VPQ2pzWXJPWnRGcHVISGhvNDhZIiwib3JpZ2luIjoiaHR0cDovL2xvY2FsaG9zdDo1MTczIiwiY3Jvc3NPcmlnaW4iOmZhbHNlfWIChCx2fLGV+dwNRbTqfCvii70DMj1HiHij5oR9KjZmFMpGQJz3l0ZsNpi0zGQtw81Hj+X+CSshhkcteCzVOJlpKAN2ZM3l9Wxn5TYJFdHc9VphEGzoyTTOfUjpZ7fQV2gt6A==';
    const realTx =
        'AAAAAFTTJ1JTZKCS6Q6aQS2bkY5gsmP//JTTwIzqsKqnltvLAS6VBPgonu3+e2qJUje77aMw0hTzv7mfKxBglq17ccifBgIAAAAAAAAgb2Je8hW/vUH9otcR+oc1RdjZ2W2oaCNgMu0gTpAVfbNU0ydSU2SgkukOmkEtm5GOYLJj//yU08CM6rCqp5bby+gDAAAAAAAAgIQeAAAAAAAA';

    PasskeyPublicKey pubKeyOf(String sig) =>
        PasskeyPublicKey(parseSerializedPasskeySignature(sig).publicKey);

    test('parses a serialized signature', () {
      final parsed = parseSerializedPasskeySignature(rustSig);
      expect(parsed.signatureScheme, SignatureScheme.Passkey);
      expect(parsed.publicKey.length, PASSKEY_PUBLIC_KEY_SIZE);
      expect(parsed.signature.length, PASSKEY_SIGNATURE_SIZE);
      expect(jsonDecode(parsed.clientDataJson)['type'], 'webauthn.get');
    });

    test('verifies a transaction (reference vector)', () {
      expect(
        pubKeyOf(rustSig).verifyTransaction(base64Decode(rustTx), rustSig),
        isTrue,
      );
    });

    test('verifies a transaction (real iPhone passkey)', () {
      expect(
        pubKeyOf(realSig).verifyTransaction(base64Decode(realTx), realSig),
        isTrue,
      );
    });

    test('rejects a tampered transaction', () {
      final tampered = Uint8List.fromList(base64Decode(rustTx));
      tampered[0] ^= 0xff;
      expect(pubKeyOf(rustSig).verifyTransaction(tampered, rustSig), isFalse);
    });

    test('rejects a signature whose embedded key is not this key', () {
      // The real-vector signature carries a different key than the rust vector.
      expect(
        pubKeyOf(rustSig).verifyTransaction(base64Decode(realTx), realSig),
        isFalse,
      );
    });

    test('flag is 0x06 and sui-bytes round-trips to the same key', () {
      final pk = pubKeyOf(rustSig);
      expect(pk.flag(), 0x06);
      final restored = publicKeyFromSuiBytes(pk.toSuiPublicKey());
      expect(restored.toSuiAddress(), pk.toSuiAddress());
    });
  });
}
