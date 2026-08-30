import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:protobuf/protobuf.dart';
import 'package:sui_dart/grpc/generated/google/rpc/status.pb.dart'
    as rpc_status;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart';

import 'package:sui_dart/grpc/generated/sui/rpc/v2/bcs.pb.dart' as grpc_bcs;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/effects.pb.dart'
    as pb_effects;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/execution_status.pb.dart'
    as pb_exec;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/executed_transaction.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/filter.pb.dart' as pb_filter;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/ledger_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/query_options.pb.dart'
    as pb_query;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/move_package.pb.dart'
    hide TypeParameter;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/move_package_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/name_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/object.pb.dart'
    as grpc_object;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/owner.pb.dart' as pb_owner;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/signature.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/signature_verification_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/state_service.pbgrpc.dart'
    hide Balance, CoinMetadata;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction_execution_service.pbgrpc.dart'
    hide CommandResult, CommandOutput;
import 'package:sui_dart/sui.dart' as sui_dart;
import 'package:sui_dart/builder/transaction.dart' show chunk;
import 'package:sui_dart/types/common.dart' hide ObjectOwner;

import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    as pb_struct;

import 'package:sui_dart/core/sui_core_client.dart';

import 'sui_grpc_client.dart';

// ignore: constant_identifier_names
const _MAX_OBJECTS_PER_BATCH = 50;

const _grpcStatusNames = <int, String>{
  StatusCode.cancelled: 'CANCELLED',
  StatusCode.unknown: 'UNKNOWN',
  StatusCode.invalidArgument: 'INVALID_ARGUMENT',
  StatusCode.deadlineExceeded: 'DEADLINE_EXCEEDED',
  StatusCode.notFound: 'NOT_FOUND',
  StatusCode.alreadyExists: 'ALREADY_EXISTS',
  StatusCode.permissionDenied: 'PERMISSION_DENIED',
  StatusCode.resourceExhausted: 'RESOURCE_EXHAUSTED',
  StatusCode.failedPrecondition: 'FAILED_PRECONDITION',
  StatusCode.aborted: 'ABORTED',
  StatusCode.outOfRange: 'OUT_OF_RANGE',
  StatusCode.unimplemented: 'UNIMPLEMENTED',
  StatusCode.internal: 'INTERNAL',
  StatusCode.unavailable: 'UNAVAILABLE',
  StatusCode.dataLoss: 'DATA_LOSS',
  StatusCode.unauthenticated: 'UNAUTHENTICATED',
};

/// Collects a server-streamed ledger query into a [Page].
///
/// One item over the page is requested as lookahead: the node reports its item
/// limit as reached without scanning past it, so a page filled exactly to the
/// limit would otherwise look the same as one with more behind it.
class _LedgerPage<T> {
  _LedgerPage(this.limit);

  final int limit;
  final List<T> _items = [];
  String? _frontier;
  String? _startCursor;
  String? _endCursor;
  pb_query.QueryEndReason? _endReason;
  bool _sawLookahead = false;

  void watermark(pb_query.Watermark watermark) {
    if (watermark.hasCursor()) _frontier = base64Encode(watermark.cursor);
  }

  void add(T Function() parse) {
    if (_items.length >= limit) {
      _sawLookahead = true;
      return;
    }
    _startCursor ??= _frontier;
    _endCursor = _frontier;
    _items.add(parse());
  }

  void end(pb_query.QueryEnd end) => _endReason = end.reason;

  Page<T> build() {
    // A clamped item limit means a full page may still have more behind it.
    final hasNextPage =
        _sawLookahead ||
        _endReason == pb_query.QueryEndReason.QUERY_END_REASON_ITEM_LIMIT ||
        _endReason == pb_query.QueryEndReason.QUERY_END_REASON_SCAN_LIMIT;

    return Page(
      data: _items,
      hasNextPage: hasNextPage,
      // An early-stopped scan resumes at the frontier, not at the last item.
      nextCursor: _sawLookahead
          ? _endCursor
          : hasNextPage
          ? (_frontier ?? _endCursor)
          : _endCursor,
      startCursor: _startCursor,
    );
  }
}

/// Converts a Google protobuf Value to a Dart dynamic value.
dynamic _protoValueToDart(pb_struct.Value value) {
  switch (value.whichKind()) {
    case pb_struct.Value_Kind.nullValue:
      return null;
    case pb_struct.Value_Kind.numberValue:
      return value.numberValue;
    case pb_struct.Value_Kind.stringValue:
      return value.stringValue;
    case pb_struct.Value_Kind.boolValue:
      return value.boolValue;
    case pb_struct.Value_Kind.structValue:
      return _protoStructToDart(value.structValue);
    case pb_struct.Value_Kind.listValue:
      return value.listValue.values.map(_protoValueToDart).toList();
    case pb_struct.Value_Kind.notSet:
      return null;
  }
}

/// Converts a Google protobuf Struct to a Dart Map.
Map<String, dynamic> _protoStructToDart(pb_struct.Struct struct) {
  return struct.fields.map((k, v) => MapEntry(k, _protoValueToDart(v)));
}

/// Converts a Google protobuf Value to a `Map<String, dynamic>`.
/// For object JSON, the top-level value is always a struct.
Map<String, dynamic>? _protoValueToMap(pb_struct.Value value) {
  final result = _protoValueToDart(value);
  if (result is Map<String, dynamic>) return result;
  if (result is Map) return Map<String, dynamic>.from(result);
  return null;
}

