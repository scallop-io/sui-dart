// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:sui_dart/sui.dart';
import 'package:sui_dart/utils/hex.dart';
import 'package:sui_dart/utils/sha.dart';

class PublicKeyWeight {
  int weight;
  PublicKey publicKey;

  PublicKeyWeight(this.weight, this.publicKey);
}

class PubkeyEnumWeightPair {
  Map pubKey;
  int weight;

  PubkeyEnumWeightPair(this.pubKey, this.weight);

  factory PubkeyEnumWeightPair.fromJson(Map<String, dynamic> data) {
    return PubkeyEnumWeightPair(data["pubKey"], data["weight"]);
  }

  Map<String, dynamic> toJson() {
    return {"pubKey": pubKey, "weight": weight};
  }
}

class MultiSigPublicKeyStruct {
  List<PubkeyEnumWeightPair> pks;
  int threshold;

  MultiSigPublicKeyStruct(this.pks, this.threshold);

  factory MultiSigPublicKeyStruct.fromJson(Map<String, dynamic> data) {
    var tmp = <PubkeyEnumWeightPair>[];
    if (data["pk_map"] is Iterable) {
      tmp = data["pk_map"]
          .map<PubkeyEnumWeightPair>((x) => PubkeyEnumWeightPair.fromJson(x))
          .toList();
    }

    return MultiSigPublicKeyStruct(tmp, data["threshold"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "pk_map": pks.map((pk) => pk.toJson()).toList(),
      "threshold": threshold,
    };
  }
}

class MultiSigStruct {
  List<Map<String, dynamic>> sigs;
  int bitmap;
  MultiSigPublicKeyStruct multisigPK;

  MultiSigStruct(this.sigs, this.bitmap, this.multisigPK);

