import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:sui_dart/cryptography/ed25519_keypair.dart';
import 'package:sui_dart/utils/ed25519_hd_key.dart' show derivePath;
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;

void main() {
  const validSecretKey =
      'mdqVWeFekT7pqy5T49+tV12jO0m+ESW7ki4zSU9JiCgbL0kJbj5dvQ/PqcDAzZLZqzshVEs01d1KZdmLh4uZIg==';
  const invalidSecretKey =
      'mdqVWeFekT7pqy5T49+tV12jO0m+ESW7ki4zSU9JiCgbL0kJbj5dvQ/PqcDAzZLZqzshVEs01d1KZdmLh4uZIG==';
  const testMnemonic =
      'result crisp session latin must fruit genuine question prevent start coconut brave speak student dismiss';

  group('ed25519-keypair', () {
    test('keypair', () {
      final keypair = Ed25519Keypair();
      expect(keypair.publicKeyBytes().length == 32, true);
    });

    test('create keypair from secret key', () {
      Uint8List secretKey = base64Decode(validSecretKey);
      final keypair = Ed25519Keypair.fromSecretKey(secretKey);
      final publicKey = base64Encode(keypair.publicKeyBytes());
      expect(publicKey == 'Gy9JCW4+Xb0Pz6nAwM2S2as7IVRLNNXdSmXZi4eLmSI=', true);
    });

    test('creating keypair from invalid secret key throws error', () {
      expect(() {
        Uint8List secretKey = base64Decode(invalidSecretKey);
        Ed25519Keypair.fromSecretKey(secretKey);
      }, throwsException);
    });

    test(
      'creating keypair from invalid secret key succeeds if validation is skipped',
      () {
        expect(() {
          Uint8List secretKey = base64Decode(invalidSecretKey);
          final keypair = Ed25519Keypair.fromSecretKey(
            secretKey,
            skipValidation: true,
          );
          final publicKey = base64Encode(keypair.publicKeyBytes());
          return publicKey == 'Gy9JCW4+Xb0Pz6nAwM2S2as7IVRLNNXdSmXZi4eLmSA=';
        }, throwsException);
      },
    );

    test('generate keypair from random seed', () {
      final seed = Uint8List.fromList(List<int>.filled(32, 8));
      final keypair = Ed25519Keypair.fromSeed(seed);
      final publicKey = base64Encode(keypair.publicKeyBytes());
      expect(publicKey == 'E5j2LG0aRXxRumpLXz29L2n8qTIWIY3ImX5Ba9F9k8o=', true);
    });

    test('signature of data is valid', () {
      final keypair = Ed25519Keypair();
      final signData = Uint8List.fromList(utf8.encode('hello world'));
      final signature = keypair.signData(signData);
      final isValid = ed25519.verify(
        keypair.keyPair().publicKey,
        signData,
        signature,
      );
      expect(isValid, true);
    });

    test('derive ed25519 keypair from path and mnemonics', () {
      final keypair = Ed25519Keypair.fromMnemonics(testMnemonic);
      final publicKey = base64Encode(keypair.publicKeyBytes());
      expect(publicKey == 'aFstb5h4TddjJJryHJL1iMob6AxAqYxVv3yRt05aweI=', true);
      expect(
        keypair.getPublicKey().toSuiAddress() ==
            '0x936accb491f0facaac668baaedcf4d0cfc6da1120b66f77fa6a43af718669973',
        true,
      );
    });

    test('incorrect coin type node for ed25519 derivation path', () {
      expect(() {
        Ed25519Keypair.deriveKeypair("m/44'/0'/0'/0'/0'", testMnemonic);
      }, throwsArgumentError);
    });

    test('incorrect purpose node for ed25519 derivation path', () {
      expect(() {
        Ed25519Keypair.deriveKeypair("m/54'/784'/0'/0'/0'", testMnemonic);
      }, throwsArgumentError);
    });

    test('invalid mnemonics to derive ed25519 keypair', () {
      expect(() {
        Ed25519Keypair.fromMnemonics('aaa');
      }, throwsArgumentError);
    });

    test('signs PersonalMessages', () {
      final keypair = Ed25519Keypair();
      final message = Uint8List.fromList(utf8.encode('hello world'));

      final signatureWithBytes = (keypair.signPersonalMessage(message));

      expect(
        keypair.verifyPersonalMessage(message, signatureWithBytes.signature),
        true,
      );
      expect(
        keypair.verifyPersonalMessage(message, signatureWithBytes.signature),
        true,
      );
    });
  });

  group('derivation paths', () {
    const mnemonic =
        'abandon abandon abandon abandon abandon abandon abandon abandon '
        'abandon abandon abandon about';

    test('reject an index that would wrap onto another account', () {
      expect(
        () => Ed25519Keypair.deriveKeypair(
          "m/44'/784'/2147483648'/0'/0'",
          mnemonic,
        ),
        throwsArgumentError,
      );
    });

    test('reject a non-canonical index', () {
      expect(
        () => Ed25519Keypair.deriveKeypair("m/44'/784'/01'/0'/0'", mnemonic),
        throwsArgumentError,
      );
    });

    test('reject a seed outside 16 to 64 bytes', () {
      expect(
        () => derivePath("m/44'/784'/0'/0'/0'", '00' * 15),
        throwsArgumentError,
      );
      expect(
        () => derivePath("m/44'/784'/0'/0'/0'", '00' * 65),
        throwsArgumentError,
      );
    });

    test('still derive the last valid index', () {
      expect(
        () => Ed25519Keypair.deriveKeypair(
          "m/44'/784'/2147483647'/0'/0'",
          mnemonic,
        ),
        returnsNormally,
      );
      expect(
        () => derivePath("m/44'/784'/2147483647'/0'/0'", '00' * 32),
        returnsNormally,
      );
    });
  });
}