class GrpcCoreClient implements SuiCoreClient {
  final SuiGrpcClient _client;

  GrpcCoreClient(this._client);

  @override
  Future<List<ObjectResult>> getObjects(
    List<String> ids, {
    ObjectIncludeOptions? include,
  }) async {
    final readMask = _objectReadMask(include);
    final chunks = chunk(ids, _MAX_OBJECTS_PER_BATCH);

    final results = <GetObjectResult>[];
    for (final c in chunks) {
      final response = await _client.ledgerService.batchGetObjects(
        BatchGetObjectsRequest(
          requests: c.map((id) => GetObjectRequest(objectId: id)),
          readMask: readMask,
        ),
      );
      results.addAll(response.objects);
    }

    return [
      for (var i = 0; i < results.length; i++)
        if (results[i].whichResult() == GetObjectResult_Result.error)
          _objectError(results[i].error, i < ids.length ? ids[i] : null)
        else
          ObjectSuccess(_parseObject(results[i].object, include)),
    ];
  }

  static ObjectError _objectError(rpc_status.Status status, String? objectId) {
    final notFound = status.code == StatusCode.notFound;
    return ObjectError(
      status.message,
      // Missing objects keep the `notExists` code so existing handlers work.
      code: notFound
          ? 'notExists'
          : (_grpcStatusNames[status.code] ?? 'unknown'),
      reason: notFound ? ObjectErrorReason.notFound : ObjectErrorReason.unknown,
      objectId: objectId,
      cause: status,
    );
  }

  @override
  Future<Page<ObjectData>> getOwnedObjects(
    String owner, {
    String? type,
    String? cursor,
    int? limit,
    ObjectIncludeOptions? include,
  }) async {
    final readMask = _objectReadMask(include);

    final response = await _client.stateService.listOwnedObjects(
      ListOwnedObjectsRequest(
        owner: owner,
        objectType: type,
        pageSize: limit,
        pageToken: cursor != null ? base64Decode(cursor) : null,
        readMask: readMask,
      ),
    );

    final hasNext =
        response.hasNextPageToken() && response.nextPageToken.isNotEmpty;
    return Page(
      data: response.objects.map((obj) => _parseObject(obj, include)).toList(),
      hasNextPage: hasNext,
      nextCursor: hasNext ? base64Encode(response.nextPageToken) : null,
    );
  }

  @override
  Future<Page<CoinData>> getCoins(
    String owner, {
    String coinType = '0x2::sui::SUI',
    String? cursor,
    int? limit,
  }) async {
    final normalizedCoinType = normalizeStructTagString(coinType);
    final objectType = '0x2::coin::Coin<$normalizedCoinType>';

    final response = await _client.stateService.listOwnedObjects(
      ListOwnedObjectsRequest(
        owner: owner,
        objectType: objectType,
        pageSize: limit,
        pageToken: cursor != null ? base64Decode(cursor) : null,
        readMask: FieldMask(
          paths: [
            'object_id',
            'version',
            'digest',
            'object_type',
            'owner',
            'balance',
          ],
        ),
      ),
    );

    final hasNext =
        response.hasNextPageToken() && response.nextPageToken.isNotEmpty;
    return Page(
      data: response.objects.map((obj) {
        return CoinData(
          objectId: obj.objectId,
          version: obj.version.toString(),
          digest: obj.digest,
          owner: obj.hasOwner() ? _mapOwner(obj.owner) : const UnknownOwner(),
          type: normalizedCoinType,
          balance: obj.balance.toString(),
        );
      }).toList(),
      hasNextPage: hasNext,
      nextCursor: hasNext ? base64Encode(response.nextPageToken) : null,
    );
  }

  @override
  Future<Balance> getBalance(
    String owner, {
    String coinType = '0x2::sui::SUI',
  }) async {
    final normalizedCoinType = normalizeStructTagString(coinType);

    final response = await _client.stateService.getBalance(
      GetBalanceRequest(owner: owner, coinType: normalizedCoinType),
    );

    final balance = response.balance;
    return Balance(
      coinType: balance.coinType,
      balance: balance.balance.toString(),
      coinBalance: balance.coinBalance.toString(),
      addressBalance: balance.addressBalance.toString(),
    );
  }

  @override
  Future<CoinMetadata?> getCoinMetadata(String coinType) async {
    final normalizedCoinType = normalizeStructTagString(coinType);

    final response = await _client.stateService.getCoinInfo(
      GetCoinInfoRequest(coinType: normalizedCoinType),
    );

    if (!response.hasMetadata()) return null;

    final metadata = response.metadata;
    return CoinMetadata(
      id: metadata.id,
      decimals: metadata.decimals,
      name: metadata.name,
      symbol: metadata.symbol,
      description: metadata.description,
      iconUrl: metadata.iconUrl.isNotEmpty ? metadata.iconUrl : null,
    );
  }

  @override
  Future<List<Balance>> getAllBalances(String owner) async {
    final allBalances = [];
    List<int>? pageToken;

    while (true) {
      final response = await _client.stateService.listBalances(
        ListBalancesRequest(owner: owner, pageToken: pageToken),
      );

      allBalances.addAll(response.balances);

      if (!response.hasNextPageToken() || response.nextPageToken.isEmpty) {
        break;
      }
      pageToken = response.nextPageToken;
    }

    return allBalances.map((balance) {
      return Balance(
        coinType: balance.coinType,
        balance: balance.balance.toString(),
        coinBalance: balance.coinBalance.toString(),
        addressBalance: balance.addressBalance.toString(),
      );
    }).toList();
  }