  factory MultiSigStruct.fromJson(Map<String, dynamic> data) {
    return MultiSigStruct(
      (data["sigs"] as List).map((e) => Map<String, dynamic>.of(e)).toList(),
      data["bitmap"],
      MultiSigPublicKeyStruct.fromJson(data["multisig_pk"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {"sigs": sigs, "bitmap": bitmap, "multisig_pk": multisigPK};
  }
}

class ParsedPartialMultiSigSignature {
  SignatureScheme signatureScheme;
  Uint8List signature;
  PublicKey publicKey;
  int weight;

  ParsedPartialMultiSigSignature({
    required this.signatureScheme,
    required this.signature,
    required this.publicKey,
    required this.weight,
  });
}

const MAX_SIGNER_IN_MULTISIG = 10;
const MIN_SIGNER_IN_MULTISIG = 1;

class MultiSigPublicKey with PublicKey {
  late Uint8List _rawBytes;
  late MultiSigPublicKeyStruct _multisigPublicKey;

  late final List<PublicKeyWeight> publicKeys;

  MultiSigPublicKey(MultiSigPublicKeyStruct value) {
    _multisigPublicKey = value;
    _rawBytes = SuiBcs.MultiSigPublicKey.serialize(value.toJson()).toBytes();

    if (_multisigPublicKey.threshold < 1) {
      throw ArgumentError("Invalid threshold");
    }

    final seenPublicKeys = <String>{};

    publicKeys = _multisigPublicKey.pks.map((e) {
      final scheme = e.pubKey.keys.first;
      final bytes = e.pubKey[scheme].cast<int>();
      final publicKeyStr = Uint8List.fromList(bytes).toString();

      if (seenPublicKeys.contains(publicKeyStr)) {
        throw ArgumentError("Multisig does not support duplicate public keys");
      }
      seenPublicKeys.add(publicKeyStr);

      if (e.weight < 1) {
        throw ArgumentError("Invalid weight");
      }
      return PublicKeyWeight(
        e.weight,
        publicKeyFromRawBytes(scheme, Uint8List.fromList(bytes)),
      );
    }).toList();

    final totalWeight = publicKeys.isEmpty
        ? 0
        : publicKeys.map((p) => p.weight).reduce((x, y) => x + y);

    if (_multisigPublicKey.threshold > totalWeight) {
      throw ArgumentError("Unreachable threshold");
    }

    if (publicKeys.length > MAX_SIGNER_IN_MULTISIG) {
      throw ArgumentError(
        "Max number of signers in a multisig is $MAX_SIGNER_IN_MULTISIG",
      );
    }

    if (publicKeys.length < MIN_SIGNER_IN_MULTISIG) {
      throw ArgumentError(
        "Min number of signers in a multisig is $MIN_SIGNER_IN_MULTISIG",
      );
    }
  }

  factory MultiSigPublicKey.fromPublicKeys({
    required int threshold,
    required List<PublicKeyWeight> publicKeys,
  }) {
    final pubKeyStruct = MultiSigPublicKeyStruct(
      publicKeys.map((e) {
        final scheme = SIGNATURE_SCHEME_TO_FLAG.flagToScheme(
          e.publicKey.flag(),
        );
        return PubkeyEnumWeightPair({
          scheme.name: e.publicKey.toRawBytes(),
        }, e.weight);
      }).toList(),
      threshold,
    );
    return MultiSigPublicKey(pubKeyStruct);
  }

  factory MultiSigPublicKey.fromBytes(Uint8List publicKey) {
    final pubkeyStruct = MultiSigPublicKeyStruct.fromJson(
      SuiBcs.MultiSigPublicKey.parse(publicKey),
    );
    return MultiSigPublicKey(pubkeyStruct);
  }

  @override
  int flag() {
    return SIGNATURE_SCHEME_TO_FLAG.MultiSig;
  }

  @override
  String toBase64() {
    return base64Encode(toRawBytes());
  }

  @override
  Uint8List toRawBytes() {
    return _rawBytes;
  }

  /// The threshold required for this multisig public key.
  int getThreshold() {
    return _multisigPublicKey.threshold;
  }

  /// The member public keys and their weights.
  List<PublicKeyWeight> getPublicKeys() {
    return publicKeys;
  }

  @override
  String toSuiAddress() {
    final suiBytes = publicKeys.map((p) => p.publicKey.toSuiBytes()).toList();
    // flag + u16 threshold + (flagged key, u8 weight) per member
    final tmp = Uint8List(
      3 + suiBytes.fold<int>(0, (sum, b) => sum + b.length + 1),
    );
    tmp.setAll(0, [SIGNATURE_SCHEME_TO_FLAG.MultiSig]);
    tmp.setAll(1, Bcs.u16().serialize(_multisigPublicKey.threshold).toBytes());
    int i = 3;
    for (var j = 0; j < publicKeys.length; j++) {
      tmp.setAll(i, suiBytes[j]);
      i += suiBytes[j].length;
      tmp[i++] = publicKeys[j].weight;
    }
    return normalizeSuiAddress(Hex.encode(blake2b(tmp)));
  }

  @override
  bool verify(Uint8List data, Uint8List signature) {
    // Only serialized signatures are supported.
    final sig = parseSerializedSignature(base64Encode(signature));
    final signatureScheme = sig.signatureScheme;
    final multisig = sig.multisig;

    if (signatureScheme != SignatureScheme.MultiSig) {
      throw ArgumentError("Invalid signature scheme");
    }

    int signatureWeight = 0;

    if (!bytesEqual(
      _rawBytes,
      SuiBcs.MultiSigPublicKey.serialize(
        multisig!.multisigPK.toJson(),
      ).toBytes(),
    )) {
      return false;
    }

    final List<ParsedPartialMultiSigSignature> parseSig;
    try {
      parseSig = parsePartialSignatures(multisig);
    } on FormatException {
      // a member signature of another scheme: not valid, not malformed
      return false;
    }
    for (var item in parseSig) {
      final publicKey = item.publicKey;
      final weight = item.weight;
      final signature = item.signature;

      if (!(publicKey.verify(data, signature))) {
        return false;
      }

      signatureWeight += weight;
    }

    return signatureWeight >= _multisigPublicKey.threshold;
  }

  /// Combines partial signatures into one serialized multisig, requiring each public key to be known and to sign at most once.
  String combinePartialSignatures(List<String> signatures) {
    if (signatures.length > MAX_SIGNER_IN_MULTISIG) {
      throw ArgumentError(
        "Max number of signatures in a multisig is $MAX_SIGNER_IN_MULTISIG",
      );
    }

    var bitmap = 0;
    final compressedSignatures = <Map<String, Uint8List>>[];

    for (int i = 0; i < signatures.length; i++) {
      final parsed = parseSerializedSignature(signatures[i]);
      if (parsed.signatureScheme == SignatureScheme.MultiSig) {
        throw ArgumentError("MultiSig is not supported inside MultiSig");
      }

      Uint8List publicKey;
      if (parsed.signatureScheme == SignatureScheme.ZkLogin) {
        // Match whichever zkLogin encoding (legacy or current) this multisig knows.
        final nonLegacy = toZkLoginPublicIdentifier(
          parsed.zkLogin!["addressSeed"],
          parsed.zkLogin!["iss"],
          legacyAddress: false,
        ).toRawBytes();
        final legacy = toZkLoginPublicIdentifier(
          parsed.zkLogin!["addressSeed"],
          parsed.zkLogin!["iss"],
          legacyAddress: true,
        ).toRawBytes();
        publicKey =
            publicKeys.any((p) => bytesEqual(legacy, p.publicKey.toRawBytes()))
            ? legacy
            : nonLegacy;
      } else {
        publicKey = parsed.pubKey!.toRawBytes();
      }

      compressedSignatures.add({parsed.signatureScheme.name: parsed.signature});

      int? publicKeyIndex;
      for (int j = 0; j < publicKeys.length; j++) {
        if (parsed.signatureScheme ==
                SIGNATURE_SCHEME_TO_FLAG.flagToScheme(
                  publicKeys[j].publicKey.flag(),
                ) &&
            bytesEqual(publicKey, publicKeys[j].publicKey.toRawBytes())) {
          if (bitmap & (1 << j) != 0) {
            throw ArgumentError(
              "Received multiple signatures from the same public key",
            );
          }

          publicKeyIndex = j;
          break;
        }
      }

      if (publicKeyIndex == null) {
        throw ArgumentError("Received signature from unknown public key");
      }

      bitmap |= 1 << publicKeyIndex;
    }

    final multisig = {
      "sigs": compressedSignatures,
      "bitmap": bitmap,
      "multisig_pk": _multisigPublicKey.toJson(),
    };
    final bytes = SuiBcs.MultiSig.serialize(
      multisig,
      // ten ML-DSA-65 members are ~53 KB
      options: BcsWriterOptions(maxSize: 65536),
    ).toBytes();
    var tmp = Uint8List(bytes.length + 1);
    tmp.setAll(0, [SIGNATURE_SCHEME_TO_FLAG.MultiSig]);
    tmp.setAll(1, bytes);
    return base64Encode(tmp);
  }
}

/// Parses a multisig into its individual signatures (scheme, signature, public key, weight).
List<ParsedPartialMultiSigSignature> parsePartialSignatures(
  MultiSigStruct multisig,
) {
  final sigs = multisig.sigs;
  final len = sigs.length;
  final indices = asIndices(multisig.bitmap);
  if (indices.length != len) {
    throw ArgumentError('Signature count does not match bitmap');
  }
  final res = <ParsedPartialMultiSigSignature>[];
  for (int i = 0; i < len; i++) {
    final sss = sigs[i].entries.first;
    final signatureScheme = sss.key;
    final signature = sss.value.cast<int>();
    final pkIndex = indices[i];
    if (pkIndex >= multisig.multisigPK.pks.length) {
      throw ArgumentError('Bitmap references an unknown public key');
    }
    final pair = multisig.multisigPK.pks[pkIndex];
    final publicKeyEntry = pair.pubKey.entries.first;
    final publicKeyScheme = publicKeyEntry.key;
    final pkBytes = publicKeyEntry.value.cast<int>();

    if (signatureScheme == SignatureScheme.MultiSig.name) {
      throw ArgumentError("MultiSig is not supported inside MultiSig");
    }
    if (signatureScheme != publicKeyScheme) {
      throw const FormatException('Signature scheme does not match public key');
    }

    final publicKey = publicKeyFromRawBytes(
      publicKeyScheme,
      Uint8List.fromList(pkBytes),
    );

    final parsedSign = ParsedPartialMultiSigSignature(
      signatureScheme: SignatureScheme.values.byName(signatureScheme),
      signature: Uint8List.fromList(signature),
      publicKey: publicKey,
      weight: pair.weight,
    );
    res.add(parsedSign);
  }
  return res;
}

Uint8List asIndices(int bitmap) {
  if (bitmap < 0 || bitmap >= 1 << MAX_SIGNER_IN_MULTISIG) {
    throw ArgumentError('Invalid bitmap');
  }
  final res = <int>[];
  for (int i = 0; i < 10; i++) {
    if ((bitmap & (1 << i)) != 0) {
      res.add(i);
    }
  }
  return Uint8List.fromList(res);
}

PublicKey publicKeyFromRawBytes(
  String signatureScheme,
  Uint8List bytes, {
  String? address,
}) {
  if (address != null) address = normalizeSuiAddress(address);
  final PublicKey publicKey;
  switch (signatureScheme) {
    case "Ed25519":
      publicKey = Ed25519PublicKey.fromBytes(bytes);
    case "Secp256k1":
      publicKey = Secp256PublicKey.fromBytes(
        bytes,
        SIGNATURE_SCHEME_TO_FLAG.Secp256k1,
      );
    case "Secp256r1":
      publicKey = Secp256PublicKey.fromBytes(
        bytes,
        SIGNATURE_SCHEME_TO_FLAG.Secp256r1,
      );
    case "MultiSig":
      publicKey = MultiSigPublicKey.fromBytes(bytes);
    case "ZkLogin":
      // A supplied address disambiguates legacy vs current zkLogin derivation; else auto-detect.
      publicKey = ZkLoginPublicIdentifier.fromBytes(bytes, address: address);
    case "Passkey":
      publicKey = PasskeyPublicKey(bytes);
    case "MLDSA65":
      publicKey = MLDSA65PublicKey(bytes);
    default:
      throw ArgumentError("Unsupported signature scheme $signatureScheme");
  }
  if (address != null && publicKey.toSuiAddress() != address) {
    throw ArgumentError('Public key bytes do not match the provided address');
  }
  return publicKey;
}
