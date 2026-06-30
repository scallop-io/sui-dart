import 'dart:async';
import 'dart:typed_data';

import 'package:sui_dart/builder/transaction.dart';
import 'package:sui_dart/sui_account.dart';
import 'package:sui_dart/sui_client.dart';
import 'package:sui_dart/types/objects.dart';
import 'package:sui_dart/types/transactions.dart';

/// Runs async tasks one at a time, in submission order. A failing task does not
/// break the chain — its error is delivered to that task's caller only.
class SerialQueue {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    // The continuation never throws (errors are routed to [completer]), so the
    // chain keeps flowing even after a task fails.
    _tail = _tail.then((_) async {
      try {
        completer.complete(await task());
      } catch (error, stack) {
        completer.completeError(error, stack);
      }
    });
    return completer.future;
  }
}

/// Signs and executes transactions one at a time for a single account, reusing
/// the gas coin from each transaction's effects so the next transaction does not
/// have to wait for the previous one to be indexed.
///
/// This covers the common high-throughput case (back-to-back transactions from
/// one signer). It does not cache arbitrary owned-object versions across
/// transactions, so a sequence that mutates the same non-gas object repeatedly
/// must still pass fresh references; and it does not run transactions in
/// parallel.
class SerialTransactionExecutor {
  final SuiClient client;
  final SuiAccount signer;
  final BigInt defaultGasBudget;

  final SerialQueue _queue = SerialQueue();
  SuiObjectRef? _cachedGasCoin;

  SerialTransactionExecutor({
    required this.client,
    required this.signer,
    BigInt? defaultGasBudget,
  }) : defaultGasBudget = defaultGasBudget ?? BigInt.from(50000000);

  /// Builds [transaction] to BCS bytes, paying with the cached gas coin if one
  /// is available. Runs through the serial queue.
  Future<Uint8List> buildTransaction(Transaction transaction) {
    return _queue.run(() => _build(transaction));
  }

  Future<Uint8List> _build(Transaction transaction) async {
    if (_cachedGasCoin != null) {
      transaction.setGasPayment([_cachedGasCoin!]);
    }
    if (transaction.getData().gasData.budget == null) {
      transaction.setGasBudget(defaultGasBudget);
    }
    transaction.setSenderIfNotSet(signer.getAddress());
    return transaction.build(BuildOptions(client: client));
  }

  /// Builds, signs, and executes [transaction], caching the resulting gas coin
  /// for the next transaction. On failure the cache is cleared so the next build
  /// re-selects gas from the client.
  Future<SuiTransactionBlockResponse> executeTransaction(
    Transaction transaction, {
    SuiTransactionBlockResponseOptions? responseOptions,
    List<String> additionalSignatures = const [],
  }) {
    return _queue.run(() async {
      final bytes = await _build(transaction);
      final signed = signer.keyPair.signTransactionBlock(bytes);

      final options = responseOptions ?? SuiTransactionBlockResponseOptions();
      options.showEffects = true;

      try {
        final response = await client.executeTransactionBlock(signed.bytes, [
          signed.signature,
          ...additionalSignatures,
        ], options: options);
        _cachedGasCoin = gasCoinFromEffects(response);
        return response;
      } catch (_) {
        resetCache();
        rethrow;
      }
    });
  }

  /// Clears the cached gas coin; the next build re-selects gas from the client.
  void resetCache() {
    _cachedGasCoin = null;
  }
}

/// The gas coin reference from a transaction's effects (the mutated gas object),
/// or `null` if effects were not returned.
SuiObjectRef? gasCoinFromEffects(SuiTransactionBlockResponse response) {
  return response.effects?.gasObject.reference;
}
