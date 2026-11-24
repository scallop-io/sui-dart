import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/builder/transaction_block_data.dart'
    show tryParseTransactionData;
import 'package:sui_dart/cryptography/intent.dart' show IntentScope;
import 'package:sui_dart/builder/transaction.dart'
    show
        ResolvedSimulation,
        SerializeTransactionOptions,
        Transaction,
        TransactionPlugin,
        simulationResolvePlugin;
import 'package:sui_dart/core/sui_core_client.dart';
import 'package:sui_dart/grpc/grpc_core_client.dart' show GrpcCoreClient;
import 'package:sui_dart/grpc/types.dart';
import 'package:sui_dart/types/common.dart'
    show normalizeStructTagString, normalizeSuiAddress;
import 'package:sui_dart/types/framework.dart' show MOCKED_GAS_OBJECT_ID;

import 'graphql_operation.dart';
import 'operations.graphql.dart' as generated;
import 'schema.graphql.dart' as schema;
import 'sui_graphql_client.dart';

// Aliases for long generated type names.
typedef _MgoObject = generated.Query$MultiGetObjects$multiGetObjects;
typedef _OwnedNode = generated.Query$GetOwnedObjects$address$objects$nodes;
typedef _CoreOwner = generated.Fragment$CoreOwnerFields;
typedef _CoreAddressOwner = generated.Fragment$CoreOwnerFields$$AddressOwner;
typedef _CoreObjectOwner = generated.Fragment$CoreOwnerFields$$ObjectOwner;
typedef _CoreShared = generated.Fragment$CoreOwnerFields$$Shared;
typedef _CoreConsensusOwner =
    generated.Fragment$CoreOwnerFields$$ConsensusAddressOwner;
typedef _CoreImmutable = generated.Fragment$CoreOwnerFields$$Immutable;
typedef _DfNode = generated.Query$GetDynamicFields$address$dynamicFields$nodes;
typedef _DfMoveObjectValue =
    generated.Query$GetDynamicFields$address$dynamicFields$nodes$value$$MoveObject;
typedef _DfMoveValue =
    generated.Query$GetDynamicFields$address$dynamicFields$nodes$value$$MoveValue;
typedef _SimCommand =
    generated.Query$SimulateTransaction$simulateTransaction$outputs;
typedef _ListedEvent = generated.Query$ListEvents$events$nodes;

/// GraphQL-backed [SuiCoreClient]. [executeTransaction] and
/// [verifyZkLoginSignature] throw `UnsupportedError`; use the gRPC transport
/// for those.

/// Chunk size for `multiGetObjects`. The node caps request bytes, not key
/// count, so this is a safe chunk rather than the node's own threshold.
const _objectBatchSize = 40;

class GraphQLCoreClient implements SuiCoreClient {
  GraphQLCoreClient(this._client);

  final SuiGraphQLClient _client;