  @override
  Future<TransactionResponse> getTransaction(
    String digest, {
    TransactionIncludeOptions? include,
  }) async {
    final readMask = _transactionReadMask(include);

    try {
      final response = await _client.ledgerService.getTransaction(
        GetTransactionRequest(digest: digest, readMask: readMask),
      );

      if (!response.hasTransaction()) {
        throw TransactionError(TransactionErrorReason.notFound, digest);
      }

      return _parseTransaction(response.transaction, include);
    } on GrpcError catch (error) {
      if (error.code == StatusCode.notFound) {
        throw TransactionError(
          TransactionErrorReason.notFound,
          digest,
          cause: error,
        );
      }
      rethrow;
    }
  }

  @override
  Future<TransactionResponse> executeTransaction(
    Uint8List transactionBytes,
    List<String> signatures, {
    TransactionIncludeOptions? include,
  }) async {
    final readMask = _transactionReadMask(include);

    final response = await _client.transactionExecutionService
        .executeTransaction(
          ExecuteTransactionRequest(
            transaction: .new(bcs: .new(value: transactionBytes)),
            signatures: signatures.map((sig) {
              return UserSignature(bcs: grpc_bcs.Bcs(value: base64Decode(sig)));
            }),
            readMask: readMask,
          ),
        );

    return _parseTransaction(response.transaction, include);
  }

  @override
  Future<TransactionResponse> simulateTransaction(
    sui_dart.Transaction transactionBlock, {
    TransactionIncludeOptions? include,
    bool? doGasSelection,
    bool? checksEnabled,
  }) async {
    final readMask = _simulateReadMask(include);

    // gRPC conversion is synchronous, so intents must resolve before it.
    if (!transactionBlock.isPreparedForSerialization()) {
      await transactionBlock.prepareForSerialization(
        sui_dart.SerializeTransactionOptions(client: this),
      );
    }

    // An empty payment means address-balance gas, so the node must select gas.
    final payment = transactionBlock.getData().gasData.payment;
    final gasSelection = doGasSelection ?? (payment != null && payment.isEmpty);

    final response = await _client.transactionExecutionService
        .simulateTransaction(
          SimulateTransactionRequest(
            transaction: transactionBlock.toGrpcTransaction(),
            readMask: readMask,
            doGasSelection: gasSelection,
            checks: checksEnabled == false
                ? SimulateTransactionRequest_TransactionChecks.DISABLED
                : SimulateTransactionRequest_TransactionChecks.ENABLED,
          ),
        );

    var result = _parseTransaction(response.transaction, include);

    if (include?.commandResults == true) {
      result = result.copyWith(
        commandResults: response.commandOutputs.map((cmdResult) {
          return CommandResult(
            returnValues: cmdResult.returnValues.map((output) {
              return CommandOutput(
                bcs: output.hasValue()
                    ? Uint8List.fromList(output.value.value)
                    : Uint8List(0),
              );
            }).toList(),
            mutatedReferences: cmdResult.mutatedByRef.map((output) {
              return CommandOutput(
                bcs: output.hasValue()
                    ? Uint8List.fromList(output.value.value)
                    : Uint8List(0),
              );
            }).toList(),
          );
        }).toList(),
      );
    }

    return result;
  }

  @override
  Future<Page<TransactionResponse>> listTransactions({
    TransactionFilter? filter,
    String? after,
    String? before,
    QueryOrder? order,
    int? limit,
    int? startCheckpoint,
    int? endCheckpoint,
    TransactionIncludeOptions? include,
  }) async {
    final pagination = resolvePagination(
      after: after,
      before: before,
      order: order,
      limit: limit,
    );
    final resolved = filter == null ? null : resolveTransactionFilter(filter);
    validateTransactionQuery(resolved, pagination);

    final stream = _client.ledgerService.listTransactions(
      ListTransactionsRequest(
        readMask: _transactionReadMask(include),
        startCheckpoint: _checkpoint(startCheckpoint),
        endCheckpoint: _checkpoint(endCheckpoint),
        filter: resolved == null ? null : _transactionFilter(resolved),
        options: _queryOptions(pagination),
      ),
    );

    final page = _LedgerPage<TransactionResponse>(pagination.limit);
    await for (final frame in stream) {
      if (frame.hasWatermark()) page.watermark(frame.watermark);
      if (frame.hasTransaction()) {
        page.add(() => _parseTransaction(frame.transaction, include));
      }
      if (frame.hasEnd()) page.end(frame.end);
    }

    return page.build();
  }

