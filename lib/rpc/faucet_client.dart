import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:sui_dart/http/http.dart';
import 'package:sui_dart/rpc/faucet_pow.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/types/faucet.dart';
import 'package:sui_dart/utils/error.dart';

class FaucetClient {
  final String endpoint;
  FaucetClient(this.endpoint);

  /// Proof-of-work faucet (testnet serves only this); submits once, no retry.
  /// [timeout] spans the whole flow. Throws [TimeoutException], [FaucetRateLimitError] or [FaucetError].
  Future<FaucetResponseV3> requestSuiFromFaucetV3(
    String recipient, {
    Map<String, String>? headers,
    Duration timeout = const Duration(minutes: 3),
    CancelToken? cancelToken,
  }) async {
    if (recipient.replaceFirst(RegExp('^0x', caseSensitive: false), '') == '') {
      throw ArgumentError('Invalid faucet recipient');
    }
    recipient = normalizeSuiAddress(recipient);
    if (!isValidSuiAddress(recipient)) {
      throw ArgumentError('Invalid faucet recipient');
    }

    final token = cancelToken ?? CancelToken();
    var timedOut = false;
    final timer = Timer(timeout, () {
      timedOut = true;
      token.cancel('Faucet request timed out');
    });

    Future<dynamic> request(String path, [Map<String, dynamic>? body]) async {
      try {
        final options = Options(headers: headers);
        final resp = body == null
            ? await http.get(
                '$endpoint$path',
                options: options,
                cancelToken: token,
              )
            : await http.post(
                '$endpoint$path',
                data: body,
                options: options,
                cancelToken: token,
              );
        return resp.data;
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel && timedOut) {
          throw TimeoutException('Faucet request timed out', timeout);
        }
        final res = e.response;
        if (res == null) rethrow;
        if (res.statusCode == 429) throw FaucetRateLimitError();
        final data = res.data is Map ? res.data as Map : const {};
        throw FaucetError(
          data['error'] is String
              ? data['error']
              : 'Faucet request failed (HTTP ${res.statusCode})',
          status: res.statusCode ?? 0,
          code: data['code'] is String ? data['code'] : null,
          digest: data['digest'] is String ? data['digest'] : null,
        );
      }
    }

    try {
      // not `1 << 32`: that is 0 on the web
      final random = Random.secure();
      var nonce =
          BigInt.from(random.nextInt(0x100000000)) << 32 |
          BigInt.from(random.nextInt(0x100000000));
      while (true) {
        final startedAt = DateTime.now();
        final challenge = FaucetChallenge.fromJson(
          await request('/v3/challenge?recipient=$recipient'),
        );
        if (challenge.recipient != recipient) {
          throw StateError('Faucet challenge recipient mismatch');
        }
        final proof = await challenge.solve(
          nonce,
          startedAt.add(Duration(milliseconds: challenge.windowSeconds * 800)),
          isCancelled: () => token.isCancelled,
        );
        if (token.isCancelled) {
          if (timedOut) {
            throw TimeoutException('Faucet request timed out', timeout);
          }
          throw DioException.requestCancelled(
            requestOptions: RequestOptions(path: '$endpoint/v3/challenge'),
            reason: token.cancelError?.error,
          );
        }
        if (proof == null) continue;

        final result = await request('/v3/gas', {
          'recipient': recipient,
          'checkpointSeq': challenge.checkpointSeq,
          'nonce': proof.nonce,
          'hashHex': proof.hashHex,
        });
        if (result is! Map ||
            result['status'] != 'success' ||
            result['recipient'] != recipient ||
            result['digest'] is! String ||
            !isValidTransactionDigest(result['digest'])) {
          throw const FormatException('Invalid faucet response');
        }
        return FaucetResponseV3(
          digest: result['digest'],
          recipient: recipient,
          amountMist: BigInt.parse(result['amountMist']),
          difficulty: BigInt.parse(result['difficulty']),
        );
      }
    } finally {
      timer.cancel();
    }
  }

  /// Request SUI from the `/v2/gas` faucet. Throws on non-`Success` status,
  /// or [FaucetRateLimitError] on HTTP 429.
  Future<FaucetResponseV2> requestSuiFromFaucetV2(String recipient) async {
    final data = {
      "FixedAmountRequest": {"recipient": recipient},
    };

    try {
      final resp = await http.post("$endpoint/v2/gas", data: data);
      final parsed = FaucetResponseV2.fromJson(resp.data);
      if (!parsed.isSuccess) {
        throw Exception('Faucet request failed: ${parsed.failureInternal}');
      }
      return parsed;
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw FaucetRateLimitError();
      }
      rethrow;
    }
  }

  @Deprecated('Use requestSuiFromFaucetV2; the /gas endpoint is deprecated.')
  Future<FaucetResponse> requestSuiFromFaucetV0(String recipient) async {
    final data = {
      "FixedAmountRequest": {"recipient": recipient},
    };

    final resp = await http.post("$endpoint/gas", data: data);
    return FaucetResponse.fromJson(resp.data);
  }

  @Deprecated('Use requestSuiFromFaucetV2; the /v1/gas endpoint is deprecated.')
  Future<BatchFaucetResponse> requestSuiFromFaucetV1(String recipient) async {
    final data = {
      "FixedAmountRequest": {"recipient": recipient},
    };

    final resp = await http.post("$endpoint/v1/gas", data: data);
    return BatchFaucetResponse.fromJson(resp.data);
  }

  @Deprecated(
    'Use requestSuiFromFaucetV2; the /v1/status endpoint is deprecated.',
  )
  Future<BatchStatusFaucetResponse> getFaucetRequestStatus(
    String taskId,
  ) async {
    final resp = await http.get("$endpoint/v1/status/$taskId");
    return BatchStatusFaucetResponse.fromJson(resp.data);
  }
}