  static final _getBalanceOperation =
      GraphQLOperation<
        generated.Query$GetBalance,
        generated.Variables$Query$GetBalance
      >(
        document: generated.documentNodeQueryGetBalance,
        operationName: 'GetBalance',
        decodeData: generated.Query$GetBalance.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _getAllBalancesOperation =
      GraphQLOperation<
        generated.Query$GetAllBalances,
        generated.Variables$Query$GetAllBalances
      >(
        document: generated.documentNodeQueryGetAllBalances,
        operationName: 'GetAllBalances',
        decodeData: generated.Query$GetAllBalances.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _multiGetObjectsOperation =
      GraphQLOperation<
        generated.Query$MultiGetObjects,
        generated.Variables$Query$MultiGetObjects
      >(
        document: generated.documentNodeQueryMultiGetObjects,
        operationName: 'MultiGetObjects',
        decodeData: generated.Query$MultiGetObjects.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _getOwnedObjectsOperation =
      GraphQLOperation<
        generated.Query$GetOwnedObjects,
        generated.Variables$Query$GetOwnedObjects
      >(
        document: generated.documentNodeQueryGetOwnedObjects,
        operationName: 'GetOwnedObjects',
        decodeData: generated.Query$GetOwnedObjects.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _getCoinMetadataOperation =
      GraphQLOperation<
        generated.Query$GetCoinMetadata,
        generated.Variables$Query$GetCoinMetadata
      >(
        document: generated.documentNodeQueryGetCoinMetadata,
        operationName: 'GetCoinMetadata',
        decodeData: generated.Query$GetCoinMetadata.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _getEpochOperation =
      GraphQLOperation<generated.Query$GetEpoch, GraphQLNoVariables>(
        document: generated.documentNodeQueryGetEpoch,
        operationName: 'GetEpoch',
        decodeData: generated.Query$GetEpoch.fromJson,
        encodeVariables: (_) => const {},
      );

  static final _getDynamicFieldsOperation =
      GraphQLOperation<
        generated.Query$GetDynamicFields,
        generated.Variables$Query$GetDynamicFields
      >(
        document: generated.documentNodeQueryGetDynamicFields,
        operationName: 'GetDynamicFields',
        decodeData: generated.Query$GetDynamicFields.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _resolveTransactionOperation =
      GraphQLOperation<
        generated.Query$ResolveTransaction,
        generated.Variables$Query$ResolveTransaction
      >(
        document: generated.documentNodeQueryResolveTransaction,
        operationName: 'ResolveTransaction',
        decodeData: generated.Query$ResolveTransaction.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _simulateTransactionOperation =
      GraphQLOperation<
        generated.Query$SimulateTransaction,
        generated.Variables$Query$SimulateTransaction
      >(
        document: generated.documentNodeQuerySimulateTransaction,
        operationName: 'SimulateTransaction',
        decodeData: generated.Query$SimulateTransaction.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _getMoveFunctionOperation =
      GraphQLOperation<
        generated.Query$GetMoveFunction,
        generated.Variables$Query$GetMoveFunction
      >(
        document: generated.documentNodeQueryGetMoveFunction,
        operationName: 'GetMoveFunction',
        decodeData: generated.Query$GetMoveFunction.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _getTransactionOperation =
      GraphQLOperation<
        generated.Query$GetTransaction,
        generated.Variables$Query$GetTransaction
      >(
        document: generated.documentNodeQueryGetTransaction,
        operationName: 'GetTransaction',
        decodeData: generated.Query$GetTransaction.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _getTransactionEventsOperation =
      GraphQLOperation<
        generated.Query$GetTransactionEvents,
        generated.Variables$Query$GetTransactionEvents
      >(
        document: generated.documentNodeQueryGetTransactionEvents,
        operationName: 'GetTransactionEvents',
        decodeData: generated.Query$GetTransactionEvents.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _getTransactionBalanceChangesOperation =
      GraphQLOperation<
        generated.Query$GetTransactionBalanceChanges,
        generated.Variables$Query$GetTransactionBalanceChanges
      >(
        document: generated.documentNodeQueryGetTransactionBalanceChanges,
        operationName: 'GetTransactionBalanceChanges',
        decodeData: generated.Query$GetTransactionBalanceChanges.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _defaultNameServiceNameOperation =
      GraphQLOperation<
        generated.Query$GetDefaultNameServiceName,
        generated.Variables$Query$GetDefaultNameServiceName
      >(
        document: generated.documentNodeQueryGetDefaultNameServiceName,
        operationName: 'GetDefaultNameServiceName',
        decodeData: generated.Query$GetDefaultNameServiceName.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _resolveNameServiceAddressOperation =
      GraphQLOperation<
        generated.Query$ResolveNameServiceAddress,
        generated.Variables$Query$ResolveNameServiceAddress
      >(
        document: generated.documentNodeQueryResolveNameServiceAddress,
        operationName: 'ResolveNameServiceAddress',
        decodeData: generated.Query$ResolveNameServiceAddress.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _getProtocolConfigOperation =
      GraphQLOperation<generated.Query$GetProtocolConfig, GraphQLNoVariables>(
        document: generated.documentNodeQueryGetProtocolConfig,
        operationName: 'GetProtocolConfig',
        decodeData: generated.Query$GetProtocolConfig.fromJson,
        encodeVariables: (_) => const {},
      );

  static final _listTransactionsOperation =
      GraphQLOperation<
        generated.Query$ListTransactions,
        generated.Variables$Query$ListTransactions
      >(
        document: generated.documentNodeQueryListTransactions,
        operationName: 'ListTransactions',
        decodeData: generated.Query$ListTransactions.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static final _listEventsOperation =
      GraphQLOperation<
        generated.Query$ListEvents,
        generated.Variables$Query$ListEvents
      >(
        document: generated.documentNodeQueryListEvents,
        operationName: 'ListEvents',
        decodeData: generated.Query$ListEvents.fromJson,
        encodeVariables: (v) => v.toJson(),
      );

  static Never _unsupported(String method) => throw UnsupportedError(
    'GraphQLCoreClient.$method is unavailable on the GraphQL transport; use the gRPC transport',
  );

  static Balance _mapBalance(generated.Fragment$CoreBalanceFields balance) =>
      Balance(
        coinType: balance.coinType?.repr ?? '',
        balance: balance.totalBalance ?? '0',
        coinBalance: balance.coinBalance ?? '0',
        addressBalance: balance.addressBalance ?? '0',
      );

  static ObjectData _mapObject(_MgoObject obj) {
    final contents = obj.asMoveObject?.contents;
    return ObjectData(
      objectId: obj.address,
      version: obj.version?.toString() ?? '',
      digest: obj.digest ?? '',
      owner: _mapOwner(obj.owner),
      type:
          contents?.type?.repr ?? (obj.asMovePackage != null ? 'package' : ''),
      json: contents?.json,
      content: contents?.bcs == null ? null : base64Decode(contents!.bcs!),
      objectBcs: obj.objectBcs == null ? null : base64Decode(obj.objectBcs!),
      previousTransaction: obj.previousTransaction?.digest,
      display: contents?.display?.output,
    );
  }

  static ObjectData _mapOwnedObject(_OwnedNode node) {
    final contents = node.contents;
    return ObjectData(
      objectId: node.address,
      version: node.version?.toString() ?? '',
      digest: node.digest ?? '',
      owner: _mapOwner(node.owner),
      type: contents?.type?.repr ?? '',
      json: contents?.json,
      content: contents?.bcs == null ? null : base64Decode(contents!.bcs!),
      objectBcs: node.objectBcs == null ? null : base64Decode(node.objectBcs!),
      previousTransaction: node.previousTransaction?.digest,
      display: contents?.display?.output,
    );
  }

  static CoinData _mapCoin(_OwnedNode node) {
    final contents = node.contents;
    return CoinData(
      objectId: node.address,
      version: node.version?.toString() ?? '',
      digest: node.digest ?? '',
      owner: _mapOwner(node.owner),
      type: contents?.type?.repr ?? '',
      balance: contents?.json?['balance']?.toString() ?? '0',
    );
  }

  static Owner _mapOwner(_CoreOwner? owner) => switch (owner) {
    _CoreAddressOwner o => AddressOwner(o.address?.address ?? ''),
    _CoreObjectOwner o => ObjectOwner(o.address?.address ?? ''),
    _CoreShared o => SharedOwner(o.initialSharedVersion?.toString() ?? '0'),
    _CoreConsensusOwner o => ConsensusAddressOwner(
      address: o.address?.address ?? '',
      startVersion: o.startVersion?.toString() ?? '0',
    ),
    _CoreImmutable() => const ImmutableOwner(),
    _ => const UnknownOwner(),
  };

  static DynamicFieldEntry _mapDynamicField(_DfNode node) {
    final name = DynamicFieldName(
      type: node.name?.type?.repr,
      bcs: node.name?.bcs == null ? null : base64Decode(node.name!.bcs!),
    );
    final value = node.value;
    if (value is _DfMoveObjectValue) {
      return DynamicFieldEntry(
        name: name,
        objectType: value.contents?.type?.repr ?? '',
        objectId: value.address,
        type: 'DynamicObject',
      );
    }
    if (value is _DfMoveValue) {
      return DynamicFieldEntry(
        name: name,
        objectType: value.type?.repr ?? '',
        objectId: node.address,
        type: 'DynamicField',
        value: value.bcs == null ? null : base64Decode(value.bcs!),
      );
    }
    return DynamicFieldEntry(
      name: name,
      objectType: '',
      objectId: node.address,
      type: 'Unknown',
    );
  }

  static Uint8List _decodeBcs(String? bcs) =>
      bcs == null ? Uint8List(0) : base64Decode(bcs);

  static String _mapVisibility(schema.Enum$MoveVisibility? visibility) =>
      switch (visibility) {
        schema.Enum$MoveVisibility.PUBLIC => 'Public',
        schema.Enum$MoveVisibility.PRIVATE => 'Private',
        schema.Enum$MoveVisibility.FRIEND => 'Friend',
        _ => 'Unknown',
      };

  static String _mapAbility(schema.Enum$MoveAbility ability) =>
      switch (ability) {
        schema.Enum$MoveAbility.COPY => 'Copy',
        schema.Enum$MoveAbility.DROP => 'Drop',
        schema.Enum$MoveAbility.KEY => 'Key',
        schema.Enum$MoveAbility.STORE => 'Store',
        _ => 'Unknown',
      };

  static CommandResult _mapSimCommand(_SimCommand cmd) => CommandResult(
    returnValues:
        cmd.returnValues
            ?.map((v) => CommandOutput(bcs: _decodeBcs(v.value?.bcs)))
            .toList() ??
        const [],
    mutatedReferences:
        cmd.mutatedReferences
            ?.map((v) => CommandOutput(bcs: _decodeBcs(v.value?.bcs)))
            .toList() ??
        const [],
  );

  @override
  TransactionPlugin resolveTransactionPlugin() =>
      simulationResolvePlugin(this, simulate: _resolveSimulate);

  Future<ResolvedSimulation> _resolveSimulate(
    Transaction request, {
    required bool doGasSelection,
    required bool checksEnabled,
  }) async {
    final data = await _client.executeData(
      _resolveTransactionOperation,
      generated.Variables$Query$ResolveTransaction(
        transaction:
            request.toGrpcTransaction().toProto3Json() as Map<String, dynamic>,
        doGasSelection: doGasSelection,
        checksEnabled: checksEnabled,
      ),
    );
    final transaction = data.simulateTransaction.effects?.transaction;
    final effects = transaction?.effects;
    final error = effects?.executionError;
    final bcs = transaction?.transactionBcs;
    return (
      bcs: bcs == null ? null : base64Decode(bcs),
      epoch: effects?.epoch?.epochId.toString(),
      status: ExecutionStatus(
        success: effects?.status == schema.Enum$ExecutionStatus.SUCCESS,
        error: error == null
            ? null
            : _parseExecutionError(
                message: error.message,
                abortCode: error.abortCode,
                sourceLineNumber: error.sourceLineNumber,
                instructionOffset: error.instructionOffset,
                identifier: error.identifier,
                constant: error.constant,
                package: error.module?.package?.address,
                module: error.module?.name,
                functionName: error.function?.name,
              ),
      ),
    );
  }

  @override
  Future<List<ObjectResult>> getObjects(
    List<String> objectIds, {
    ObjectIncludeOptions? include,
  }) async {
    if (objectIds.isEmpty) return const [];
    final results = <ObjectResult>[];
    for (var start = 0; start < objectIds.length; start += _objectBatchSize) {
      final stop = start + _objectBatchSize;
      final batch = objectIds.sublist(
        start,
        stop < objectIds.length ? stop : objectIds.length,
      );
      final data = await _client.executeData(
        _multiGetObjectsOperation,
        generated.Variables$Query$MultiGetObjects(
          keys: batch.map((id) => schema.Input$ObjectKey(address: id)).toList(),
          includeContent: include?.content,
          includePreviousTransaction: include?.previousTransaction,
          includeObjectBcs: include?.objectBcs,
          includeDisplay: include?.display,
        ),
      );
      final objects = data.multiGetObjects;
      for (var i = 0; i < objects.length; i++) {
        results.add(
          objects[i] == null
              ? ObjectError(
                  'Object ${batch[i]} not found',
                  code: 'notExists',
                  reason: ObjectErrorReason.notFound,
                  objectId: batch[i],
                )
              : ObjectSuccess(_mapObject(objects[i]!)),
        );
      }
    }
    return results;
  }

  @override
  Future<Page<ObjectData>> getOwnedObjects(
    String address, {
    String? type,
    String? cursor,
    int? limit,
    ObjectIncludeOptions? include,
  }) async {
    final data = await _client.executeData(
      _getOwnedObjectsOperation,
      generated.Variables$Query$GetOwnedObjects(
        address: address,
        type: type,
        first: limit,
        after: cursor,
        includeContent: include?.content,
        includePreviousTransaction: include?.previousTransaction,
        includeObjectBcs: include?.objectBcs,
        includeDisplay: include?.display,
      ),
    );
    final connection = data.address?.objects;
    if (connection == null) return const Page(data: [], hasNextPage: false);
    return Page(
      data: connection.nodes.map(_mapOwnedObject).toList(),
      hasNextPage: connection.pageInfo.hasNextPage,
      nextCursor: connection.pageInfo.endCursor,
    );
  }

  @override
  Future<Page<CoinData>> getCoins(
    String address, {
    String coinType = '0x2::sui::SUI',
    String? cursor,
    int? limit,
  }) async {
    final normalized = normalizeStructTagString(coinType);
    final data = await _client.executeData(
      _getOwnedObjectsOperation,
      generated.Variables$Query$GetOwnedObjects(
        address: address,
        type: '0x2::coin::Coin<$normalized>',
        first: limit,
        after: cursor,
      ),
    );
    final connection = data.address?.objects;
    if (connection == null) return const Page(data: [], hasNextPage: false);
    return Page(
      data: connection.nodes.map(_mapCoin).toList(),
      hasNextPage: connection.pageInfo.hasNextPage,
      nextCursor: connection.pageInfo.endCursor,
    );
  }

  @override
  Future<Balance> getBalance(
    String address, {
    String coinType = '0x2::sui::SUI',
  }) async {
    final normalized = normalizeStructTagString(coinType);
    final data = await _client.executeData(
      _getBalanceOperation,
      generated.Variables$Query$GetBalance(
        address: address,
        coinType: normalized,
      ),
    );
    final balance = data.address?.balance;
    if (balance == null) {
      return Balance(
        coinType: normalized,
        balance: '0',
        coinBalance: '0',
        addressBalance: '0',
      );
    }
    return _mapBalance(balance);
  }

  @override
  Future<CoinMetadata?> getCoinMetadata(String coinType) async {
    final normalized = normalizeStructTagString(coinType);
    final data = await _client.executeData(
      _getCoinMetadataOperation,
      generated.Variables$Query$GetCoinMetadata(coinType: normalized),
    );
    final metadata = data.coinMetadata;
    if (metadata == null) return null;
    return CoinMetadata(
      id: metadata.address,
      decimals: metadata.decimals ?? 0,
      name: metadata.name ?? '',
      symbol: metadata.symbol ?? '',
      description: metadata.description ?? '',
      iconUrl: metadata.iconUrl,
    );
  }

  @override
  Future<List<Balance>> getAllBalances(String address) async {
    final balances = <Balance>[];
    String? after;
    while (true) {
      final data = await _client.executeData(
        _getAllBalancesOperation,
        generated.Variables$Query$GetAllBalances(
          address: address,
          first: 50,
          after: after,
        ),
      );
      final connection = data.address?.balances;
      if (connection == null) break;
      balances.addAll(connection.nodes.map(_mapBalance));
      if (!connection.pageInfo.hasNextPage) break;
      after = connection.pageInfo.endCursor;
      if (after == null) break;
    }
    return balances;
  }

  @override
  Future<TransactionResponse> getTransaction(
    String digest, {
    TransactionIncludeOptions? include,
  }) async {
    final data = await _client.executeData(
      _getTransactionOperation,
      generated.Variables$Query$GetTransaction(
        digest: digest,
        includeEffects: include?.effects,
        includeEvents: include?.events,
        includeBalanceChanges: include?.balanceChanges,
        includeEffectsJson:
            include?.effects == true || include?.objectTypes == true
            ? true
            : null,
        includeBcs: include?.bcs == true || include?.transaction == true
            ? true
            : null,
      ),
    );
    final tx = data.transaction;
    if (tx == null) {
      throw TransactionError(TransactionErrorReason.notFound, digest);
    }
    return _mapTransaction(tx, include);
  }

  Future<TransactionResponse> _mapTransaction(
    generated.Fragment$CoreTransactionFields tx,
    TransactionIncludeOptions? include,
  ) async {
    final effects = tx.effects;
    final timestamp = effects?.timestamp;
    final error = effects?.executionError;
    final status = ExecutionStatus(
      success: effects?.status == schema.Enum$ExecutionStatus.SUCCESS,
      error: error == null
          ? null
          : _parseExecutionError(
              message: error.message,
              abortCode: error.abortCode,
              sourceLineNumber: error.sourceLineNumber,
              instructionOffset: error.instructionOffset,
              identifier: error.identifier,
              constant: error.constant,
              package: error.module?.package?.address,
              module: error.module?.name,
              functionName: error.function?.name,
            ),
    );
    final effectsJson = effects?.effectsJson;
    final parsed = effectsJson == null
        ? null
        : GrpcCoreClient.parseEffectsJson(effectsJson);
    return TransactionResponse(
      digest: tx.digest,
      signatures: [
        for (final sig in tx.signatures)
          if (sig.signatureBytes != null) sig.signatureBytes!,
      ],
      epoch: effects?.epoch?.epochId.toString(),
      status: status,
      effects: include?.effects == true && parsed != null
          ? TransactionEffects(
              bcs: effects?.effectsBcs == null
                  ? null
                  : base64Decode(effects!.effectsBcs!),
              version: parsed.version,
              transactionDigest: parsed.transactionDigest,
              lamportVersion: parsed.lamportVersion,
              status: parsed.status,
              gasUsed: parsed.gasUsed,
              gasObject: parsed.gasObject,
              dependencies: parsed.dependencies,
              changedObjects: parsed.changedObjects,
              unchangedConsensusObjects: parsed.unchangedConsensusObjects,
              eventsDigest: parsed.eventsDigest,
              auxiliaryDataDigest: parsed.auxiliaryDataDigest,
            )
          : null,
      events: include?.events == true
          ? await _allEvents(tx.digest, effects?.events)
          : null,
      balanceChanges: include?.balanceChanges == true
          ? await _allBalanceChanges(tx.digest, effects?.balanceChanges)
          : null,
      objectTypes: include?.objectTypes == true
          ? {
              for (final obj
                  in parsed?.changedObjects ?? const <ChangedObject>[])
                if (obj.objectType case final type?) obj.objectId: type,
            }
          : null,
      transaction: include?.transaction == true && tx.transactionBcs != null
          ? tryParseTransactionData(base64Decode(tx.transactionBcs!))
          : null,
      bcs: include?.bcs == true && tx.transactionBcs != null
          ? base64Decode(tx.transactionBcs!)
          : null,
      timestampMs: timestamp == null
          ? null
          : DateTime.tryParse(timestamp)?.millisecondsSinceEpoch.toString(),
      checkpoint: effects?.checkpoint?.sequenceNumber.toString(),
    );
  }

  Future<List<Event>> _allEvents(
    String digest,
    generated.Fragment$CoreEventPage? page,
  ) async {
    final events = <Event>[];
    while (page != null) {
      for (final node in page.nodes) {
        final type = node.contents?.type?.repr ?? '';
        events.add(
          Event(
            packageId:
                node.transactionModule?.package?.address ??
                type.split('::').first,
            module: node.transactionModule?.name ?? '',
            sender: node.sender?.address ?? '',
            eventType: type,
            bcs: _decodeBcs(node.contents?.bcs),
            json: node.contents?.json,
          ),
        );
      }
      if (!page.pageInfo.hasNextPage) break;
      final data = await _client.executeData(
        _getTransactionEventsOperation,
        generated.Variables$Query$GetTransactionEvents(
          digest: digest,
          after: page.pageInfo.endCursor,
        ),
      );
      page = data.transaction?.effects?.events;
    }
    return events;
  }

  Future<List<BalanceChange>> _allBalanceChanges(
    String digest,
    generated.Fragment$CoreBalanceChangePage? page,
  ) async {
    final changes = <BalanceChange>[];
    while (page != null) {
      for (final node in page.nodes) {
        changes.add(
          BalanceChange(
            address: node.owner?.address ?? '',
            coinType: node.coinType?.repr ?? '',
            amount: node.amount ?? '0',
          ),
        );
      }
      if (!page.pageInfo.hasNextPage) break;
      final data = await _client.executeData(
        _getTransactionBalanceChangesOperation,
        generated.Variables$Query$GetTransactionBalanceChanges(
          digest: digest,
          after: page.pageInfo.endCursor,
        ),
      );
      page = data.transaction?.effects?.balanceChanges;
    }
    return changes;
  }

  @override
  Future<TransactionResponse> executeTransaction(
    Uint8List transactionBytes,
    List<String> signatures, {
    TransactionIncludeOptions? include,
  }) => _unsupported('executeTransaction');

  @override
  Future<TransactionResponse> simulateTransaction(
    Transaction transactionBlock, {
    TransactionIncludeOptions? include,
    bool? doGasSelection,
    bool? checksEnabled,
  }) async {
    // gRPC conversion is synchronous, so intents must resolve before it.
    if (!transactionBlock.isPreparedForSerialization()) {
      await transactionBlock.prepareForSerialization(
        SerializeTransactionOptions(client: this),
      );
    }
    final txJson =
        transactionBlock.toGrpcSimulationTransaction().toProto3Json()
            as Map<String, dynamic>;
    final payment = transactionBlock.getData().gasData.payment;
    final data = await _client.executeData(
      _simulateTransactionOperation,
      generated.Variables$Query$SimulateTransaction(
        tx: txJson,
        checksEnabled: checksEnabled,
        doGasSelection: doGasSelection ?? (payment != null && payment.isEmpty),
        includeEffects: include?.effects,
        includeEvents: include?.events,
        includeBalanceChanges: include?.balanceChanges,
        includeEffectsJson:
            include?.effects == true || include?.objectTypes == true
            ? true
            : null,
        includeBcs: include?.bcs == true || include?.transaction == true
            ? true
            : null,
      ),
    );
    final result = data.simulateTransaction;
    final tx = result.effects?.transaction;
    final gasObjectId = tx?.effects?.gasEffects?.gasObject?.address;
    final mapped = tx == null
        ? const TransactionResponse(digest: '')
        : await _mapTransaction(tx, include);
    return mapped.copyWith(
      commandResults: result.outputs?.map(_mapSimCommand).toList(),
      gasPaymentMocked:
          gasObjectId != null &&
          normalizeSuiAddress(gasObjectId) == MOCKED_GAS_OBJECT_ID,
    );
  }

  ExecutionError _parseExecutionError({
    required String message,
    String? abortCode,
    int? sourceLineNumber,
    int? instructionOffset,
    String? identifier,
    String? constant,
    String? package,
    String? module,
    String? functionName,
  }) {
    // the failing command is only in the message ("in 3rd command")
    final match = RegExp(r'in (\d+)\w* command').firstMatch(message);
    final command = match == null ? null : int.parse(match.group(1)!) - 1;
    if (abortCode == null) {
      return ExecutionError(
        message: message,
        kind: 'UNKNOWN',
        command: command,
      );
    }
    final location = package == null || module == null
        ? null
        : MoveAbortLocation(
            package: package,
            module: module,
            functionName: functionName,
            instruction: instructionOffset,
          );
    // the server sends a source line only for a clever error
    final clever = sourceLineNumber != null;
    return ExecutionError(
      message: formatMoveAbortMessage(
        command: command,
        location: location,
        abortCode: abortCode,
        cleverLineNumber: clever ? sourceLineNumber : null,
        cleverConstantName: identifier,
        cleverValue: constant,
      ),
      kind: 'MOVE_ABORT',
      command: command,
      detail: AbortDetail(
        MoveAbort(
          abortCode: abortCode,
          location: location,
          cleverError: constant,
        ),
      ),
    );
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
    validateCheckpointRange(startCheckpoint, endCheckpoint);

    final data = await _client.executeData(
      _listTransactionsOperation,
      generated.Variables$Query$ListTransactions(
        filter: schema.Input$TransactionFilter(
          sentAddress: resolved?.sender,
          function: resolved?.package == null ? null : resolved!.functionTarget,
          afterCheckpoint: _afterCheckpoint(startCheckpoint),
          beforeCheckpoint: endCheckpoint,
        ),
        first: pagination.descending ? null : pagination.limit,
        after: pagination.after,
        last: pagination.descending ? pagination.limit : null,
        before: pagination.before,
        includeEffects: include?.effects,
        includeEvents: include?.events,
        includeBalanceChanges: include?.balanceChanges,
        includeEffectsJson:
            include?.effects == true || include?.objectTypes == true
            ? true
            : null,
        includeBcs: include?.bcs == true || include?.transaction == true
            ? true
            : null,
      ),
    );

    final connection = data.transactions;
    if (connection == null) {
      return Page(data: const [], hasNextPage: false);
    }
    // Reading back returns nodes ascending, so flip them for a descending page.
    final nodes = pagination.descending
        ? connection.nodes.reversed.toList()
        : connection.nodes;

    return _pageOf(
      await Future.wait(nodes.map((tx) => _mapTransaction(tx, include))),
      descending: pagination.descending,
      hasNextPage: connection.pageInfo.hasNextPage,
      hasPreviousPage: connection.pageInfo.hasPreviousPage,
      startCursor: connection.pageInfo.startCursor,
      endCursor: connection.pageInfo.endCursor,
    );
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
    validateCheckpointRange(startCheckpoint, endCheckpoint);

    final data = await _client.executeData(
      _listEventsOperation,
      generated.Variables$Query$ListEvents(
        filter: schema.Input$EventFilter(
          sender: resolved?.sender,
          module: resolved?.emitModule,
          type: resolved?.eventType,
          afterCheckpoint: _afterCheckpoint(startCheckpoint),
          beforeCheckpoint: endCheckpoint,
        ),
        first: pagination.descending ? null : pagination.limit,
        after: pagination.after,
        last: pagination.descending ? pagination.limit : null,
        before: pagination.before,
      ),
    );

    final connection = data.events;
    if (connection == null) {
      return Page(data: const [], hasNextPage: false);
    }
    final nodes = pagination.descending
        ? connection.nodes.reversed.toList()
        : connection.nodes;

    return _pageOf(
      nodes.map(_mapListedEvent).toList(),
      descending: pagination.descending,
      hasNextPage: connection.pageInfo.hasNextPage,
      hasPreviousPage: connection.pageInfo.hasPreviousPage,
      startCursor: connection.pageInfo.startCursor,
      endCursor: connection.pageInfo.endCursor,
    );
  }

  /// GraphQL's bound is exclusive; [startCheckpoint] is inclusive.
  static int? _afterCheckpoint(int? startCheckpoint) =>
      startCheckpoint == null || startCheckpoint == 0
      ? null
      : startCheckpoint - 1;

  /// Reading back reverses the connection, so the cursors and flag swap ends.
  static Page<T> _pageOf<T>(
    List<T> data, {
    required bool descending,
    required bool hasNextPage,
    required bool hasPreviousPage,
    required String? startCursor,
    required String? endCursor,
  }) {
    return Page(
      data: data,
      hasNextPage: descending ? hasPreviousPage : hasNextPage,
      nextCursor: descending ? startCursor : endCursor,
      startCursor: descending ? endCursor : startCursor,
    );
  }

  static Event _mapListedEvent(_ListedEvent event) {
    final packageId = event.transactionModule?.package?.address;
    final module = event.transactionModule?.name;
    // system transactions have no sender
    final sender = event.sender?.address ?? '0x0';
    final eventType = event.contents?.type?.repr;
    final digest = event.transaction?.digest;

    if (packageId == null ||
        module == null ||
        eventType == null ||
        digest == null) {
      throw const GraphQLResponseDecodingException(
        'ListEvents',
        'event is missing required fields',
      );
    }

    return Event(
      packageId: normalizeSuiAddress(packageId),
      module: module,
      sender: normalizeSuiAddress(sender),
      eventType: normalizeStructTagString(eventType),
      bcs: _decodeBcs(event.contents?.bcs),
      json: event.contents?.json,
      checkpoint: event.transaction?.effects?.checkpoint?.sequenceNumber
          .toString(),
      transactionDigest: digest,
      eventIndex: event.sequenceNumber,
    );
  }

  @override
  Future<String> getReferenceGasPrice() async {
    final data = await _client.executeData(
      _getEpochOperation,
      const GraphQLNoVariables(),
    );
    return data.epoch?.referenceGasPrice ?? '0';
  }

  @override
  Future<SystemState> getCurrentSystemState() async {
    final data = await _client.executeData(
      _getEpochOperation,
      const GraphQLNoVariables(),
    );
    final epoch = data.epoch;
    final start = epoch?.startTimestamp;
    return SystemState(
      epoch: epoch?.epochId.toString() ?? '0',
      referenceGasPrice: epoch?.referenceGasPrice ?? '0',
      epochStartTimestampMs: start == null
          ? null
          : DateTime.tryParse(start)?.millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<ProtocolConfig> getProtocolConfig() async {
    final data = await _client.executeData(
      _getProtocolConfigOperation,
      const GraphQLNoVariables(),
    );
    final configs = data.protocolConfigs;
    return ProtocolConfig(
      protocolVersion: configs?.protocolVersion.toString() ?? '0',
      featureFlags: {
        for (final flag in configs?.featureFlags ?? []) flag.key: flag.value,
      },
      attributes: {
        for (final config in configs?.configs ?? []) config.key: config.value,
      },
    );
  }

  @override
  Future<Page<DynamicFieldEntry>> getDynamicFields(
    String parentId, {
    String? cursor,
    int? limit,
    bool includeValue = false,
  }) async {
    final data = await _client.executeData(
      _getDynamicFieldsOperation,
      generated.Variables$Query$GetDynamicFields(
        parentId: parentId,
        first: limit,
        after: cursor,
        includeValue: includeValue,
      ),
    );
    final connection = data.address?.dynamicFields;
    if (connection == null) return const Page(data: [], hasNextPage: false);
    return Page(
      data: connection.nodes.map(_mapDynamicField).toList(),
      hasNextPage: connection.pageInfo.hasNextPage,
      nextCursor: connection.pageInfo.endCursor,
    );
  }

  @override
  Future<VerifySignatureResult> verifyZkLoginSignature(
    Uint8List bytes,
    String signature, {
    String? address,
    IntentScope intentScope = IntentScope.transactionData,
  }) => _unsupported('verifyZkLoginSignature');

  @override
  Future<String?> defaultNameServiceName(String address) async {
    final data = await _client.executeData(
      _defaultNameServiceNameOperation,
      generated.Variables$Query$GetDefaultNameServiceName(address: address),
    );
    return data.address?.defaultNameRecord?.domain;
  }

  @override
  Future<String?> resolveNameServiceAddress(String name) async {
    final data = await _client.executeData(
      _resolveNameServiceAddressOperation,
      generated.Variables$Query$ResolveNameServiceAddress(name: name),
    );
    return data.address?.address;
  }

  @override
  Future<MoveFunction> getMoveFunction(
    String packageId,
    String moduleName,
    String functionName,
  ) async {
    final data = await _client.executeData(
      _getMoveFunctionOperation,
      generated.Variables$Query$GetMoveFunction(
        package: packageId,
        module: moduleName,
        function: functionName,
      ),
    );
    final fn = data.package?.module?.function;
    if (fn == null) {
      throw Exception(
        'Move function not found: $packageId::$moduleName::$functionName',
      );
    }
    return MoveFunction(
      name: fn.name,
      visibility: _mapVisibility(fn.visibility),
      isEntry: fn.isEntry ?? false,
      typeParameters:
          fn.typeParameters
              ?.map(
                (tp) => TypeParameter(
                  abilities: tp.constraints.map(_mapAbility).toList(),
                ),
              )
              .toList() ??
          const [],
      parameters: [
        for (final p in fn.parameters ?? const []) _parseSignature(p.signature),
      ],
      returnTypes: [
        for (final r in fn.$return ?? const []) _parseSignature(r.signature),
      ],
    );
  }

  /// `{ref: '&' | '&mut' | null, body: ...}`
  static NormalizedMoveType _parseSignature(Map<String, dynamic> signature) {
    final body = _parseSignatureBody(signature['body']);
    return switch (signature['ref']) {
      '&' => MoveTypeReference(body),
      '&mut' => MoveTypeMutableReference(body),
      _ => body,
    };
  }

  static NormalizedMoveType _parseSignatureBody(dynamic body) {
    if (body is String) {
      return MoveTypePrimitive(body[0].toUpperCase() + body.substring(1));
    }
    if (body is Map) {
      if (body.containsKey('vector')) {
        return MoveTypeVector(_parseSignatureBody(body['vector']));
      }
      if (body['datatype'] case final Map datatype) {
        return MoveTypeStruct(
          address: normalizeSuiAddress(datatype['package']),
          module: datatype['module'],
          name: datatype['type'],
          typeArguments: [
            for (final arg in datatype['typeParameters'] ?? const [])
              _parseSignatureBody(arg),
          ],
        );
      }
      if (body.containsKey('typeParameter')) {
        return MoveTypeParameter(body['typeParameter']);
      }
    }
    return const MoveTypePrimitive('Unknown');
  }

  @override
  Future<String> getChainIdentifier() => _client.getChainIdentifier();
}
