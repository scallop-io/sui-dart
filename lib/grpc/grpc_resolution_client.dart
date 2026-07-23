import 'dart:typed_data';

import 'package:sui_dart/builder/transaction.dart';
import 'package:sui_dart/grpc/sui_grpc_client.dart';
import 'package:sui_dart/sui_account.dart';

/// Builds, signs, and executes transactions entirely over gRPC.
extension SuiGrpcClientTransactions on SuiGrpcClient {
  /// Builds [tx] to BCS bytes, resolving coins/objects/gas over gRPC.
  Future<Uint8List> buildTransaction(Transaction tx, {String? sender}) {
    if (sender != null) tx.setSenderIfNotSet(sender);
    return tx.build(BuildOptions(client: core));
  }

  /// Builds [tx] over gRPC, signs it with [account], and executes it over gRPC.
  Future<TransactionResponse> signAndExecuteTransaction(
    SuiAccount account,
    Transaction tx, {
    TransactionIncludeOptions? include,
  }) async {
    tx.setSenderIfNotSet(account.getAddress());
    final bytes = await buildTransaction(tx);
    final signed = account.keyPair.signTransactionBlock(bytes);
    return executeTransaction(bytes, [signed.signature], include: include);
  }
}
