import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/sui.dart';
import 'package:sui_dart/utils/hex.dart';
import 'package:test/test.dart';

void main() {
  final ed = Ed25519Keypair.fromSecretKey(Uint8List(32)..fillRange(0, 32, 9));
  final k1 = Secp256k1Keypair.fromSecretKey(Uint8List(32)..fillRange(0, 32, 7));
  final message = Uint8List.fromList(utf8.encode('hello'));
  final other = '0x${'a' * 64}';
  const words =
      'film crazy soon outside stand loop subway crumble thrive popular green '
      'nuclear struggle pistol arm wife phrase warfare march wheat nephew ask '
      'sunny firm';

  test('verifyAddress takes any spelling of the address', () {
    final address = ed.toSuiAddress();
    final key = ed.getPublicKey();
    expect(
      key.verifyAddress('0x${address.substring(2).toUpperCase()}'),
      isTrue,
    );
    expect(key.verifyAddress(address.substring(2)), isTrue);
    expect(key.verifyAddress(other), isFalse);
  });

  test('verify rejects a serialized signature from another key', () {
    final foreign = base64Decode(k1.signPersonalMessage(message).signature);
    expect(
      () => ed.getPublicKey().verify(message, foreign),
      throwsArgumentError,
    );
  });

  test('equals across key types is false, not a throw', () {
    expect(ed.getPublicKey().equals(k1.getPublicKey()), isFalse);
    expect(k1.getPublicKey().equals(ed.getPublicKey()), isFalse);
  });

  test('secp256 derivation and keys are range checked', () {
    expect(
      () => Secp256k1Keypair.deriveKeypair("m/54'/784'/0'/0/2147483648", words),
      throwsArgumentError,
    );
    expect(
      () => Secp256k1Keypair.fromSecretKey(Uint8List(32)),
      throwsArgumentError,
    );
    expect(
      () =>
          Secp256k1Keypair.fromSecretKey(Uint8List(32)..fillRange(0, 32, 255)),
      throwsArgumentError,
    );
  });

  test('a 0x-prefixed seed is accepted', () {
    expect(
      Ed25519Keypair.deriveKeypairFromSeed('0x${'11' * 32}').toSuiAddress(),
      Ed25519Keypair.deriveKeypairFromSeed('11' * 32).toSuiAddress(),
    );
  });

  test('invalid input throws: negative zkLogin seed, hex, parent id', () {
    expect(
      () => computeZkLoginAddressFromSeed(
        BigInt.from(-5),
        'https://accounts.google.com',
      ),
      throwsArgumentError,
    );
    expect(() => Hex.decode('0x-1'), throwsFormatException);
    expect(
      () => deriveDynamicFieldId(
        parentObjectId: '0x${'1' * 66}',
        keyTypeTag: 'u64',
        keyBcs: Uint8List(1),
      ),
      throwsA(anything),
    );
  });

  test('small helpers', () {
    expect(formatDigest('abc'), 'abc…');
    expect(UpgradePolicy.ADDITIVE.value, 128);
    expect(UpgradePolicy.DEP_ONLY.value, 192);
  });

  test('Owner decodes a Party owner', () {
    final bytes = Uint8List.fromList([
      5, 7, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 1, //
      ...Hex.decode('${'0' * 60}0acc'),
      63, 0, 0, 0, 0, 0, 0, 0,
    ]);
    final owner = SuiBcs.Owner.parse(bytes);
    expect('${owner['Party']['startVersion']}', '7');
    expect(SuiBcs.Owner.serialize(owner).toBytes(), bytes);
  });

  test('the sender is validated and normalized', () {
    final tx = Transaction()..setSender('0xa');
    expect(tx.getData().sender, normalizeSuiAddress('0xa'));
    expect(() => Transaction().setSender('0x0x5'), throwsArgumentError);
    expect(() => Transaction().setGasOwner('0x0x5'), throwsArgumentError);
  });

  test('restored gas data rejects a bad budget', () {
    expect(
      () => Transaction.from(
        jsonEncode({
          'version': 2,
          'sender': other,
          'expiration': null,
          'gasData': {'budget': 'abc'},
          'inputs': [],
          'commands': [],
        }),
      ),
      throwsArgumentError,
    );
  });

  test('an argument without \$kind, and a thunk added twice', () {
    final tx = Transaction();
    tx.moveCall('0x2::m::a');
    tx.mergeCoins(tx.gas, [
      tx.object({'Result': 0}),
    ]);
    expect(tx.getData().inputs, isEmpty);

    final twice = Transaction();
    TransactionResult thunk(Transaction t) => t.moveCall('0x2::m::a');
    twice.add(thunk);
    twice.add(thunk);
    expect(twice.getData().commands, hasLength(1));
  });
}
