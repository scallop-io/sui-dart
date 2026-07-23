import 'dart:convert';
import 'dart:typed_data';

import 'package:sui_dart/builder/transaction.dart' show Transaction;
import 'package:sui_dart/core/sui_core_client.dart';
import 'package:sui_dart/grpc/types.dart';
import 'package:sui_dart/types/common.dart' show normalizeStructTagString;

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
typedef _DfNode = generated.Query$GetDynamicFields$object$dynamicFields$nodes;
typedef _DfMoveObjectValue =
    generated.Query$GetDynamicFields$object$dynamicFields$nodes$value$$MoveObject;
typedef _DfMoveValue =
    generated.Query$GetDynamicFields$object$dynamicFields$nodes$value$$MoveValue;
typedef _SimEventNode =
    generated.Query$SimulateTransaction$simulateTransaction$effects$events$nodes;
typedef _SimCommand =
    generated.Query$SimulateTransaction$simulateTransaction$outputs;

/// GraphQL-backed [SuiCoreClient]. [executeTransaction] and
/// [verifyZkLoginSignature] throw `UnsupportedError`; use the gRPC transport
/// for those.
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
      type: contents?.type?.repr ?? '',
      json: contents?.json,
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

  static Event _mapSimEvent(_SimEventNode node) {
    final contents = node.contents;
    final eventType = contents?.type?.repr ?? '';
    final parts = eventType.split('::');
    return Event(
      packageId: parts.isNotEmpty ? parts.first : '',
      module:
          node.transactionModule?.name ?? (parts.length > 1 ? parts[1] : ''),
      sender: node.sender?.address ?? '',
      eventType: eventType,
      bcs: _decodeBcs(contents?.bcs),
      json: contents?.json,
    );
  }

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
  Future<List<ObjectResult>> getObjects(
    List<String> objectIds, {
    ObjectIncludeOptions? include,
  }) async {
    if (objectIds.isEmpty) return const [];
    final data = await _client.executeData(
      _multiGetObjectsOperation,
      generated.Variables$Query$MultiGetObjects(
        keys: objectIds
            .map((id) => schema.Input$ObjectKey(address: id))
            .toList(),
      ),
    );
    return data.multiGetObjects
        .map<ObjectResult>(
          (obj) => obj == null
              ? const ObjectError('Object not found')
              : ObjectSuccess(_mapObject(obj)),
        )
        .toList();
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
      generated.Variables$Query$GetTransaction(digest: digest),
    );
    final tx = data.transaction;
    if (tx == null) throw Exception('Transaction not found: $digest');
    final effects = tx.effects;
    final timestamp = effects?.timestamp;
    return TransactionResponse(
      digest: tx.digest,
      status: ExecutionStatus(
        success: effects?.status == schema.Enum$ExecutionStatus.SUCCESS,
      ),
      timestampMs: timestamp == null
          ? null
          : DateTime.tryParse(timestamp)?.millisecondsSinceEpoch.toString(),
    );
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
    final txJson =
        transactionBlock.toGrpcTransaction().toProto3Json()
            as Map<String, dynamic>;
    final data = await _client.executeData(
      _simulateTransactionOperation,
      generated.Variables$Query$SimulateTransaction(
        tx: txJson,
        checksEnabled: checksEnabled,
        doGasSelection: doGasSelection,
      ),
    );
    final result = data.simulateTransaction;
    final effects = result.effects;
    return TransactionResponse(
      digest: '',
      status: ExecutionStatus(
        success: effects?.status == schema.Enum$ExecutionStatus.SUCCESS,
      ),
      events: effects?.events?.nodes.map(_mapSimEvent).toList(),
      commandResults: result.outputs?.map(_mapSimCommand).toList(),
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
  Future<Page<DynamicFieldEntry>> getDynamicFields(
    String parentId, {
    String? cursor,
    int? limit,
  }) async {
    final data = await _client.executeData(
      _getDynamicFieldsOperation,
      generated.Variables$Query$GetDynamicFields(
        parentId: parentId,
        first: limit,
        after: cursor,
      ),
    );
    final connection = data.object?.dynamicFields;
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
      parameters: const [],
      returnTypes: const [],
    );
  }

  @override
  Future<String> getChainIdentifier() => _client.getChainIdentifier();
}
