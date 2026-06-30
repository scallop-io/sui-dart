import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:sui_dart/sui.dart';
import 'package:bcs_dart/bcs.dart';

void main() {
  group('hardened struct-tag parsing', () {
    test('rejects malformed struct tags', () {
      expect(() => parseStructTag('::foo::Bar'), throwsArgumentError);
      expect(() => parseStructTag('0x2::coin'), throwsArgumentError);
      expect(() => parseStructTag('0x2::coin::Coin<u8>GARBAGE'), throwsArgumentError);
    });

    test('parses a valid struct tag', () {
      final t = parseStructTag('0x2::coin::Coin<0x2::sui::SUI>');
      expect(t.module, 'coin');
      expect(t.name, 'Coin');
    });

    test('parseTypeTag handles vector<struct>', () {
      final r = parseTypeTag('vector<0x2::sui::SUI>');
      expect(r is String, true);
      expect((r as String).startsWith('vector<0x'), true);
      expect(r.endsWith('::sui::SUI>'), true);
    });

    test('parseTypeTag rejects malformed vectors', () {
      expect(() => parseTypeTag('vector<'), throwsArgumentError);
      expect(() => parseTypeTag('vector<>'), throwsArgumentError);
    });

    test('normalizeStructTagString rejects top-level vector', () {
      expect(() => normalizeStructTagString('vector<0x2::sui::SUI>'),
          throwsArgumentError);
    });

    test('isValidStructTag', () {
      expect(isValidStructTag('0x2::coin::Coin<0x2::sui::SUI>'), true);
      expect(isValidStructTag('::foo::Bar'), false);
      expect(isValidStructTag('not a type'), false);
    });
  });

  group('base58 digest validation', () {
    test('accepts a real base58 32-byte digest, rejects junk', () {
      final digest = toB58(Uint8List.fromList(List<int>.filled(32, 7)));
      expect(isValidTransactionDigest(digest), true);
      expect(isValidTransactionDigest('not-base58-0OIl'), false);
      // 31 bytes is wrong length
      expect(
          isValidTransactionDigest(
              toB58(Uint8List.fromList(List<int>.filled(31, 7)))),
          false);
    });
  });

  group('format / parse units', () {
    test('parseToUnits', () {
      expect(parseToUnits('1.5', 9), BigInt.from(1500000000));
      expect(parseToUnits('0', 9), BigInt.zero);
      expect(parseToUnits('-2', 0), BigInt.from(-2));
      expect(() => parseToUnits('1.0000000001', 9), throwsArgumentError);
      expect(() => parseToUnits('abc', 9), throwsArgumentError);
    });

    test('parseToMist', () {
      expect(parseToMist('1'), BigInt.from(1000000000));
    });

    test('formatAddress / formatDigest', () {
      final a = formatAddress('0x${'a' * 64}');
      expect(a.startsWith('0xaaaa'), true);
      expect(a.endsWith('aaaa'), true);
      expect(formatDigest('ABCDEFGHIJKLMNOP').startsWith('ABCDEFGHIJ'), true);
    });
  });

  group('move registry', () {
    test('isValidNamedPackage', () {
      expect(isValidNamedPackage('@org/app'), true);
      expect(isValidNamedPackage('@org/app/1'), true);
      expect(isValidNamedPackage('0x2'), false);
      expect(isValidNamedPackage('@org/app/x'), false);
    });
  });
}
