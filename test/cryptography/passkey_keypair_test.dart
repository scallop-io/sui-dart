import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/sui.dart';
import 'package:sui_dart/utils/sha.dart';
import 'package:test/test.dart';

/// A software stand-in for a platform authenticator: it holds a secp256r1 key
/// and produces real WebAuthn-shaped assertions, so the full sign -> verify path
/// can be exercised without a device.
class _SoftwareProvider extends PasskeyProvider {
  final Uint8List _privateKey;
  final Secp256 _secp = Secp256.fromSecp256r1();

  _SoftwareProvider(this._privateKey);

  static const _spkiHeader = [
    0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, //
    0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, //
    0x03, 0x01, 0x07, 0x03, 0x42, 0x00,
  ];

  @override
  Future<PasskeyRegistration> create() async {
    final xy = _secp.getPublicKeyFromPrivateKeyBytes(_privateKey, false); // 64
    final der = Uint8List.fromList([..._spkiHeader, 0x04, ...xy]);
    return PasskeyRegistration(
      publicKeyDer: der,
      credentialId: Uint8List.fromList([1, 2, 3, 4]),
    );
  }

  @override
  Future<PasskeyAuthentication> get(
    Uint8List challenge, [
    Uint8List? credentialId,
  ]) async {
    final clientDataJson =
        '{"type":"webauthn.get","challenge":"${base64Url.encode(challenge).replaceAll('=', '')}","origin":"https://example.com","crossOrigin":false}';
    final clientDataBytes = Uint8List.fromList(utf8.encode(clientDataJson));
    final authenticatorData = Uint8List.fromList(
      List<int>.generate(37, (i) => i + 1),
    );

    final clientDataHash = sha256(clientDataBytes);
    final payload = Uint8List.fromList([
      ...authenticatorData,
      ...clientDataHash,
    ]);
    final sig = _secp.sign(sha256(payload), _privateKey);

    return PasskeyAuthentication(
      authenticatorData: authenticatorData,
      clientDataJson: clientDataBytes,
      signature: _der(sig),
    );
  }

  static Uint8List _der(SignatureData sig) {
    final r = _derInt(sig.r);
    final s = _derInt(sig.s);
    return Uint8List.fromList([0x30, r.length + s.length, ...r, ...s]);
  }

  static Uint8List _derInt(BigInt v) {
    var b = encodeBigIntAsUnsigned(v);
    var start = 0;
    while (start < b.length - 1 && b[start] == 0) {
      start++;
    }
    b = Uint8List.sublistView(b, start);
    if (b[0] & 0x80 != 0) {
      b = Uint8List.fromList([0x00, ...b]);
    }
    return Uint8List.fromList([0x02, b.length, ...b]);
  }
}

void main() {
  group('PasskeyKeypair', () {
    final tx = Uint8List.fromList(List<int>.generate(64, (i) => i));
    final msg = Uint8List.fromList(utf8.encode('Hello world!'));

    late _SoftwareProvider provider;

    setUp(() {
      provider = _SoftwareProvider(
        Secp256.fromSecp256r1().generatePrivateKeyBytes(),
      );
    });

    test('derives the public key from a registration credential', () async {
      final signer = await PasskeyKeypair.getPasskeyInstance(provider);
      expect(signer.getPublicKey().flag(), 0x06);
      expect(
        signer.getPublicKey().toRawBytes().length,
        PASSKEY_PUBLIC_KEY_SIZE,
      );
      expect(signer.getCredentialId(), Uint8List.fromList([1, 2, 3, 4]));
    });

    test('signs a transaction that verifies against its public key', () async {
      final signer = await PasskeyKeypair.getPasskeyInstance(provider);
      final result = await signer.signTransaction(tx);

      expect(isValidTransactionSignature(tx, result.signature), isTrue);
      expect(
        signer.getPublicKey().verifyTransaction(tx, result.signature),
        isTrue,
      );
      expect(
        parseSerializedPasskeySignature(result.signature).signatureScheme,
        SignatureScheme.Passkey,
      );
    });

    test('signs a personal message that verifies', () async {
      final signer = await PasskeyKeypair.getPasskeyInstance(provider);
      final result = await signer.signPersonalMessage(msg);
      expect(isValidPersonalMessageSignature(msg, result.signature), isTrue);
    });

    test('signAndRecover + findCommonPublicKey identifies the key', () async {
      final signer = await PasskeyKeypair.getPasskeyInstance(provider);
      final pks1 = await PasskeyKeypair.signAndRecover(provider, tx);
      final pks2 = await PasskeyKeypair.signAndRecover(provider, msg);

      final common = findCommonPublicKey(pks1, pks2);
      expect(common.toRawBytes(), signer.getPublicKey().toRawBytes());
    });
  });
}
