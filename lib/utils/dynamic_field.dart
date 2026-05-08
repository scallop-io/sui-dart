import 'dart:typed_data';

import 'package:sui_dart/bcs/sui_bcs.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/utils/hex.dart';
import 'package:sui_dart/utils/sha.dart';

/// `HashingIntentScope::ChildObjectId` domain separator.
const int _kHashingIntentChildObjectId = 0xf0;

/// Deterministic UID of a dynamic field. Lets callers `getObject(uid)`
/// directly instead of paginating `listDynamicFields`.
///
/// BLAKE2b-256 of: `0xf0 || parent (32) || keyLen (u64 LE) || keyBcs || typeTagBcs`.
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
