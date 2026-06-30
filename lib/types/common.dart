// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:bcs_dart/bcs.dart' show fromB58;
import 'package:sui_dart/utils/move_registry.dart';
import 'sui_bcs.dart';

/// Base58 string representing the object digest
typedef TransactionDigest = String;
typedef SuiAddress = String;

class Shared {
  int initialSharedVersion;

  Shared(this.initialSharedVersion);

  factory Shared.fromJson(dynamic data) {
    return Shared(data['initial_shared_version']);
  }
}

class ObjectOwner {
  SuiAddress? addressOwner;
  SuiAddress? objectOwner;
  Shared? shared;
  bool immutable;

  ObjectOwner(this.addressOwner, this.objectOwner, this.shared, this.immutable);

  factory ObjectOwner.fromJson(dynamic data) {
    if (data is String && data == 'Immutable') {
      return ObjectOwner(null, null, null, true);
    }

    return ObjectOwner(
      data['AddressOwner'],
      data['ObjectOwner'],
      data['Shared'] != null ? Shared.fromJson(data['Shared']) : null,
      false,
    );
  }
}

// Source: sui-types/src/base_types.rs#L171 (acb2b97).
const TX_DIGEST_LENGTH = 32;

/// True if value is a valid tx digest (Base58-encoded 32 bytes).
bool isValidTransactionDigest(String value) {
  try {
    return fromB58(value).length == TX_DIGEST_LENGTH;
  } catch (_) {
    return false;
  }
}

// TODO - can we automatically sync this with rust length definition?
// Source: sui-types/src/base_types.rs#L67 (acb2b97), the Move account address length.
const SUI_ADDRESS_LENGTH = 32;

bool isValidSuiAddress(String value) {
  return isHex(value) && getHexByteLength(value) == SUI_ADDRESS_LENGTH;
}

bool isValidSuiObjectId(String value) {
  return isValidSuiAddress(value);
}

List<String> splitGenericParameters(
  String str, [
  (String, String) genericSeparators = ('<', '>'),
]) {
  final (left, right) = genericSeparators;
  final tok = <String>[];
  String word = '';
  int nestedAngleBrackets = 0;

  for (int i = 0; i < str.length; i++) {
    final char = str[i];
    if (char == left) {
      nestedAngleBrackets++;
    }
    if (char == right) {
      nestedAngleBrackets--;
    }
    if (nestedAngleBrackets == 0 && char == ',') {
      tok.add(word.trim());
      word = '';
      continue;
    }
    word += char;
  }

  tok.add(word.trim());

  return tok;
}

dynamic parseTypeTag(String type) {
  if (type.startsWith('vector<')) {
    if (!type.endsWith('>')) {
      throw ArgumentError('Invalid type tag: $type');
    }
    final inner = type.substring(7, type.length - 1);
    if (inner.isEmpty) {
      throw ArgumentError('Invalid type tag: $type');
    }
    final parsed = parseTypeTag(inner);
    if (parsed is String) {
      return 'vector<$parsed>';
    }
    return 'vector<${normalizeStructTag(parsed)}>';
  }

  if (!type.contains('::')) return type;

  return parseStructTag(type);
}

StructTag parseStructTag(String type) {
  final parts = type.split('::');

  if (parts.length < 3) {
    throw ArgumentError('Invalid struct tag: $type');
  }

  final address = parts[0];
  final module = parts[1];

  if (address.isEmpty || module.isEmpty) {
    throw ArgumentError('Invalid struct tag: $type');
  }

  final isMvrPackage = isValidNamedPackage(address);

  final rest = type.substring(address.length + module.length + 4);
  final name = rest.contains('<') ? rest.substring(0, rest.indexOf('<')) : rest;

  if (name.isEmpty || (rest.contains('<') && !rest.endsWith('>'))) {
    throw ArgumentError('Invalid struct tag: $type');
  }

  final typeParams = rest.contains('<')
      ? splitGenericParameters(
          rest.substring(rest.indexOf('<') + 1, rest.lastIndexOf('>')),
        ).map((typeParam) => parseTypeTag(typeParam.trim())).toList()
      : [];

  return StructTag(
    isMvrPackage ? address : normalizeSuiAddress(address),
    module,
    name,
    typeParams,
  );
}

String normalizeStructTag(StructTag type) {
  final address = type.address;
  final module = type.module;
  final name = type.name;
  final typeParams = type.typeParams;

  final formattedTypeParams = typeParams.isNotEmpty
      ? "<${typeParams.map((typeParam) => typeParam is String ? typeParam : normalizeStructTag(typeParam)).join(',')}>"
      : "";

  return "$address::$module::$name$formattedTypeParams";
}

String normalizeStructTagString(String type) {
  if (type.startsWith('vector<')) {
    throw ArgumentError(
      'normalizeStructTag does not support vector types. Use normalizeTypeTag instead.',
    );
  }
  return normalizeStructTag(parseStructTag(type));
}

/// Lowercases, prepends `0x`, and left-pads to `SUI_ADDRESS_LENGTH`.
///
/// WARNING: a leading `0x` is stripped (e.g. `0x0x...`); pass `forceAdd0x: true` to keep it.
String normalizeSuiAddress(String value, [bool forceAdd0x = false]) {
  String address = value.toLowerCase();
  if (!forceAdd0x && address.startsWith('0x')) {
    address = address.substring(2);
  }
  return "0x${address.padLeft(SUI_ADDRESS_LENGTH * 2, '0')}";
}

String normalizeSuiObjectId(String value, [bool forceAdd0x = false]) {
  return normalizeSuiAddress(value, forceAdd0x);
}

bool isHex(String value) {
  return RegExp(r'^(0x|0X)?[a-fA-F0-9]+$').hasMatch(value) &&
      value.length % 2 == 0;
}

int getHexByteLength(String value) {
  return RegExp(r'^(0x|0X)').hasMatch(value)
      ? (value.length - 2) ~/ 2
      : value.length ~/ 2;
}

final MOVE_IDENTIFIER_REGEX = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');

bool isValidMoveIdentifier(String name) {
  return MOVE_IDENTIFIER_REGEX.hasMatch(name);
}

const PRIMITIVE_TYPE_TAGS = [
  'bool',
  'u8',
  'u16',
  'u32',
  'u64',
  'u128',
  'u256',
  'address',
  'signer',
];

final VECTOR_TYPE_REGEX = RegExp(r'^vector<(.+)>$');

bool isValidTypeTag(String type) {
  if (PRIMITIVE_TYPE_TAGS.contains(type)) return true;

  final vectorMatch = VECTOR_TYPE_REGEX.firstMatch(type);
  if (vectorMatch != null) return isValidTypeTag(vectorMatch.group(1)!);

  if (type.contains('::')) return isValidStructTag(type);

  return false;
}

bool isValidParsedStructTag(StructTag tag) {
  if (!isValidSuiAddress(tag.address) && !isValidNamedPackage(tag.address)) {
    return false;
  }

  if (!isValidMoveIdentifier(tag.module) || !isValidMoveIdentifier(tag.name)) {
    return false;
  }

  return tag.typeParams.every((param) {
    if (param is String) {
      return isValidTypeTag(param);
    }
    return isValidParsedStructTag(param as StructTag);
  });
}

bool isValidStructTag(String type) {
  try {
    final tag = parseStructTag(type);
    return isValidParsedStructTag(tag);
  } catch (_) {
    return false;
  }
}
