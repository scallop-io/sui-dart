import 'dart:typed_data';

import 'package:sui_dart/builder/transaction.dart' show Transaction;
import 'package:sui_dart/grpc/types.dart';
import 'package:sui_dart/types/common.dart'
    show normalizeStructTagString, normalizeSuiAddress;

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

  /// Ledger-ordered transactions, newest first when [order] is descending.
  /// [after] pages forward, [before] back; give only one, matching the order.
  Future<Page<TransactionResponse>> listTransactions({
    TransactionFilter? filter,
    String? after,
    String? before,
    QueryOrder? order,
    int? limit,
    int? startCheckpoint,
    int? endCheckpoint,
    TransactionIncludeOptions? include,
  });

  /// Paged like [listTransactions].
  Future<Page<Event>> listEvents({
    EventFilter? filter,
    String? after,
    String? before,
    QueryOrder? order,
    int? limit,
    int? startCheckpoint,
    int? endCheckpoint,
  });

  Future<String> getReferenceGasPrice();

  Future<SystemState> getCurrentSystemState();

  Future<ProtocolConfig> getProtocolConfig();

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

  /// Null when the SuiNS name is unregistered or expired.
  Future<String?> resolveNameServiceAddress(String name);

  Future<MoveFunction> getMoveFunction(
    String packageId,
    String moduleName,
    String functionName,
  );

  Future<String> getChainIdentifier();
}

/// Used when a query gives no limit, so both transports ask for the same page.
const defaultQueryPageSize = 50;

class ResolvedPagination {
  final bool descending;
  final String? after;
  final String? before;
  final int limit;

  const ResolvedPagination({
    required this.descending,
    required this.limit,
    this.after,
    this.before,
  });

  bool get hasBound => after != null || before != null;
}

/// [after] and [before] are exclusive positions. A query takes at most one, and
/// it has to match the direction: [after] ascending, [before] descending.
ResolvedPagination resolvePagination({
  String? after,
  String? before,
  QueryOrder? order,
  int? limit,
}) {
  if (after != null && before != null) {
    throw ArgumentError('Only one of `after` or `before` may be given');
  }

  final descending = order != null
      ? order == QueryOrder.descending
      : before != null;

  if (after != null && descending) {
    throw ArgumentError('`after` cannot be combined with a descending query');
  }
  if (before != null && !descending) {
    throw ArgumentError('`before` cannot be combined with an ascending query');
  }

  return ResolvedPagination(
    descending: descending,
    after: after,
    before: before,
    limit: limit ?? defaultQueryPageSize,
  );
}

/// A [TransactionFilter] narrowed to one predicate: [sender], or a function
/// split into [package] and its optional [module] and [function].
class ResolvedTransactionFilter {
  final String? sender;
  final String? package;
  final String? module;
  final String? function;

  const ResolvedTransactionFilter({
    this.sender,
    this.package,
    this.module,
    this.function,
  });

  /// `package`, `package::module`, or `package::module::function`.
  String get functionTarget =>
      [package, module, function].whereType<String>().join('::');
}

ResolvedTransactionFilter resolveTransactionFilter(TransactionFilter filter) {
  final predicates = [filter.sender, filter.function].nonNulls.length;
  if (predicates != 1) {
    throw ArgumentError(
      'A transaction filter must specify exactly one of sender, function',
    );
  }

  if (filter.sender != null) {
    return ResolvedTransactionFilter(
      sender: normalizeSuiAddress(filter.sender!),
    );
  }

  final parts = filter.function!.split('::');
  if (parts.length > 3 || parts.any((part) => part.isEmpty)) {
    throw ArgumentError(
      'Invalid function filter "${filter.function}": expected "package", '
      '"package::module", or "package::module::function"',
    );
  }

  return ResolvedTransactionFilter(
    package: normalizeSuiAddress(parts[0]),
    module: parts.length > 1 ? parts[1] : null,
    function: parts.length > 2 ? parts[2] : null,
  );
}

/// A function filter can only be paged when fully qualified: a package- or
/// module-level filter has no stable cursor to resume from.
void validateTransactionQuery(
  ResolvedTransactionFilter? filter,
  ResolvedPagination pagination,
) {
  if (filter?.package != null &&
      pagination.hasBound &&
      (filter!.module == null || filter.function == null)) {
    throw ArgumentError(
      'Paging transactions filtered by function requires a fully qualified '
      '"package::module::function"',
    );
  }
}

/// An [EventFilter] narrowed to one predicate.
class ResolvedEventFilter {
  final String? sender;

  /// `package::module`.
  final String? emitModule;

  /// `package::module` or a full type name.
  final String? eventType;

  const ResolvedEventFilter({this.sender, this.emitModule, this.eventType});
}

ResolvedEventFilter resolveEventFilter(EventFilter filter) {
  final predicates = [
    filter.sender,
    filter.emitModule,
    filter.eventType,
  ].nonNulls.length;
  if (predicates != 1) {
    throw ArgumentError(
      'An event filter must specify exactly one of sender, emitModule, '
      'eventType',
    );
  }

  if (filter.sender != null) {
    return ResolvedEventFilter(sender: normalizeSuiAddress(filter.sender!));
  }

  if (filter.emitModule != null) {
    final parts = filter.emitModule!.split('::');
    if (parts.length != 2 || parts.any((part) => part.isEmpty)) {
      throw ArgumentError(
        'Invalid emitModule filter "${filter.emitModule}": expected '
        '"package::module"',
      );
    }
    return ResolvedEventFilter(
      emitModule: '${normalizeSuiAddress(parts[0])}::${parts[1]}',
    );
  }

  final parts = filter.eventType!.split('::');
  if (parts.length < 2 || parts.any((part) => part.isEmpty)) {
    throw ArgumentError(
      'Invalid eventType filter "${filter.eventType}": expected '
      '"package::module" or a fully qualified type name',
    );
  }
  if (parts.length == 2) {
    return ResolvedEventFilter(
      eventType: '${normalizeSuiAddress(parts[0])}::${parts[1]}',
    );
  }
  return ResolvedEventFilter(
    eventType: normalizeStructTagString(filter.eventType!),
  );
}
