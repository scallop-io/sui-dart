import 'dart:typed_data';

import 'package:sui_dart/bcs/sui_bcs.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/utils/hex.dart';
import 'package:sui_dart/utils/sha.dart';

/// `HashingIntentScope::ChildObjectId` domain separator.
const int _kHashingIntentChildObjectId = 0xf0;

/// Deterministic UID of a dynamic field, for direct `getObject(uid)`.
/// BLAKE2b-256 of `0xf0 || parent (32) || keyLen (u64 LE) || keyBcs || typeTagBcs` (order is wire-significant).
String deriveDynamicFieldId({
  required String parentObjectId,
  required String keyTypeTag,
  required Uint8List keyBcs,
}) {
  final parentBytes = Hex.decode(normalizeSuiAddress(parentObjectId));
  final keyTypeTagBcs = SuiBcs.TypeTag.serialize(keyTypeTag).toBytes();

  final lenLE = ByteData(8)..setUint64(0, keyBcs.length, Endian.little);

  final input = BytesBuilder(copy: false)
    ..addByte(_kHashingIntentChildObjectId)
    ..add(parentBytes)
    ..add(lenLE.buffer.asUint8List())
    ..add(keyBcs)
    ..add(keyTypeTagBcs);

  return normalizeSuiAddress('0x${Hex.encode(blake2b(input.toBytes()))}');
}

/// Derive the ID of a `derived_object`. [key] is BCS-encoded key bytes; [typeTag] is its Move type.
String deriveObjectId({
  required String parentObjectId,
  required String typeTag,
  required Uint8List key,
}) {
  return deriveDynamicFieldId(
    parentObjectId: parentObjectId,
    keyTypeTag: '0x2::derived_object::DerivedObjectKey<$typeTag>',
    keyBcs: key,
  );
}
