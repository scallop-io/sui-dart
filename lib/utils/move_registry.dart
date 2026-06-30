import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/utils/suins.dart';

final _namePattern = RegExp(r'^([a-z0-9]+(?:-[a-z0-9]+)*)$');
final _versionRegex = RegExp(r'^\d+$');
const _maxAppSize = 64;
const _nameSeparator = '/';

/// Whether [name] is a valid Move Registry (MVR) package name, e.g.
/// `@org/app` or `@org/app/1`.
bool isValidNamedPackage(String name) {
  final parts = name.split(_nameSeparator);
  // 2 parts (no version) or 3 (with version).
  if (parts.length < 2 || parts.length > 3) return false;

  final org = parts[0];
  final app = parts[1];
  final version = parts.length > 2 ? parts[2] : null;

  if (version != null && !_versionRegex.hasMatch(version)) return false;
  if (!isValidSuiNSName(org)) return false;
  return _namePattern.hasMatch(app) && app.length < _maxAppSize;
}

/// Whether [type] contains valid named packages and is a valid Move struct tag.
bool isValidNamedType(String type) {
  final splitType = type.split(RegExp(r'::|<|>|,'));
  for (final t in splitType) {
    if (t.contains(_nameSeparator) && !isValidNamedPackage(t)) return false;
  }
  return isValidStructTag(type);
}
