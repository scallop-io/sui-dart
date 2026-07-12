import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/sui.dart';
import 'package:sui_dart/utils/bech32/bech32.dart';
import 'package:test/test.dart';

class _PasskeyProvider extends PasskeyProvider {
  _PasskeyProvider(this.signature, {this.useWrongChallenge = false});

  final Uint8List signature;
  final bool useWrongChallenge;

  @override
  Future<PasskeyRegistration> create() => throw UnimplementedError();

  @override
  Future<PasskeyAuthentication> get(
    Uint8List challenge, [
    Uint8List? credentialId,
  ]) async {
    final returnedChallenge = useWrongChallenge
        ? Uint8List.fromList([...challenge, 0])
        : challenge;
    final encodedChallenge = base64UrlEncode(
      returnedChallenge,
    ).replaceAll('=', '');
    return PasskeyAuthentication(
      authenticatorData: Uint8List(0),
      clientDataJson: Uint8List.fromList(
        utf8.encode('{"type":"webauthn.get","challenge":"$encodedChallenge"}'),
      ),
      signature: signature,
    );
  }
}

void main() {
  group('security regressions', () {
    test('multisig signatures cannot substitute another key scheme', () {
      final r1 = Secp256r1Keypair();
      final sameBytesK1 = Secp256PublicKey.fromBytes(
        r1.getPublicKey().toRawBytes(),
        SIGNATURE_SCHEME_TO_FLAG.Secp256k1,
      );
      final multisig = MultiSigPublicKey.fromPublicKeys(
        threshold: 1,
        publicKeys: [PublicKeyWeight(1, sameBytesK1)],
      );
      final signature = r1.signData(Uint8List.fromList([1]));
      final serialized = toSerializedSignature(
        SignatureScheme.Secp256r1,
        signature,
        r1.getPublicKey(),
      );

      expect(
        () => multisig.combinePartialSignatures([serialized]),
        throwsArgumentError,
      );
    });

    test('multisig bitmap must match its signatures', () {
      final publicKey = Ed25519Keypair().getPublicKey();
      final multisig = MultiSigStruct(
        [
          {SignatureScheme.Ed25519.name: Uint8List(64)},
        ],
        0,
        MultiSigPublicKeyStruct([
          PubkeyEnumWeightPair({
            SignatureScheme.Ed25519.name: publicKey.toRawBytes(),
          }, 1),
        ], 1),
      );

      expect(() => parsePartialSignatures(multisig), throwsArgumentError);
      expect(() => asIndices(1 << MAX_SIGNER_IN_MULTISIG), throwsArgumentError);
    });

    test('serialized signatures require their exact size', () {
      expect(
        () => parseSerializedSignature(base64Encode(Uint8List(0))),
        throwsArgumentError,
      );
      expect(
        () => parseSerializedSignature(
          base64Encode(Uint8List.fromList([SIGNATURE_SCHEME_TO_FLAG.Ed25519])),
        ),
        throwsArgumentError,
      );
    });

    test('passkey wrapper requires a secp256r1 inner signature', () {
      final encoded = SuiBcs.PasskeyAuthenticator.serialize({
        'authenticatorData': Uint8List(0),
        'clientDataJson': '{}',
        'userSignature': Uint8List(
          1 + PASSKEY_SIGNATURE_SIZE + PASSKEY_PUBLIC_KEY_SIZE,
        ),
      }).toBytes();
      final serialized = Uint8List.fromList([
        SIGNATURE_SCHEME_TO_FLAG.Passkey,
        ...encoded,
      ]);

      expect(
        () => parseSerializedPasskeySignature(serialized),
        throwsArgumentError,
      );
    });

    test('passkey signer rejects mismatched challenges and malformed DER', () {
      final publicKey = Secp256r1Keypair().getPublicKey().toRawBytes();
      final challenge = Uint8List.fromList([1, 2, 3]);

      expect(
        () => PasskeyKeypair(
          publicKey,
          _PasskeyProvider(Uint8List(0), useWrongChallenge: true),
        ).sign(challenge),
        throwsArgumentError,
      );
      expect(
        () => PasskeyKeypair(
          publicKey,
          _PasskeyProvider(Uint8List.fromList([0x30])),
        ).sign(challenge),
        throwsArgumentError,
      );
      expect(
        () => PasskeyKeypair(
          publicKey,
          _PasskeyProvider(Uint8List.fromList([0x30, 6, 2, 1, 1, 2, 1, 1, 0])),
        ).sign(challenge),
        throwsArgumentError,
      );
    });

    test('private key decoder enforces the documented payload length', () {
      final invalidPayload = Uint8List.fromList([
        SIGNATURE_SCHEME_TO_FLAG.Ed25519,
        ...getRandom().nextBytes(PRIVATE_KEY_SIZE - 1),
      ]);
      final encoded = bech32.encode(
        Bech32(SUI_PRIVATE_KEY_PREFIX, bech32.toWords(invalidPayload)),
      );

      expect(() => decodeSuiPrivateKey(encoded), throwsArgumentError);
      expect(
        () => padLeftUint8List(Uint8List(PRIVATE_KEY_SIZE + 1)),
        throwsArgumentError,
      );
      expect(
        padLeftUint8List(Uint8List.fromList([1])),
        hasLength(PRIVATE_KEY_SIZE),
      );
    });
  });
}