  @override
  Future<Page<Event>> listEvents({
    EventFilter? filter,
    String? after,
    String? before,
    QueryOrder? order,
    int? limit,
    int? startCheckpoint,
    int? endCheckpoint,
  }) async {
    final pagination = resolvePagination(
      after: after,
      before: before,
      order: order,
      limit: limit,
    );
    final resolved = filter == null ? null : resolveEventFilter(filter);

    final stream = _client.ledgerService.listEvents(
      ListEventsRequest(
        readMask: FieldMask(
          paths: [
            'package_id',
            'module',
            'sender',
            'event_type',
            'contents',
            'json',
            'checkpoint',
            'transaction_digest',
            'event_index',
          ],
        ),
        startCheckpoint: _checkpoint(startCheckpoint),
        endCheckpoint: _checkpoint(endCheckpoint),
        filter: resolved == null ? null : _eventFilter(resolved),
        options: _queryOptions(pagination),
      ),
    );

    final page = _LedgerPage<Event>(pagination.limit);
    await for (final frame in stream) {
      if (frame.hasWatermark()) page.watermark(frame.watermark);
      if (frame.hasEvent()) {
        final event = frame.event;
        page.add(
          () => Event(
            packageId: event.packageId,
            module: event.module,
            sender: event.sender,
            eventType: event.eventType,
            bcs: event.hasContents()
                ? Uint8List.fromList(event.contents.value)
                : Uint8List(0),
            json: event.hasJson() ? _protoValueToMap(event.json) : null,
            checkpoint: event.hasCheckpoint()
                ? event.checkpoint.toString()
                : null,
            transactionDigest: event.hasTransactionDigest()
                ? event.transactionDigest
                : null,
            eventIndex: event.hasEventIndex() ? event.eventIndex : null,
          ),
        );
      }
      if (frame.hasEnd()) page.end(frame.end);
    }

    return page.build();
  }

  static Int64? _checkpoint(int? checkpoint) =>
      checkpoint == null ? null : Int64(checkpoint);

  static pb_query.QueryOptions _queryOptions(ResolvedPagination pagination) {
    return pb_query.QueryOptions(
      // One item over the page as lookahead; see [_LedgerPage].
      limit: pagination.limit + 1,
      after: pagination.after == null ? null : base64Decode(pagination.after!),
      before: pagination.before == null
          ? null
          : base64Decode(pagination.before!),
      ordering: pagination.descending
          ? pb_query.Ordering.ORDERING_DESCENDING
          : pb_query.Ordering.ORDERING_ASCENDING,
    );
  }

