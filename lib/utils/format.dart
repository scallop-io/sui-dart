// ignore_for_file: non_constant_identifier_names
import 'package:sui_dart/types/framework.dart' show SUI_DECIMALS;

const _ellipsis = '…';

/// Shorten an address to `0xXXXX…XXXX` for display.
String formatAddress(String address) {
  if (address.length <= 6) {
    return address;
  }

  final offset = address.startsWith('0x') ? 2 : 0;

  return '0x${address.substring(offset, offset + 4)}$_ellipsis${address.substring(address.length - 4)}';
}

/// Shorten a digest to its first 10 characters followed by an ellipsis.
String formatDigest(String digest) {
  return '${digest.substring(0, 10)}$_ellipsis';
}

final _amountRegex = RegExp(r'^-?(?:[0-9]+(?:\.[0-9]+)?|\.[0-9]+)$');

/// Parse a decimal string to smallest-unit [BigInt] (pure BigInt, no float).
BigInt parseToUnits(String amount, int decimals) {
  if (decimals < 0) {
    throw ArgumentError('Invalid decimals: $decimals');
  }

  if (!_amountRegex.hasMatch(amount)) {
    throw ArgumentError('Invalid amount: "$amount"');
  }

  final negative = amount.startsWith('-');
  final stripped = negative ? amount.substring(1) : amount;

  final parts = stripped.split('.');
  final whole = parts[0];
  final fraction = parts.length > 1 ? parts[1] : '';

  if (fraction.length > decimals) {
    throw ArgumentError(
      'Too many decimal places: "$amount" has ${fraction.length} but max is $decimals',
    );
  }

  final paddedFraction = fraction.padRight(decimals, '0');
  final wholePart = whole.isEmpty ? BigInt.zero : BigInt.parse(whole);
  final fractionPart =
      paddedFraction.isEmpty ? BigInt.zero : BigInt.parse(paddedFraction);
  final result = wholePart * BigInt.from(10).pow(decimals) + fractionPart;

  return negative ? -result : result;
}

/// Parse a SUI decimal string into MIST.
BigInt parseToMist(String amount) {
  return parseToUnits(amount, SUI_DECIMALS);
}
