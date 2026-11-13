import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:sui_dart/http/http.dart';
import 'package:sui_dart/rpc/faucet_pow.dart';
import 'package:sui_dart/sui.dart';
import 'package:sui_dart/utils/hex.dart';
import 'package:test/test.dart';

const _recipient =
    '0x936accb491f0facaac668baaedcf4d0cfc6da1120b66f77fa6a43af718669973';
const _digest = '6oH779AUs2WpwW77xCVGbYqK1FYVamRqHjV6A5wCV8Qj';

Map<String, dynamic> _challenge({String difficulty = '2'}) => {
  'version': 1,
  'domain': 'sui-faucet-pow/1',
  'algorithm': 'argon2d',
  'argon2Version': 19,
  'salt': 'sui-faucet-pow-1',
  'memorySize': 8192,
  'iterations': 1,
  'parallelism': 1,
  'hashLength': 32,
  'chainId': _digest,
  'checkpointSeq': '42',
  'checkpointDigest': _digest,
  'randomBytes': 'AAECAw==',
  'faucetAddress': '0x${'1' * 64}',
  'recipient': _recipient,
  'difficulty': difficulty,
  'threshold': ((BigInt.one << 64) ~/ BigInt.parse(difficulty)).toString(),
  'windowSeconds': 60,
  'amountMist': '1000000000',
};

class _Faucet implements HttpClientAdapter {
  _Faucet(this.routes);

  final Map<String, (int, Object)> routes;
  final posted = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.data != null) {
      posted.add(Map<String, dynamic>.from(options.data as Map));
    }
    final (status, body) = routes[options.uri.path]!;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final defaultAdapter = http.httpClientAdapter;
  tearDown(() => http.httpClientAdapter = defaultAdapter);

  _Faucet serve(Map<String, (int, Object)> routes) {
    final faucet = _Faucet(routes);
    http.httpClientAdapter = faucet;
    return faucet;
  }

  final gasOk = (
    200,
    {
      'status': 'success',
      'digest': _digest,
      'recipient': _recipient,
      'amountMist': '1000000000',
      'difficulty': '2',
    },
  );

  test('argon2d proof hash matches the reference implementation', () {
    final challenge = FaucetChallenge.fromJson(_challenge());
    expect(
      Hex.encode(challenge.hash(BigInt.zero)),
      '503fe203845b6bca1161f2af815745e976f4855eb49fa70de579d7ea7d7e49d3',
    );
    expect(
      Hex.encode(challenge.hash((BigInt.one << 64) - BigInt.one)),
      'bef5dab2a291d0d4bbc2135d353efb9e52e208e7e1602df8aff2af5b6723a3c6',
    );
  });

  test('rejects challenges outside the protocol', () {
    for (final bad in <Map<String, dynamic>>[
      {..._challenge(), 'memorySize': 1 << 22},
      {..._challenge(), 'iterations': 100},
      {..._challenge(), 'threshold': '1'},
      {..._challenge(difficulty: '1')},
      {..._challenge(), 'recipient': '0xabc'},
      {..._challenge(), 'checkpointDigest': 'not-a-digest'},
    ]) {
      expect(() => FaucetChallenge.fromJson(bad), throwsFormatException);
    }
  });

  test('solves the challenge and submits the proof once', () async {
    final faucet = serve({
      '/v3/challenge': (200, _challenge()),
      '/v3/gas': gasOk,
    });

    final res = await FaucetClient(
      SuiUrls.faucetTest,
    ).requestSuiFromFaucetV3(_recipient);

    expect(res.digest, _digest);
    expect(res.amountMist, BigInt.from(1000000000));
    final body = faucet.posted.single;
    expect(body['recipient'], _recipient);
    expect(body['checkpointSeq'], '42');
    final hash = Hex.decode(body['hashHex']);
    final head = BigInt.parse(Hex.encode(hash.sublist(0, 8)), radix: 16);
    expect(head < BigInt.one << 63, isTrue);
    expect(
      Hex.encode(
        FaucetChallenge.fromJson(
          _challenge(),
        ).hash(BigInt.parse(body['nonce'])),
      ),
      body['hashHex'],
    );
  });

  test('HTTP errors keep the faucet code and digest', () async {
    serve({
      '/v3/challenge': (200, _challenge()),
      '/v3/gas': (
        409,
        {'error': 'already paid', 'code': 'DUPLICATE', 'digest': _digest},
      ),
    });

    await expectLater(
      FaucetClient(SuiUrls.faucetTest).requestSuiFromFaucetV3(_recipient),
      throwsA(
        isA<FaucetError>()
            .having((e) => e.status, 'status', 409)
            .having((e) => e.code, 'code', 'DUPLICATE')
            .having((e) => e.digest, 'digest', _digest),
      ),
    );
  });

  test('HTTP 429 becomes FaucetRateLimitError', () async {
    serve({'/v3/challenge': (429, {})});
    await expectLater(
      FaucetClient(SuiUrls.faucetTest).requestSuiFromFaucetV3(_recipient),
      throwsA(isA<FaucetRateLimitError>()),
    );
  });

  test('gives up with TimeoutException on an unsolvable challenge', () async {
    serve({
      '/v3/challenge': (200, _challenge(difficulty: '${1 << 48}')),
      '/v3/gas': gasOk,
    });
    await expectLater(
      FaucetClient(SuiUrls.faucetTest).requestSuiFromFaucetV3(
        _recipient,
        timeout: const Duration(milliseconds: 300),
      ),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('rejects an empty recipient before any request', () {
    expect(
      () => FaucetClient(SuiUrls.faucetTest).requestSuiFromFaucetV3('0x'),
      throwsArgumentError,
    );
  });
}
