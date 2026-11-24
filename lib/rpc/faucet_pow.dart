import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/key_derivators/api.dart' show Argon2Parameters;
import 'package:pointycastle/key_derivators/argon2.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/utils/hex.dart';

final _u64 = BigInt.one << 64;
final _u64Pattern = RegExp(r'^(0|[1-9][0-9]{0,19})$');

BigInt? parseFaucetU64(Object? value) {
  if (value is! String || !_u64Pattern.hasMatch(value)) return null;
  final parsed = BigInt.parse(value);
  return parsed < _u64 ? parsed : null;
}

final _addressPattern = RegExp(r'^0x[0-9a-f]{64}$');
final _base64Pattern = RegExp(
  r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$',
);

// refuse anything else, so a server can't force huge work
const _fixed = {
  'version': 1,
  'domain': 'sui-faucet-pow/1',
  'algorithm': 'argon2d',
  'argon2Version': 19,
  'salt': 'sui-faucet-pow-1',
  'memorySize': 8192,
  'iterations': 1,
  'parallelism': 1,
  'hashLength': 32,
};

class FaucetChallenge {
  FaucetChallenge._(this.json, this.threshold, this.windowSeconds);

  final Map<String, dynamic> json;
  final BigInt threshold;
  final int windowSeconds;

  String get recipient => json['recipient'];
  String get checkpointSeq => json['checkpointSeq'];

  factory FaucetChallenge.fromJson(dynamic data) {
    if (data is! Map) throw const FormatException('Invalid faucet challenge');
    final json = Map<String, dynamic>.from(data);
    BigInt u64(String key) {
      final v = json[key];
      if (v is! String || !_u64Pattern.hasMatch(v)) {
        throw FormatException('Invalid faucet challenge $key');
      }
      final n = BigInt.parse(v);
      if (n >= _u64) throw FormatException('Invalid faucet challenge $key');
      return n;
    }

    void check(bool ok, String key) {
      if (!ok) throw FormatException('Invalid faucet challenge $key');
    }

    _fixed.forEach((k, v) => check(json[k] == v, k));
    for (final k in ['chainId', 'checkpointDigest']) {
      final v = json[k];
      check(v is String && v.length <= 44 && isValidTransactionDigest(v), k);
    }
    for (final k in ['faucetAddress', 'recipient']) {
      check(json[k] is String && _addressPattern.hasMatch(json[k]), k);
    }
    final random = json['randomBytes'];
    check(
      random is String &&
          random.length <= 1024 &&
          _base64Pattern.hasMatch(random),
      'randomBytes',
    );
    u64('checkpointSeq');
    check(u64('amountMist') > BigInt.zero, 'amountMist');
    final difficulty = u64('difficulty');
    check(
      difficulty >= BigInt.two && difficulty <= BigInt.one << 48,
      'difficulty',
    );
    final threshold = u64('threshold');
    check(threshold == _u64 ~/ difficulty, 'threshold');
    final window = json['windowSeconds'];
    check(window is int && window >= 1, 'windowSeconds');
    return FaucetChallenge._(json, threshold, window);
  }

  Uint8List hash(BigInt nonce) {
    final preimage = [
      json['domain'],
      json['chainId'],
      json['checkpointSeq'],
      json['checkpointDigest'],
      json['randomBytes'],
      json['faucetAddress'],
      json['recipient'],
      nonce.toString(),
    ].join('\n');
    final generator = Argon2BytesGenerator()
      ..init(
        Argon2Parameters(
          Argon2Parameters.ARGON2_d,
          Uint8List.fromList(utf8.encode(json['salt'])),
          desiredKeyLength: 32,
          iterations: 1,
          memory: 8192,
          lanes: 1,
          version: Argon2Parameters.ARGON2_VERSION_13,
        ),
      );
    return generator.process(Uint8List.fromList(utf8.encode(preimage)));
  }

  /// Wants the first 8 hash bytes, big-endian, under [threshold]; null past [deadline].
  Future<({String nonce, String hashHex})?> solve(
    BigInt nonce,
    DateTime deadline, {
    bool Function()? isCancelled,
  }) async {
    while (DateTime.now().isBefore(deadline)) {
      if (isCancelled?.call() ?? false) return null;
      final digest = hash(nonce);
      // yield so a UI isolate keeps drawing between hashes
      await Future<void>.delayed(Duration.zero);
      if (!DateTime.now().isBefore(deadline)) break;
      // BigInt, not getUint64: the web has no 64-bit ints
      final head = BigInt.parse(Hex.encode(digest.sublist(0, 8)), radix: 16);
      if (head < threshold) {
        return (nonce: nonce.toString(), hashHex: Hex.encode(digest));
      }
      nonce = (nonce + BigInt.one) % _u64;
    }
    return null;
  }
}
