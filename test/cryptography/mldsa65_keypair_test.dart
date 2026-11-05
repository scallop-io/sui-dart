import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pqcrypto/pqcrypto.dart' show DilithiumParams, MlDsa;
import 'package:sui_dart/sui.dart';
import 'package:sui_dart/utils/ed25519_hd_key.dart' as hd_key;
import 'package:sui_dart/utils/hex.dart';
import 'package:sui_dart/utils/sha.dart';
import 'package:test/test.dart';

final seed = Uint8List(32)..fillRange(0, 32, 2);
const address =
    '0xa44576e02f83a9e1bddac6fd742a77931d1689d9a61122eb3125dee425f6dd36';
const privateKey =
    'suiprivkey1qupqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyghdug7';

// [mnemonic, secret key hex, suiprivkey, address] at the default path.
const derivationCases = [
  [
    'act wing dilemma glory episode region allow mad tourist humble muffin oblige',
    '776e86532c6983454353f4860ae5e3f10c11bd4bcaec9455e1b05c0e14947075',
    'suiprivkey1qamkapjn935cx32r206gvzh9u0cscydaf09we9z4uxc9crs5j3c82q5m0tk',
    '0xd0f33625a23608ac4f3fd938a461ab15ed688af783eb4c54c19ab68e37a420dd',
  ],
  [
    'flag rebel cabbage captain minimum purpose long already valley horn enrich salt',
    'fc8b67af3bdadbd1314772ffcd2ed2fccbe09fe051cc07c3c05d3992edca3a6d',
    'suiprivkey1ql7gkea080ddh5f3gae0lnfw6t7vhcylupgucp7rcpwnnyhdegax6hx9cww',
    '0xd6de2b6e6d68114bbb6c4bbe3af4f174dcf51b27e5393b7606203cda8c933a93',
  ],
  [
    'area renew bar language pudding trial small host remind supreme cabbage era',
    '8d6bb89cf774f0c879648a8eaff68cb9131e0cb1a88c209a13453ea5cc306958',
    'suiprivkey1q7xkhwyu7a60pjrevj9gatlk3ju3x8svkx5gcgy6zdznafwvxp54swwyjt4',
    '0x48e9fcc44df5766d6be8e824c2781c40dd196f6a6b2e7244b78b02ab05249d66',
  ],
];

// SLIP-0010 ML-DSA-65: [seed, path, chain code, sha256(public key)].
const slip10Cases = [
  [
    '000102030405060708090a0b0c0d0e0f',
    "m/0'",
    'd8b27c87ec212d6501629199262a9d0d66ec26deab313c26a474bc4ddd5dce7c',
    '1d9d7fce0a1560acef9b117f3e3022cb0bdd46f30a3134db33165baf66b53e7e',
  ],
  [
    '000102030405060708090a0b0c0d0e0f',
    "m/0'/1'/2'/2'/1000000000'",
    'dc65d6cf4fa993c2f04fae2b41d70d8c5ba4c9d2042ea5720bf42a2315a6b7db',
    '9591ff122a7eff9cd64100f2123e678db9c257815ec5570b0b6acd8847e62f24',
  ],
  [
    'fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a2'
        '9f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542',
    "m/0'/2147483647'/1'/2147483646'/2'",
    '55a202d3f7803dd79e31c454e65eb7da49dee824b467bfed5204df980e71571d',
    '4b6c9f1dd1a811fe704c1355e32c43b63007317868ed6c3fce385f11c1b5da39',
  ],
];

