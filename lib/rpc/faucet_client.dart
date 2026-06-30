import 'package:dio/dio.dart';
import 'package:sui_dart/http/http.dart';
import 'package:sui_dart/types/faucet.dart';
import 'package:sui_dart/utils/error.dart';

class FaucetClient {
  final String endpoint;
  FaucetClient(this.endpoint);

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
