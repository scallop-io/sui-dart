// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:typed_data';

import 'package:sui_dart/sui_client.dart';
import 'package:sui_dart/types/coins.dart';
import 'package:sui_dart/types/normalized.dart';
import 'package:sui_dart/types/objects.dart';
import 'package:sui_dart/types/transactions.dart';

/// Transport-agnostic view of the chain reads the transaction builder needs at
/// build time (coin selection, object resolution, gas price, dry run, move
/// function signatures, protocol limits).
///
/// Implemented over JSON-RPC by [JsonRpcResolutionClient] and over gRPC by
/// `GrpcResolutionClient`, so the builder doesn't depend on a transport.
abstract interface class TxResolutionClient {
  Future<PaginatedCoins> getCoins(
    String owner, {
    String? coinType,
    String? cursor,
    int? limit,
  });

  Future<List<SuiObjectResponse>> multiGetObjects(
    List<String> objectIds, {
    SuiObjectDataOptions? options,
  });

  Future<BigInt> getReferenceGasPrice();

  Future<DryRunTransactionBlockResponse> dryRunTransaction(
    Uint8List bytes, {
    String? signerAddress,
  });

  Future<SuiMoveNormalizedFunction> getNormalizedMoveFunction(
    String package,
    String module,
    String function,
  );

  /// The chain's protocol config (build limits), or `null` if the transport
  /// can't provide it (callers fall back to offline defaults / explicit limits).
  Future<dynamic> getProtocolConfig();
}

/// [TxResolutionClient] backed by the JSON-RPC [SuiClient].
class JsonRpcResolutionClient implements TxResolutionClient {
  final SuiClient client;

  JsonRpcResolutionClient(this.client);

  @override
  Future<PaginatedCoins> getCoins(
    String owner, {
    String? coinType,
    String? cursor,
    int? limit,
  }) =>
      client.getCoins(owner, coinType: coinType, cursor: cursor, limit: limit);

  @override
  Future<List<SuiObjectResponse>> multiGetObjects(
    List<String> objectIds, {
    SuiObjectDataOptions? options,
  }) => client.multiGetObjects(objectIds, options: options);

  @override
  Future<BigInt> getReferenceGasPrice() => client.getReferenceGasPrice();

  @override
  Future<DryRunTransactionBlockResponse> dryRunTransaction(
    Uint8List bytes, {
    String? signerAddress,
  }) => client.dryRunTransaction(bytes, signerAddress: signerAddress);

  @override
  Future<SuiMoveNormalizedFunction> getNormalizedMoveFunction(
    String package,
    String module,
    String function,
  ) => client.getNormalizedMoveFunction(package, module, function);

  @override
  Future<dynamic> getProtocolConfig() => client.getProtocolConfig();
}