  static pb_filter.TransactionFilter _transactionFilter(
    ResolvedTransactionFilter filter,
  ) {
    return pb_filter.TransactionFilter(
      terms: [
        pb_filter.TransactionTerm(
          literals: [
            filter.sender != null
                ? pb_filter.TransactionLiteral(
                    sender: pb_filter.SenderFilter(address: filter.sender),
                  )
                : pb_filter.TransactionLiteral(
                    moveCall: pb_filter.MoveCallFilter(
                      function: filter.functionTarget,
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  static pb_filter.EventFilter _eventFilter(ResolvedEventFilter filter) {
    final pb_filter.EventLiteral literal;
    if (filter.sender != null) {
      literal = pb_filter.EventLiteral(
        sender: pb_filter.SenderFilter(address: filter.sender),
      );
    } else if (filter.emitModule != null) {
      literal = pb_filter.EventLiteral(
        emitModule: pb_filter.EmitModuleFilter(module: filter.emitModule),
      );
    } else {
      literal = pb_filter.EventLiteral(
        eventType: pb_filter.EventTypeFilter(eventType: filter.eventType),
      );
    }

    return pb_filter.EventFilter(
      terms: [
        pb_filter.EventTerm(literals: [literal]),
      ],
    );
  }

  @override
  Future<String> getReferenceGasPrice() async {
    final response = await _client.ledgerService.getEpoch(
      GetEpochRequest(readMask: FieldMask(paths: ['reference_gas_price'])),
    );

    return response.epoch.referenceGasPrice.toString();
  }

  @override
  Future<SystemState> getCurrentSystemState() async {
    final response = await _client.ledgerService.getEpoch(
      GetEpochRequest(
        readMask: FieldMask(
          paths: [
            'epoch',
            'reference_gas_price',
            'system_state',
            'start',
            'end',
          ],
        ),
      ),
    );

    final epoch = response.epoch;
    return SystemState(
      epoch: epoch.epoch.toString(),
      referenceGasPrice: epoch.referenceGasPrice.toString(),
      systemState: epoch.hasSystemState()
          ? epoch.systemState.writeToJsonMap()
          : null,
      epochStartTimestampMs: epoch.hasStart()
          ? epoch.start.seconds.toString()
          : null,
    );
  }

  @override
  Future<ProtocolConfig> getProtocolConfig() async {
    final response = await _client.ledgerService.getEpoch(
      GetEpochRequest(readMask: FieldMask(paths: ['protocol_config'])),
    );

    final config = response.epoch.protocolConfig;
    return ProtocolConfig(
      protocolVersion: config.protocolVersion.toString(),
      featureFlags: Map.of(config.featureFlags),
      attributes: Map.of(config.attributes),
    );
  }

  @override
  Future<Page<DynamicFieldEntry>> getDynamicFields(
    String parentId, {
    String? cursor,
    int? limit,
  }) async {
    final response = await _client.stateService.listDynamicFields(
      ListDynamicFieldsRequest(
        parent: parentId,
        pageSize: limit,
        pageToken: cursor != null ? base64Decode(cursor) : null,
        readMask: FieldMask(
          paths: ['kind', 'field_id', 'name', 'value_type', 'child_id'],
        ),
      ),
    );

    final hasNext =
        response.hasNextPageToken() && response.nextPageToken.isNotEmpty;
    return Page(
      data: response.dynamicFields.map((field) {
        return DynamicFieldEntry(
          name: DynamicFieldName(
            type: field.hasName() ? field.name.name : null,
            bcs: field.hasName() ? Uint8List.fromList(field.name.value) : null,
          ),
          objectType: field.valueType,
          objectId: field.childId.isNotEmpty ? field.childId : field.fieldId,
          type: _mapDynamicFieldKind(field.kind),
        );
      }).toList(),
      hasNextPage: hasNext,
      nextCursor: hasNext ? base64Encode(response.nextPageToken) : null,
    );
  }

  @override
  Future<VerifySignatureResult> verifyZkLoginSignature(
    Uint8List bytes,
    String signature, {
    String? address,
  }) async {
    final response = await _client.signatureVerificationService.verifySignature(
      VerifySignatureRequest(
        message: grpc_bcs.Bcs(name: 'TransactionData', value: bytes),
        signature: UserSignature(
          bcs: grpc_bcs.Bcs(value: base64Decode(signature)),
        ),
        address: address,
      ),
    );

    return VerifySignatureResult(
      isValid: response.isValid,
      reason: response.hasReason() ? response.reason : null,
    );
  }

  @override
  Future<String?> defaultNameServiceName(String address) async {
    try {
      final response = await _client.nameService.reverseLookupName(
        ReverseLookupNameRequest(address: address),
      );
      if (response.hasRecord() && response.record.hasName()) {
        return response.record.name;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> resolveNameServiceAddress(String name) async {
    try {
      final response = await _client.nameService.lookupName(
        LookupNameRequest(name: name),
      );
      if (response.hasRecord() && response.record.hasTargetAddress()) {
        return response.record.targetAddress;
      }
      return null;
    } catch (_) {
      // Unregistered names come back NOT_FOUND, expired ones RESOURCE_EXHAUSTED.
      return null;
    }
  }

  @override
  Future<MoveFunction> getMoveFunction(
    String packageId,
    String moduleName,
    String functionName,
  ) async {
    final response = await _client.movePackageService.getFunction(
      GetFunctionRequest(
        packageId: packageId,
        moduleName: moduleName,
        name: functionName,
      ),
    );

    final func = response.function;
    return MoveFunction(
      name: func.name,
      visibility: _mapVisibility(func.visibility),
      isEntry: func.isEntry,
      typeParameters: func.typeParameters.map((tp) {
        return TypeParameter(
          abilities: tp.constraints.map(_mapAbility).toList(),
        );
      }).toList(),
      parameters: func.parameters.map(_parseNormalizedMoveType).toList(),
      returnTypes: func.returns.map(_parseNormalizedMoveType).toList(),
    );
  }

  @override
  Future<String> getChainIdentifier() async {
    final response = await _client.ledgerService.getServiceInfo(
      GetServiceInfoRequest(),
    );
    return response.chainId;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  FieldMask _objectReadMask(ObjectIncludeOptions? include) {
    final paths = <String>[
      'object_id',
      'version',
      'digest',
      'object_type',
      'owner',
    ];

    if (include?.previousTransaction == true) paths.add('previous_transaction');
    if (include?.content == true) paths.add('contents');
    if (include?.json == true) paths.add('json');
    if (include?.objectBcs == true) paths.add('bcs');
    if (include?.display == true) paths.add('display');

    return FieldMask(paths: paths);
  }

  FieldMask _transactionReadMask(TransactionIncludeOptions? include) {
    // status is always requested: without it a failed transaction reads as
    // successful. The full effects message still needs include.effects.
    final paths = <String>[
      'digest',
      'signatures',
      'checkpoint',
      'timestamp',
      'effects.status',
    ];

    if (include?.transaction == true) paths.add('transaction');
    if (include?.effects == true) paths.add('effects');
    if (include?.events == true) paths.add('events');
    if (include?.balanceChanges == true) paths.add('balance_changes');
    if (include?.bcs == true) paths.add('transaction.bcs');
    if (include?.commandResults == true) paths.add('command_outputs');

    return FieldMask(paths: paths);
  }

  FieldMask _simulateReadMask(TransactionIncludeOptions? include) {
    final paths = <String>['transaction.digest', 'transaction.signatures'];

    if (include?.transaction == true) paths.add('transaction.transaction');
    if (include?.effects == true) paths.add('transaction.effects');
    if (include?.events == true) {
      paths.add('transaction.events');
      paths.add('transaction.events.events.json');
    }
    if (include?.balanceChanges == true) {
      paths.add('transaction.balance_changes');
    }
    if (include?.bcs == true) paths.add('transaction.transaction.bcs');
    if (include?.commandResults == true) paths.add('command_outputs');

    return FieldMask(paths: paths);
  }

  ObjectData _parseObject(
    grpc_object.Object obj,
    ObjectIncludeOptions? include,
  ) {
    return ObjectData(
      objectId: obj.objectId,
      version: obj.version.toString(),
      digest: obj.digest,
      owner: obj.hasOwner() ? _mapOwner(obj.owner) : const UnknownOwner(),
      type: obj.objectType,
      previousTransaction: include?.previousTransaction == true
          ? obj.previousTransaction
          : null,
      content: (include?.content == true && obj.hasContents())
          ? Uint8List.fromList(obj.contents.value)
          : null,
      objectBcs: (include?.objectBcs == true && obj.hasBcs())
          ? Uint8List.fromList(obj.bcs.value)
          : null,
      json: (include?.json == true && obj.hasJson())
          ? _protoValueToMap(obj.json)
          : null,
      display: (include?.display == true && obj.hasDisplay())
          ? _protoValueToMap(obj.display.output)
          : null,
    );
  }

  TransactionResponse _parseTransaction(
    ExecutedTransaction tx,
    TransactionIncludeOptions? include,
  ) {
    ExecutionStatus status = const ExecutionStatus(success: true);
    if (tx.hasEffects() && tx.effects.hasStatus()) {
      status = ExecutionStatus(
        success: tx.effects.status.success,
        error: tx.effects.status.hasError()
            ? _parseExecutionError(tx.effects.status.error)
            : null,
      );
    }

    // Extract epoch from effects
    final epoch = (tx.hasEffects() && tx.effects.hasEpoch())
        ? tx.effects.epoch.toString()
        : null;

    // Extract signatures
    final signatures = tx.signatures
        .map((sig) => base64Encode(sig.bcs.value))
        .toList();

    return TransactionResponse(
      digest: tx.digest,
      signatures: signatures,
      epoch: epoch,
      status: status,
      transaction: (include?.transaction == true && tx.hasTransaction())
          ? base64Encode(tx.transaction.writeToBuffer())
          : null,
      effects: (include?.effects == true && tx.hasEffects())
          ? _parseTransactionEffects(tx.effects)
          : null,
      events: (include?.events == true && tx.hasEvents())
          ? tx.events.events.map((event) {
              return Event(
                packageId: event.packageId,
                module: event.module,
                sender: event.sender,
                eventType: event.eventType,
                bcs: event.hasContents()
                    ? Uint8List.fromList(event.contents.value)
                    : Uint8List(0),
                json: event.hasJson() ? _protoValueToMap(event.json) : null,
              );
            }).toList()
          : null,
      balanceChanges: include?.balanceChanges == true
          ? tx.balanceChanges.map((change) {
              return BalanceChange(
                address: change.address,
                coinType: change.coinType,
                amount: change.amount,
              );
            }).toList()
          : null,
      bcs:
          (include?.bcs == true &&
              tx.hasTransaction() &&
              tx.transaction.hasBcs())
          ? Uint8List.fromList(tx.transaction.bcs.value)
          : null,
      checkpoint: tx.hasCheckpoint() ? tx.checkpoint.toString() : null,
      timestampMs: tx.hasTimestamp()
          ? (tx.timestamp.seconds * Int64(1000) +
                    Int64(tx.timestamp.nanos ~/ 1000000))
                .toString()
          : null,
    );
  }

  TransactionEffects _parseTransactionEffects(
    pb_effects.TransactionEffects effects,
  ) {
    return TransactionEffects(
      version: effects.hasVersion() ? effects.version : 2,
      transactionDigest: effects.hasTransactionDigest()
          ? effects.transactionDigest
          : null,
      lamportVersion: effects.hasLamportVersion()
          ? effects.lamportVersion.toString()
          : null,
      status: effects.hasStatus()
          ? ExecutionStatus(
              success: effects.status.success,
              error: effects.status.hasError()
                  ? _parseExecutionError(effects.status.error)
                  : null,
            )
          : null,
      gasUsed: effects.hasGasUsed()
          ? GasUsed(
              computationCost: effects.gasUsed.computationCost.toString(),
              storageCost: effects.gasUsed.storageCost.toString(),
              storageRebate: effects.gasUsed.storageRebate.toString(),
              nonRefundableStorageFee: effects.gasUsed.nonRefundableStorageFee
                  .toString(),
            )
          : null,
      gasObject: effects.hasGasObject()
          ? GasObject(
              objectId: effects.gasObject.objectId,
              inputState: _mapInputObjectState(effects.gasObject.inputState),
              outputState: _mapOutputObjectState(effects.gasObject.outputState),
            )
          : null,
      dependencies: effects.dependencies.isNotEmpty
          ? effects.dependencies.toList()
          : null,
      changedObjects: effects.changedObjects.isNotEmpty
          ? effects.changedObjects.map((obj) {
              return ChangedObject(
                objectId: obj.objectId,
                idOperation: _mapIdOperation(obj.idOperation),
                inputState: _mapInputObjectState(obj.inputState),
                outputState: _mapOutputObjectState(obj.outputState),
                inputVersion: obj.hasInputVersion()
                    ? obj.inputVersion.toString()
                    : null,
                inputDigest: obj.hasInputDigest() ? obj.inputDigest : null,
                inputOwner: obj.hasInputOwner()
                    ? _mapOwner(obj.inputOwner)
                    : null,
                outputVersion: obj.hasOutputVersion()
                    ? obj.outputVersion.toString()
                    : null,
                outputDigest: obj.hasOutputDigest() ? obj.outputDigest : null,
                outputOwner: obj.hasOutputOwner()
                    ? _mapOwner(obj.outputOwner)
                    : null,
                objectType: obj.objectType.isNotEmpty ? obj.objectType : null,
              );
            }).toList()
          : null,
      unchangedConsensusObjects: effects.unchangedConsensusObjects.isNotEmpty
          ? effects.unchangedConsensusObjects.map((obj) {
              return UnchangedConsensusObject(
                kind: _mapUnchangedConsensusObjectKind(obj.kind),
                objectId: obj.objectId,
                version: obj.version.toString(),
                digest: obj.digest.isNotEmpty ? obj.digest : null,
                objectType: obj.objectType.isNotEmpty ? obj.objectType : null,
              );
            }).toList()
          : null,
      eventsDigest: effects.hasEventsDigest() ? effects.eventsDigest : null,
      bcs: effects.hasBcs() ? Uint8List.fromList(effects.bcs.value) : null,
    );
  }

  ExecutionError _parseExecutionError(pb_exec.ExecutionError error) {
    ExecutionErrorDetail? detail;

    switch (error.whichErrorDetails()) {
      case pb_exec.ExecutionError_ErrorDetails.abort:
        detail = AbortDetail(_parseMoveAbort(error.abort));
        break;
      case pb_exec.ExecutionError_ErrorDetails.sizeError:
        detail = SizeErrorDetail(
          size: error.sizeError.size.toString(),
          maxSize: error.sizeError.maxSize.toString(),
        );
        break;
      case pb_exec.ExecutionError_ErrorDetails.commandArgumentError:
        detail = CommandArgumentErrorDetail(
          argument: error.commandArgumentError.argument,
          kind: _mapErrorName(error.commandArgumentError.kind),
        );
        break;
      case pb_exec.ExecutionError_ErrorDetails.typeArgumentError:
        detail = TypeArgumentErrorDetail(
          typeArgument: error.typeArgumentError.typeArgument,
          kind: _mapErrorName(error.typeArgumentError.kind),
        );
        break;
      case pb_exec.ExecutionError_ErrorDetails.packageUpgradeError:
        detail = PackageUpgradeErrorDetail(
          kind: _mapErrorName(error.packageUpgradeError.kind),
          packageId: error.packageUpgradeError.packageId,
        );
        break;
      case pb_exec.ExecutionError_ErrorDetails.indexError:
        detail = IndexErrorDetail(
          index: error.indexError.index,
          subresult: error.indexError.subresult,
        );
        break;
      case pb_exec.ExecutionError_ErrorDetails.objectId:
        detail = ObjectIdErrorDetail(error.objectId);
        break;
      case pb_exec.ExecutionError_ErrorDetails.coinDenyListError:
        detail = CoinDenyListErrorDetail(
          address: error.coinDenyListError.address,
          coinType: error.coinDenyListError.coinType,
        );
        break;
      case pb_exec.ExecutionError_ErrorDetails.congestedObjects:
        detail = CongestedObjectsDetail(
          error.congestedObjects.objects.toList(),
        );
        break;
      case pb_exec.ExecutionError_ErrorDetails.notSet:
        break;
    }

    return ExecutionError(
      message: error.description,
      kind: _mapErrorName(error.kind),
      command: error.hasCommand() ? error.command.toInt() : null,
      detail: detail,
    );
  }

  MoveAbort _parseMoveAbort(pb_exec.MoveAbort abort) {
    String? cleverError;
    String? cleverErrorRaw;

    if (abort.hasCleverError()) {
      final ce = abort.cleverError;
      if (ce.whichValue() == pb_exec.CleverError_Value.rendered) {
        cleverError = ce.rendered;
      } else if (ce.whichValue() == pb_exec.CleverError_Value.raw) {
        cleverErrorRaw = base64Encode(ce.raw);
      }
    }

    return MoveAbort(
      abortCode: abort.abortCode.toString(),
      location: abort.hasLocation()
          ? MoveAbortLocation(
              package: abort.location.package,
              module: abort.location.module,
              function: abort.location.function,
              instruction: abort.location.instruction,
              functionName: abort.location.hasFunctionName()
                  ? abort.location.functionName
                  : null,
            )
          : null,
      cleverError: cleverError,
      cleverErrorRaw: cleverErrorRaw,
    );
  }

  // ---------------------------------------------------------------------------
  // Enum mappers
  // ---------------------------------------------------------------------------

  static Owner _mapOwner(pb_owner.Owner owner) {
    switch (owner.kind) {
      case pb_owner.Owner_OwnerKind.ADDRESS:
        return AddressOwner(owner.address);
      case pb_owner.Owner_OwnerKind.OBJECT:
        return ObjectOwner(owner.address);
      case pb_owner.Owner_OwnerKind.SHARED:
        return SharedOwner(owner.version.toString());
      case pb_owner.Owner_OwnerKind.IMMUTABLE:
        return const ImmutableOwner();
      case pb_owner.Owner_OwnerKind.CONSENSUS_ADDRESS:
        return ConsensusAddressOwner(
          address: owner.address,
          startVersion: owner.version.toString(),
        );
      default:
        return const UnknownOwner();
    }
  }

  static String _mapErrorName(ProtobufEnum? value) {
    if (value == null) return 'UNKNOWN';
    return value.name;
  }

  static String? _mapIdOperation(
    pb_effects.ChangedObject_IdOperation operation,
  ) {
    switch (operation) {
      case pb_effects.ChangedObject_IdOperation.NONE:
        return 'None';
      case pb_effects.ChangedObject_IdOperation.CREATED:
        return 'Created';
      case pb_effects.ChangedObject_IdOperation.DELETED:
        return 'Deleted';
      default:
        return null;
    }
  }

  static String? _mapInputObjectState(
    pb_effects.ChangedObject_InputObjectState state,
  ) {
    switch (state) {
      case pb_effects
          .ChangedObject_InputObjectState
          .INPUT_OBJECT_STATE_DOES_NOT_EXIST:
        return 'DoesNotExist';
      case pb_effects.ChangedObject_InputObjectState.INPUT_OBJECT_STATE_EXISTS:
        return 'Exists';
      default:
        return null;
    }
  }

  static String? _mapOutputObjectState(
    pb_effects.ChangedObject_OutputObjectState state,
  ) {
    switch (state) {
      case pb_effects
          .ChangedObject_OutputObjectState
          .OUTPUT_OBJECT_STATE_DOES_NOT_EXIST:
        return 'DoesNotExist';
      case pb_effects
          .ChangedObject_OutputObjectState
          .OUTPUT_OBJECT_STATE_OBJECT_WRITE:
        return 'ObjectWrite';
      case pb_effects
          .ChangedObject_OutputObjectState
          .OUTPUT_OBJECT_STATE_PACKAGE_WRITE:
        return 'PackageWrite';
      case pb_effects
          .ChangedObject_OutputObjectState
          .OUTPUT_OBJECT_STATE_ACCUMULATOR_WRITE:
        return 'AccumulatorWrite';
      default:
        return null;
    }
  }

  static String? _mapUnchangedConsensusObjectKind(
    pb_effects.UnchangedConsensusObject_UnchangedConsensusObjectKind kind,
  ) {
    switch (kind) {
      case pb_effects
          .UnchangedConsensusObject_UnchangedConsensusObjectKind
          .READ_ONLY_ROOT:
        return 'ReadOnlyRoot';
      case pb_effects
          .UnchangedConsensusObject_UnchangedConsensusObjectKind
          .MUTATE_CONSENSUS_STREAM_ENDED:
        return 'MutateConsensusStreamEnded';
      case pb_effects
          .UnchangedConsensusObject_UnchangedConsensusObjectKind
          .READ_CONSENSUS_STREAM_ENDED:
        return 'ReadConsensusStreamEnded';
      case pb_effects
          .UnchangedConsensusObject_UnchangedConsensusObjectKind
          .CANCELED:
        return 'Canceled';
      case pb_effects
          .UnchangedConsensusObject_UnchangedConsensusObjectKind
          .PER_EPOCH_CONFIG:
        return 'PerEpochConfig';
      default:
        return null;
    }
  }

  static String _mapDynamicFieldKind(DynamicField_DynamicFieldKind kind) {
    switch (kind) {
      case DynamicField_DynamicFieldKind.FIELD:
        return 'DynamicField';
      case DynamicField_DynamicFieldKind.OBJECT:
        return 'DynamicObject';
      default:
        return 'Unknown';
    }
  }

  static String _mapVisibility(FunctionDescriptor_Visibility visibility) {
    switch (visibility) {
      case FunctionDescriptor_Visibility.PRIVATE:
        return 'Private';
      case FunctionDescriptor_Visibility.PUBLIC:
        return 'Public';
      case FunctionDescriptor_Visibility.FRIEND:
        return 'Friend';
      default:
        return 'Unknown';
    }
  }

  static String _mapAbility(Ability ability) {
    switch (ability) {
      case Ability.COPY:
        return 'Copy';
      case Ability.DROP:
        return 'Drop';
      case Ability.STORE:
        return 'Store';
      case Ability.KEY:
        return 'Key';
      default:
        return 'Unknown';
    }
  }

  static NormalizedMoveType _parseNormalizedMoveType(OpenSignature sig) {
    final body = _parseNormalizedMoveTypeBody(sig.body);

    if (sig.reference == OpenSignature_Reference.IMMUTABLE) {
      return MoveTypeReference(body);
    } else if (sig.reference == OpenSignature_Reference.MUTABLE) {
      return MoveTypeMutableReference(body);
    }
    return body;
  }

  static NormalizedMoveType _parseNormalizedMoveTypeBody(
    OpenSignatureBody body,
  ) {
    switch (body.type) {
      case OpenSignatureBody_Type.ADDRESS:
        return const MoveTypePrimitive('Address');
      case OpenSignatureBody_Type.BOOL:
        return const MoveTypePrimitive('Bool');
      case OpenSignatureBody_Type.U8:
        return const MoveTypePrimitive('U8');
      case OpenSignatureBody_Type.U16:
        return const MoveTypePrimitive('U16');
      case OpenSignatureBody_Type.U32:
        return const MoveTypePrimitive('U32');
      case OpenSignatureBody_Type.U64:
        return const MoveTypePrimitive('U64');
      case OpenSignatureBody_Type.U128:
        return const MoveTypePrimitive('U128');
      case OpenSignatureBody_Type.U256:
        return const MoveTypePrimitive('U256');
      case OpenSignatureBody_Type.VECTOR:
        return MoveTypeVector(
          body.typeParameterInstantiation.isNotEmpty
              ? _parseNormalizedMoveTypeBody(
                  body.typeParameterInstantiation.first,
                )
              : null,
        );
      case OpenSignatureBody_Type.DATATYPE:
        final parts = body.typeName.split('::');
        return MoveTypeStruct(
          address: parts.first,
          module: parts.length > 1 ? parts[1] : '',
          name: parts.length > 2 ? parts[2] : '',
          typeArguments: body.typeParameterInstantiation
              .map(_parseNormalizedMoveTypeBody)
              .toList(),
        );
      case OpenSignatureBody_Type.TYPE_PARAMETER:
        return MoveTypeParameter(body.typeParameter);
      default:
        return const MoveTypePrimitive('Unknown');
    }
  }
}
