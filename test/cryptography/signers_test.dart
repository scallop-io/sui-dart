import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:test/test.dart';
import 'package:sui_dart/sui.dart';

// Reused zkLogin proof fixture (addressSeed -> https://accounts.google.com).
// Its legacy address is 0xf7badc2b245c7f74d7509a4aa357ecf80a29e7713fb4c44b0e7541ec43885ee1.
final _zkInputs = ZkLoginSignatureInputs(
  proofPoints: ProofPoints(
    a: [
      '11701866812704517213914612798674748657755566586597434810941240483346769369267',
      '14120438998063692297386249754230972715153876537530168883981513584586172195841',
      '1',
    ],
    b: [
      [
        '1867454501602583848852787782761996560170118249299507014999230886852556998273',
        '14466419698679116313475210654562949128349597101769256959010003188886091080310',
      ],
      [
        '11072954562924588496148632474078432406633288948256718809714861986119303529760',
        '19790516010784935100150614989097908233899718645536130727773713407611161368046',
      ],
      ['1', '0'],
    ],
    c: [
      '10423289051853033915380810516130205747182867596457139999176714476415148376350',
      '21785719695848013908061492989765777788142255897986300241561280196745174934457',
      '1',
    ],
  ),
  issBase64Details: Claim(
    value: 'yJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLC',
    indexMod4: 1,
  ),
  addressSeed:
      '13322897930163218532266430409510394316985274769125667290600321564259466511711',
  headerBase64:
      'eyJhbGciOiJSUzI1NiIsImtpZCI6ImI5YWM2MDFkMTMxZmQ0ZmZkNTU2ZmYwMzJhYWIxODg4ODBjZGUzYjkiLCJ0eXAiOiJKV1QifQ',
);

const _googleJwt =
    'eyJhbGciOiJSUzI1NiIsImtpZCI6InN1aS1rZXktaWQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJzdWIiOiIxMjM0NTY3ODkwIiwiYXVkIjoiMTIzNDU2Nzg5MC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImV4cCI6MTY5NzU1MTg0NSwiaWF0IjoxNjk3NDY1NDQ1fQ.';

void main() {
  group('jwtDecode', () {
    test('decodes the payload', () {
      final payload = jwtDecode(_googleJwt);
      expect(payload['iss'], 'https://accounts.google.com');
      expect(payload['sub'], '1234567890');
      expect(payload['aud'], '1234567890.apps.googleusercontent.com');
    });

    test('decodes the header with header: true', () {
      final header = jwtDecode(_googleJwt, header: true);
      expect(header['alg'], 'RS256');
      expect(header['kid'], 'sui-key-id');
      expect(header['typ'], 'JWT');
    });

    test('throws on malformed input', () {
      expect(() => jwtDecode('not-a-jwt'), throwsA(isA<InvalidTokenError>()));
      expect(() => jwtDecode('a.!!!.c'), throwsA(isA<InvalidTokenError>()));
    });
  });

  group('getExtendedEphemeralPublicKey', () {
    test('equals toSuiPublicKey()', () {
      final pk = Ed25519Keypair().getPublicKey();
      expect(getExtendedEphemeralPublicKey(pk), pk.toSuiPublicKey());
    });
  });

  group('ZkLoginSigner', () {
    test('derives the legacy zkLogin address from the proof', () {
      final signer = ZkLoginSigner(
        ephemeralSigner: Ed25519Keypair(),
        maxEpoch: 174,
        inputs: _zkInputs,
        legacyAddress: true,
      );
      expect(signer.getKeyScheme(), SignatureScheme.ZkLogin);
      expect(
        signer.toSuiAddress(),
        '0xf7badc2b245c7f74d7509a4aa357ecf80a29e7713fb4c44b0e7541ec43885ee1',
      );
    });

    test('signTransaction wraps the ephemeral signature in a zkLogin signature', () {
      final signer = ZkLoginSigner(
        ephemeralSigner: Ed25519Keypair(),
        maxEpoch: 174,
        inputs: _zkInputs,
        legacyAddress: true,
      );
      final txBytes = Uint8List.fromList([5, 6, 7, 8]);
      final sig = signer.signTransaction(txBytes).signature;

      expect(parseSerializedSignature(sig).signatureScheme, SignatureScheme.ZkLogin);
      final parsed = parseZkLoginSignature(fromB64(sig).sublist(1));
      expect(parsed.maxEpoch, 174);
      expect(parsed.inputs.addressSeed, _zkInputs.addressSeed);
    });

    test('constructor validates the provided address', () {
      expect(
        () => ZkLoginSigner(
          ephemeralSigner: Ed25519Keypair(),
          maxEpoch: 174,
          inputs: _zkInputs,
          legacyAddress: true,
          address: '0xdeadbeef',
        ),
        throwsArgumentError,
      );
    });

    test('sign() throws', () {
      final signer = ZkLoginSigner(
        ephemeralSigner: Ed25519Keypair(),
        maxEpoch: 174,
        inputs: _zkInputs,
        legacyAddress: true,
      );
      expect(() => signer.sign(Uint8List(4)), throwsA(isA<UnsupportedError>()));
    });
  });

  group('MultiSigSigner', () {
    late Ed25519Keypair kp1;
    late Ed25519Keypair kp2;
    late MultiSigPublicKey pk;

    setUp(() {
      kp1 = Ed25519Keypair();
      kp2 = Ed25519Keypair();
      pk = MultiSigPublicKey.fromPublicKeys(
        threshold: 2,
        publicKeys: [
          PublicKeyWeight(1, kp1.getPublicKey()),
          PublicKeyWeight(1, kp2.getPublicKey()),
        ],
      );
    });

    test('combines partial signatures that verify', () {
      final signer = MultiSigSigner(pk, [kp1, kp2]);
      final txBytes = Uint8List.fromList([1, 2, 3, 4]);
      final sig = signer.signTransaction(txBytes).signature;

      final parsed = parseSerializedSignature(sig);
      expect(parsed.signatureScheme, SignatureScheme.MultiSig);
      expect(parsed.multisig!.sigs.length, 2);
      expect(isValidTransactionSignature(txBytes, sig), true);
    });

    test('rejects duplicate signers', () {
      expect(() => MultiSigSigner(pk, [kp1, kp1]), throwsArgumentError);
    });

    test('rejects combined weight below threshold', () {
      expect(() => MultiSigSigner(pk, [kp1]), throwsArgumentError);
    });

    test('rejects a non-member signer', () {
      expect(() => MultiSigSigner(pk, [Ed25519Keypair()]), throwsArgumentError);
    });
  });
}