void main() {
  final message = Uint8List.fromList(utf8.encode('hello'));

  test('seed maps to the known address and private key', () {
    final keypair = MLDSA65Keypair.fromSecretKey(seed);
    final account = SuiAccount(keypair);
    expect(account.getAddress(), address);
    expect(account.privateKey(), privateKey);
    expect(SuiAccount.fromPrivateKey(privateKey).getAddress(), address);
    expect(keypair.getPublicKey().toRawBytes().length, MLDSA65_PUBLIC_KEY_SIZE);
  });

  test('rejects a secret key that is not 32 bytes', () {
    expect(
      () => MLDSA65Keypair.fromSecretKey(Uint8List(31)),
      throwsArgumentError,
    );
  });

  test('verifies a signature from the reference signer', () {
    final vector = jsonDecode(
      File('test/cryptography/mldsa65_vectors.json').readAsStringSync(),
    );
    final keypair = MLDSA65Keypair.fromSecretKey(
      Uint8List.fromList(Hex.decode(vector['seed'])),
    );
    expect(keypair.getPublicKey().toSuiAddress(), vector['address']);
    final msg = Uint8List.fromList(utf8.encode(vector['personalMessage']));
    expect(
      keypair.getPublicKey().verifyPersonalMessage(msg, vector['signature']),
      isTrue,
    );
    expect(
      verifyPersonalMessageSignature(msg, vector['signature']).toSuiAddress(),
      vector['address'],
    );
  });

  test('hedged signing gives different valid signatures', () {
    final keypair = MLDSA65Keypair.fromSecretKey(seed);
    final first = keypair.signData(message);
    final second = keypair.signData(message);
    expect(first.length, MLDSA65_SIGNATURE_SIZE);
    expect(first, isNot(equals(second)));
    final publicKey = keypair.getPublicKey();
    expect(publicKey.verify(message, first), isTrue);
    expect(publicKey.verify(message, second), isTrue);
    final tampered = Uint8List.fromList(first)..[100] ^= 1;
    expect(publicKey.verify(message, tampered), isFalse);
    expect(publicKey.verify(message, first.sublist(1)), isFalse);
  });

  test('personal message round trip', () {
    final keypair = MLDSA65Keypair.fromSecretKey(seed);
    final signature = keypair.signPersonalMessage(message).signature;
    expect(base64Decode(signature)[0], 0x07);
    expect(
      verifyPersonalMessageSignature(
        message,
        signature,
        address: address,
      ).toSuiAddress(),
      address,
    );
  });

  test('derives from mnemonics at m/94\'/784\'', () {
    for (final [mnemonic, secretHex, suiPrivKey, addr] in derivationCases) {
      final keypair = MLDSA65Keypair.deriveKeypair(mnemonic);
      expect(Hex.encode(keypair.getSecretKey()), secretHex);
      expect(SuiAccount(keypair).privateKey(), suiPrivKey);
      expect(keypair.getPublicKey().toSuiAddress(), addr);
      expect(
        SuiAccount.fromMnemonics(
          mnemonic,
          SignatureScheme.MLDSA65,
        ).getAddress(),
        addr,
      );
    }
    expect(
      () => MLDSA65Keypair.deriveKeypair(
        derivationCases[0][0],
        "m/44'/784'/0'/0'/0'",
      ),
      throwsArgumentError,
    );
  });

  test('messy mnemonic input derives the same keys', () {
    final words = derivationCases[0][0];
    final messy = '  ${words.toUpperCase().replaceAll(' ', ' \t\n ')}  ';
    for (final scheme in [
      SignatureScheme.Ed25519,
      SignatureScheme.Secp256k1,
      SignatureScheme.Secp256r1,
      SignatureScheme.MLDSA65,
    ]) {
      expect(
        SuiAccount.fromMnemonics(messy, scheme).getAddress(),
        SuiAccount.fromMnemonics(words, scheme).getAddress(),
      );
    }
    expect(SuiAccount.isValidMnemonics(messy), isTrue);
    expect(normalizeMnemonics(messy), words);
  });

  test('matches the SLIP-0010 ML-DSA-65 vectors', () {
    for (final [seedHex, path, chainCode, pkDigest] in slip10Cases) {
      final node = hd_key.derivePath(
        path,
        seedHex,
        masterKey: MLDSA65_SLIP10_MASTER_KEY,
      );
      expect(Hex.encode(node.chainCode!), chainCode);
      final (pk, _) = MlDsa.generateKeyPairSeeded(
        DilithiumParams.mlDsa65,
        node.key!,
      );
      expect(Hex.encode(sha256(pk)), pkDigest);
    }
  });

  test('multisig with Ed25519 and ML-DSA-65 members', () {
    final ed = Ed25519Keypair.fromSecretKey(Uint8List(32)..fillRange(0, 32, 1));
    final pq = MLDSA65Keypair.fromSecretKey(seed);
    final multisigKey = MultiSigPublicKey.fromPublicKeys(
      threshold: 2,
      publicKeys: [
        PublicKeyWeight(1, ed.getPublicKey()),
        PublicKeyWeight(1, pq.getPublicKey()),
      ],
    );
    final multisig = multisigKey.combinePartialSignatures([
      ed.signPersonalMessage(message).signature,
      pq.signPersonalMessage(message).signature,
    ]);
    expect(multisigKey.verifyPersonalMessage(message, multisig), isTrue);

    final parsed = parseSerializedSignature(multisig);
    expect(
      parsePartialSignatures(parsed.multisig!).map((p) => p.signatureScheme),
      [SignatureScheme.Ed25519, SignatureScheme.MLDSA65],
    );
    expect(
      MultiSigPublicKey(parsed.multisig!.multisigPK).toSuiAddress(),
      multisigKey.toSuiAddress(),
    );
    expect(
      verifyPersonalMessageSignature(
        message,
        multisig,
        address: multisigKey.toSuiAddress(),
      ).toSuiAddress(),
      multisigKey.toSuiAddress(),
    );
  });
}
