// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:pointycastle/export.dart' show ECSignature;
import 'package:sui_dart/bcs/sui_bcs.dart';
import 'package:sui_dart/cryptography/helper.dart';
import 'package:sui_dart/cryptography/intent.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/cryptography/passkey_publickey.dart';
import 'package:sui_dart/cryptography/secp256.dart';
import 'package:sui_dart/cryptography/signature.dart';
import 'package:sui_dart/utils/sha.dart';

/// The public key and credential id returned when registering a new passkey.
class PasskeyRegistration {
  /// DER `SubjectPublicKeyInfo` for the secp256r1 key.
  final Uint8List publicKeyDer;
  final Uint8List credentialId;

  PasskeyRegistration({required this.publicKeyDer, required this.credentialId});
}

/// The result of a WebAuthn assertion (`navigator.credentials.get` and friends).
class PasskeyAuthentication {
  final Uint8List authenticatorData;

  /// The UTF-8 encoded client data JSON.
  final Uint8List clientDataJson;

  /// The DER-encoded ECDSA signature.
  final Uint8List signature;

  PasskeyAuthentication({
    required this.authenticatorData,
    required this.clientDataJson,
    required this.signature,
  });
}

/// Bridges to a platform WebAuthn/credentials API. The actual key lives in the
/// authenticator, so this is implemented by the host app (browser via JS interop,
/// iOS/Android via platform channels) and supplied to [PasskeyKeypair].
abstract class PasskeyProvider {
  /// Registers a new passkey credential.
  Future<PasskeyRegistration> create();

  /// Signs [challenge] with an existing credential, returning the assertion.
  Future<PasskeyAuthentication> get(
    Uint8List challenge, [
    Uint8List? credentialId,
  ]);
}

/// A passkey signer (SIP-9). The private key never leaves the authenticator;
/// signing is delegated to a [PasskeyProvider], so every signing method is async.
class PasskeyKeypair {
  final Uint8List _publicKey;
  final PasskeyProvider _provider;
  final Uint8List? _credentialId;

  PasskeyKeypair(
    Uint8List publicKey,
    PasskeyProvider provider, [
    Uint8List? credentialId,
  ]) : _publicKey = Uint8List.fromList(publicKey),
       _provider = provider,
       _credentialId = credentialId {
    if (_publicKey.length != PASSKEY_PUBLIC_KEY_SIZE) {
      throw ArgumentError(
        'Invalid public key length. Expected $PASSKEY_PUBLIC_KEY_SIZE bytes, got ${_publicKey.length}',
      );
    }
  }

  SignatureScheme getKeyScheme() => SignatureScheme.Passkey;

  PasskeyPublicKey getPublicKey() => PasskeyPublicKey(_publicKey);

  String toSuiAddress() => getPublicKey().toSuiAddress();

  Uint8List? getCredentialId() => _credentialId;

  /// Registers a fresh passkey via [provider] and returns a signer for it.
  /// Only call this when creating a passkey wallet for the first time; to use an
  /// existing passkey whose public key is unknown, see [signAndRecover].
  static Future<PasskeyKeypair> getPasskeyInstance(
    PasskeyProvider provider,
  ) async {
    final registration = await provider.create();
    final uncompressed = parseDerSPKI(registration.publicKeyDer);
    final compressed = curve256r1Params.curve
        .decodePoint(uncompressed)!
        .getEncoded(true);
    return PasskeyKeypair(
      Uint8List.fromList(compressed),
      provider,
      registration.credentialId,
    );
  }

  /// Asks the authenticator to sign [data] (typically `blake2b(intent_message)`,
  /// passed as the WebAuthn challenge) and returns the BCS-encoded
  /// `PasskeyAuthenticator` (without the outer scheme flag).
  Future<Uint8List> sign(Uint8List data) async {
    final credential = await _provider.get(data, _credentialId);
    final clientDataJsonString = utf8.decode(credential.clientDataJson);
    final clientData = jsonDecode(clientDataJsonString);
    if (clientData is! Map ||
        clientData['type'] != 'webauthn.get' ||
        clientData['challenge'] is! String ||
        !bytesEqual(
          base64Url.decode(
            base64Url.normalize(clientData['challenge'] as String),
          ),
          data,
        )) {
      throw ArgumentError('Authenticator returned invalid client data');
    }

    final (r, s) = _decodeDerEcdsaSignature(credential.signature);
    if (r >= curve256r1Params.n || s >= curve256r1Params.n) {
      throw ArgumentError('Invalid ECDSA signature values');
    }
    var ecSig = ECSignature(r, s);
    if (!ecSig.isNormalized(curve256r1Params)) {
      ecSig = ecSig.normalize(curve256r1Params);
    }
    final normalized = SignatureData(ecSig.r, ecSig.s).toBytes();

    // userSignature is a serialized secp256r1 signature: flag || sig(64) || pk(33).
    final userSignature = Uint8List(1 + normalized.length + _publicKey.length);
    userSignature[0] = SIGNATURE_SCHEME_TO_FLAG.Secp256r1;
    userSignature.setAll(1, normalized);
    userSignature.setAll(1 + normalized.length, _publicKey);

    return SuiBcs.PasskeyAuthenticator.serialize({
      'authenticatorData': credential.authenticatorData,
      'clientDataJson': clientDataJsonString,
      'userSignature': userSignature,
    }).toBytes();
  }

