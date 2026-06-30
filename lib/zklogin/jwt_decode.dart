import 'dart:convert';

/// Thrown when a JWT cannot be decoded.
class InvalidTokenError implements Exception {
  final String message;
  InvalidTokenError(this.message);

  @override
  String toString() => 'InvalidTokenError: $message';
}

/// Decode a JWT without verifying its signature. Returns the payload, or the
/// header when [header] is true.
Map<String, dynamic> jwtDecode(String token, {bool header = false}) {
  final pos = header ? 0 : 1;
  final parts = token.split('.');

  if (parts.length <= pos) {
    throw InvalidTokenError('Invalid token specified: missing part #${pos + 1}');
  }

  String decoded;
  try {
    decoded = _base64UrlDecode(parts[pos]);
  } catch (e) {
    throw InvalidTokenError(
      'Invalid token specified: invalid base64 for part #${pos + 1} ($e)',
    );
  }

  try {
    return jsonDecode(decoded) as Map<String, dynamic>;
  } catch (e) {
    throw InvalidTokenError(
      'Invalid token specified: invalid json for part #${pos + 1} ($e)',
    );
  }
}

String _base64UrlDecode(String str) {
  var output = str.replaceAll('-', '+').replaceAll('_', '/');
  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw const FormatException('base64 string is not of the correct length');
  }
  return utf8.decode(base64.decode(output));
}
