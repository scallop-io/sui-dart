import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:sui_dart/http/http.dart';
import 'package:sui_dart/sui.dart';
import 'package:test/test.dart';

class _FaucetAdapter implements HttpClientAdapter {
  _FaucetAdapter(this.body, {this.statusCode = 200});

  final Map<String, dynamic> body;
  final int statusCode;
  String? lastPath;
  Map<String, dynamic>? lastData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastPath = options.path;
    lastData = options.data == null
        ? null
        : Map<String, dynamic>.from(options.data as Map);
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _recipient =
    '0x936accb491f0facaac668baaedcf4d0cfc6da1120b66f77fa6a43af718669973';

void main() {
  final defaultAdapter = http.httpClientAdapter;

  _FaucetAdapter serving(Map<String, dynamic> body, {int statusCode = 200}) {
    final adapter = _FaucetAdapter(body, statusCode: statusCode);
    http.httpClientAdapter = adapter;
    return adapter;
  }

  tearDown(() => http.httpClientAdapter = defaultAdapter);

  test('requests gas from /v2/gas and parses the coins sent', () async {
    final adapter = serving({
      'status': 'Success',
      'coins_sent': [
        {
          'amount': 1000000000,
          'id': '0xcoin',
          'transferTxDigest': '6oH779AUs2WpwW77xCVGbYqK1FYVamRqHjV6A5wCV8Qj',
        },
      ],
    });

    final response = await FaucetClient(
      SuiUrls.faucetDev,
    ).requestSuiFromFaucetV2(_recipient);

    expect(adapter.lastPath, '${SuiUrls.faucetDev}/v2/gas');
    expect(adapter.lastData, {
      'FixedAmountRequest': {'recipient': _recipient},
    });
    expect(response.isSuccess, isTrue);
    expect(response.coinsSent!.single.amount, 1000000000);
    expect(response.coinsSent!.single.id, '0xcoin');
  });

  test('a Failure status is reported with its internal reason', () async {
    serving({
      'status': {
        'Failure': {'internal': 'no coins available'},
      },
    });

    await expectLater(
      FaucetClient(SuiUrls.faucetDev).requestSuiFromFaucetV2(_recipient),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('no coins available'),
        ),
      ),
    );
  });

  test('HTTP 429 becomes FaucetRateLimitError', () async {
    serving({'status': 'Success'}, statusCode: 429);

    await expectLater(
      FaucetClient(SuiUrls.faucetDev).requestSuiFromFaucetV2(_recipient),
      throwsA(isA<FaucetRateLimitError>()),
    );
  });
}