  Future<SignatureWithBytes> signWithIntent(
    Uint8List bytes,
    IntentScope intent,
  ) async {
    final intentMessage = messageWithIntent(intent, bytes);
    final digest = blake2b(intentMessage);
    final signature = await sign(digest);

    final serialized = Uint8List(1 + signature.length);
    serialized[0] = SIGNATURE_SCHEME_TO_FLAG.Passkey;
    serialized.setAll(1, signature);

    return SignatureWithBytes(base64Encode(serialized), base64Encode(bytes));
  }

  Future<SignatureWithBytes> signTransaction(Uint8List bytes) {
    return signWithIntent(bytes, IntentScope.transactionData);
  }

  Future<SignatureWithBytes> signPersonalMessage(Uint8List bytes) {
    return signWithIntent(
      Bcs.vector(Bcs.u8()).serialize(bytes).toBytes(),
      IntentScope.personalMessage,
    );
  }

  /// Signs [message] and returns every public key (up to 4) that could have
  /// produced the signature. Call twice with different messages and intersect
  /// the results (see [findCommonPublicKey]) to identify an existing passkey
  /// whose public key is not yet known to the wallet.
  static Future<List<PasskeyPublicKey>> signAndRecover(
    PasskeyProvider provider,
    Uint8List message,
  ) async {
    final credential = await provider.get(message);
    final clientDataHash = sha256(credential.clientDataJson);
    final payload = Uint8List.fromList([
      ...credential.authenticatorData,
      ...clientDataHash,
    ]);
    final messageHash = sha256(payload);

    final (r, s) = _decodeDerEcdsaSignature(credential.signature);
    final sig = ECSignature(r, s);
    final secp = Secp256.fromSecp256r1();

    final result = <PasskeyPublicKey>[];
    for (var i = 0; i < 4; i++) {
      try {
        final recovered = secp.recoverFromSignature(i, sig, messageHash, true);
        if (recovered != null && recovered.length == PASSKEY_PUBLIC_KEY_SIZE) {
          result.add(PasskeyPublicKey(recovered));
        }
      } catch (_) {
        continue;
      }
    }
    return result;
  }
}

/// Returns the single public key present in both lists, throwing if there is not
/// exactly one. Used with two [PasskeyKeypair.signAndRecover] results.
PasskeyPublicKey findCommonPublicKey(
  List<PasskeyPublicKey> a,
  List<PasskeyPublicKey> b,
) {
  final matches = <PasskeyPublicKey>[];
  for (final x in a) {
    for (final y in b) {
      if (x.equals(y)) matches.add(x);
    }
  }
  if (matches.length != 1) {
    throw ArgumentError('No unique public key found');
  }
  return matches.first;
}

(BigInt, BigInt) _decodeDerEcdsaSignature(Uint8List der) {
  var i = 0;

  int readByte() {
    if (i >= der.length) throw ArgumentError('Invalid DER signature');
    return der[i++];
  }

  int readLength() {
    final length = readByte();
    if (length >= 0x80) throw ArgumentError('Invalid DER signature');
    return length;
  }

  BigInt readInteger() {
    if (readByte() != 0x02) throw ArgumentError('Invalid DER signature');
    final length = readLength();
    if (length == 0 || i + length > der.length) {
      throw ArgumentError('Invalid DER signature');
    }
    final bytes = Uint8List.sublistView(der, i, i + length);
    i += length;
    if (bytes[0] & 0x80 != 0 ||
        (bytes.length > 1 && bytes[0] == 0 && bytes[1] & 0x80 == 0)) {
      throw ArgumentError('Invalid DER signature');
    }
    final value = decodeBigIntToUnsigned(bytes);
    if (value == BigInt.zero) throw ArgumentError('Invalid DER signature');
    return value;
  }

  if (readByte() != 0x30 || readLength() != der.length - i) {
    throw ArgumentError('Invalid DER signature');
  }
  final r = readInteger();
  final s = readInteger();
  if (i != der.length) throw ArgumentError('Invalid DER signature');
  return (r, s);
}
