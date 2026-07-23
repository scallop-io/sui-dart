import 'dart:typed_data';

import 'package:sui_dart/builder/transaction.dart' show Transaction;
import 'package:sui_dart/grpc/types.dart';

/// Transport-agnostic Sui client contract
///
/// gRPC is the default; only it supports [executeTransaction] and
/// [verifyZkLoginSignature] (GraphQL throws `UnsupportedError`). Use GraphQL
/// for read-only workloads against an indexer.
abstract interface class SuiCoreClient {
  /// Batched object reads: one entry per input id, in the same order.
  Future<List<ObjectResult>> getObjects(
    List<String> objectIds, {
    ObjectIncludeOptions? include,
  });

  /// Objects owned by [address], optionally filtered by move [type].
  Future<Page<ObjectData>> getOwnedObjects(
    String address, {
    String? type,
    String? cursor,
    int? limit,
    ObjectIncludeOptions? include,
  });

  /// Coin objects of [coinType] owned by [address].
  Future<Page<CoinData>> getCoins(
    String address, {
    String coinType = '0x2::sui::SUI',
    String? cursor,
    int? limit,
  });

  /// Aggregate balance of [coinType] for [address].
  Future<Balance> getBalance(
    String address, {
    String coinType = '0x2::sui::SUI',
  });

  /// Coin metadata for [coinType], or null when unregistered.
  Future<CoinMetadata?> getCoinMetadata(String coinType);

  /// Aggregate balances for every coin type [address] holds, paged through to
  /// the full set.
  Future<List<Balance>> getAllBalances(String address);

  Future<TransactionResponse> getTransaction(
    String digest, {
    TransactionIncludeOptions? include,
  });

  Future<TransactionResponse> executeTransaction(
    Uint8List transactionBytes,
    List<String> signatures, {
    TransactionIncludeOptions? include,
  });

  /// Simulates [transactionBlock] without signing; results surface via
  /// effects, events, and command outputs.
  Future<TransactionResponse> simulateTransaction(
    Transaction transactionBlock, {
    TransactionIncludeOptions? include,
    bool? doGasSelection,
    bool? checksEnabled,
  });

  Future<String> getReferenceGasPrice();

  Future<SystemState> getCurrentSystemState();

  Future<Page<DynamicFieldEntry>> getDynamicFields(
    String parentId, {
    String? cursor,
    int? limit,
  });

  Future<VerifySignatureResult> verifyZkLoginSignature(
    Uint8List bytes,
    String signature, {
    String? address,
  });

  Future<String?> defaultNameServiceName(String address);

  Future<MoveFunction> getMoveFunction(
    String packageId,
    String moduleName,
    String functionName,
  );

  Future<String> getChainIdentifier();
}
