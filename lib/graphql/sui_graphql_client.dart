import 'package:dio/dio.dart';

import '../sui_urls.dart';
import 'graphql_core_client.dart';
import 'graphql_operation.dart';
import 'graphql_transport.dart';
import 'operations.graphql.dart' as generated;
import 'schema.graphql.dart' as schema;

/// Client for Sui's indexer-backed GraphQL API.
class SuiGraphQLClient {
  static final _chainIdentifierOperation =
      GraphQLOperation<generated.Query$ChainIdentifier, GraphQLNoVariables>(
        document: generated.documentNodeQueryChainIdentifier,
        operationName: 'ChainIdentifier',
        decodeData: generated.Query$ChainIdentifier.fromJson,
        encodeVariables: (_) => const {},
      );
  static final _historyByAddressOperation =
      GraphQLOperation<
        generated.Query$TransactionHistoryByAddress,
        generated.Variables$Query$TransactionHistoryByAddress
      >(
        document: generated.documentNodeQueryTransactionHistoryByAddress,
        operationName: 'TransactionHistoryByAddress',
        decodeData: generated.Query$TransactionHistoryByAddress.fromJson,
        encodeVariables: (variables) => variables.toJson(),
      );
  static final _historyBySenderOperation =
      GraphQLOperation<
        generated.Query$TransactionHistoryBySender,
        generated.Variables$Query$TransactionHistoryBySender
      >(
        document: generated.documentNodeQueryTransactionHistoryBySender,
        operationName: 'TransactionHistoryBySender',
        decodeData: generated.Query$TransactionHistoryBySender.fromJson,
        encodeVariables: (variables) => variables.toJson(),
      );
  static final _transactionGasSummaryOperation =
      GraphQLOperation<
        generated.Query$TransactionGasSummary,
        generated.Variables$Query$TransactionGasSummary
      >(
        document: generated.documentNodeQueryTransactionGasSummary,
        operationName: 'TransactionGasSummary',
        decodeData: generated.Query$TransactionGasSummary.fromJson,
        encodeVariables: (variables) => variables.toJson(),
      );
  static final _transactionsByObjectOperation =
      GraphQLOperation<
        generated.Query$TransactionsByObject,
        generated.Variables$Query$TransactionsByObject
      >(
        document: generated.documentNodeQueryTransactionsByObject,
        operationName: 'TransactionsByObject',
        decodeData: generated.Query$TransactionsByObject.fromJson,
        encodeVariables: (variables) => variables.toJson(),
      );
  static final _epochSummaryOperation =
      GraphQLOperation<
        generated.Query$EpochSummary,
        generated.Variables$Query$EpochSummary
      >(
        document: generated.documentNodeQueryEpochSummary,
        operationName: 'EpochSummary',
        decodeData: generated.Query$EpochSummary.fromJson,
        encodeVariables: (variables) => variables.toJson(),
      );
  static final _activeValidatorsOperation =
      GraphQLOperation<
        generated.Query$ActiveValidators,
        generated.Variables$Query$ActiveValidators
      >(
        document: generated.documentNodeQueryActiveValidators,
        operationName: 'ActiveValidators',
        decodeData: generated.Query$ActiveValidators.fromJson,
        encodeVariables: (variables) => variables.toJson(),
      );
  static final _stakedSuiOperation =
      GraphQLOperation<
        generated.Query$StakedSui,
        generated.Variables$Query$StakedSui
      >(
        document: generated.documentNodeQueryStakedSui,
        operationName: 'StakedSui',
        decodeData: generated.Query$StakedSui.fromJson,
        encodeVariables: (variables) => variables.toJson(),
      );
  static final _eventsByModuleOperation =
      GraphQLOperation<
        generated.Query$EventsByModule,
        generated.Variables$Query$EventsByModule
      >(
        document: generated.documentNodeQueryEventsByModule,
        operationName: 'EventsByModule',
        decodeData: generated.Query$EventsByModule.fromJson,
        encodeVariables: (variables) => variables.toJson(),
      );

  SuiGraphQLClient({
    required String endpoint,
    Dio? dio,
    Map<String, String> headers = const {},
  }) : transport = GraphQLTransport(endpoint, dio: dio, headers: headers) {
    core = GraphQLCoreClient(this);
  }

  SuiGraphQLClient.forNetwork(
    SuiNetwork network, {
    Dio? dio,
    Map<String, String> headers = const {},
  }) : transport = GraphQLTransport(
         SuiUrls.graphql(network),
         dio: dio,
         headers: headers,
       ) {
    core = GraphQLCoreClient(this);
  }

  final GraphQLTransport transport;

  late final GraphQLCoreClient core;

  /// Executes a custom query and preserves partial data and structured errors.
  Future<GraphQLResponse> query(
    String document, {
    Map<String, dynamic>? variables,
    String? operationName,
    Map<String, dynamic>? extensions,
    CancelToken? cancelToken,
  }) => transport.request(
    document,
    variables: variables,
    operationName: operationName,
    extensions: extensions,
    cancelToken: cancelToken,
  );

  /// Executes a generated operation with typed variables and response data.
  Future<TypedGraphQLResponse<TData>> execute<TData, TVariables>(
    GraphQLOperation<TData, TVariables> operation,
    TVariables variables, {
    Map<String, dynamic>? extensions,
    CancelToken? cancelToken,
  }) async {
    final encodedVariables = operation.encodeVariables(variables);
    final response = await transport.request(
      operation.document,
      variables: encodedVariables.isEmpty ? null : encodedVariables,
      operationName: operation.operationName,
      extensions: extensions,
      cancelToken: cancelToken,
    );

    TData? data;
    if (response.data != null) {
      try {
        data = operation.decodeData(response.data!);
      } on Object catch (error) {
        throw GraphQLResponseDecodingException(operation.operationName, error);
      }
    }
    return TypedGraphQLResponse(
      data: data,
      errors: response.errors,
      extensions: response.extensions,
    );
  }

  /// Executes a generated operation, throwing on GraphQL errors or no data.
  Future<TData> executeData<TData, TVariables>(
    GraphQLOperation<TData, TVariables> operation,
    TVariables variables, {
    Map<String, dynamic>? extensions,
    CancelToken? cancelToken,
  }) async {
    final response = await execute(
      operation,
      variables,
      extensions: extensions,
      cancelToken: cancelToken,
    );
    if (response.errors.isNotEmpty) throw GraphQLException(response.errors);
    if (response.data == null) {
      throw GraphQLRequestException(
        'GraphQL response missing data for ${operation.operationName}',
      );
    }
    return response.data!;
  }

  Future<String> getChainIdentifier() async {
    final data = await executeData(
      _chainIdentifierOperation,
      const GraphQLNoVariables(),
    );
    return data.chainIdentifier;
  }

  /// Transactions that affected [address], including sent and received ones.
  Future<SenderTransactionPage> queryTransactionsByAddress(
    String address, {
    int first = 20,
    String? after,
    TransactionHistoryOptions options = const TransactionHistoryOptions(),
  }) async {
    _checkPageSize(first);
    final data = await executeData(
      _historyByAddressOperation,
      generated.Variables$Query$TransactionHistoryByAddress(
        address: address,
        first: first,
        before: after,
        showBalanceChanges: options.showBalanceChanges,
        showObjectChanges: options.showObjectChanges,
      ),
    );
    final transactions = _required(
      data.transactions,
      'TransactionHistoryByAddress.transactions',
    );
    return _parseTransactionsPage(
      transactions.nodes,
      hasNextPage: transactions.pageInfo.hasPreviousPage,
      endCursor: transactions.pageInfo.startCursor,
    );
  }

  /// Transactions signed by [sender].
  Future<SenderTransactionPage> queryTransactionsBySender(
    String sender, {
    int first = 20,
    String? after,
    TransactionHistoryOptions options = const TransactionHistoryOptions(),
  }) async {
    _checkPageSize(first);
    final data = await executeData(
      _historyBySenderOperation,
      generated.Variables$Query$TransactionHistoryBySender(
        sender: sender,
        first: first,
        before: after,
        showBalanceChanges: options.showBalanceChanges,
        showObjectChanges: options.showObjectChanges,
      ),
    );
    final transactions = _required(
      data.transactions,
      'TransactionHistoryBySender.transactions',
    );
    return _parseTransactionsPage(
      transactions.nodes,
      hasNextPage: transactions.pageInfo.hasPreviousPage,
      endCursor: transactions.pageInfo.startCursor,
    );
  }

  Future<TransactionGasSummary?> getTransactionGasSummary(String digest) async {
    final data = await executeData(
      _transactionGasSummaryOperation,
      generated.Variables$Query$TransactionGasSummary(digest: digest),
    );
    final summary = data.transaction?.effects?.gasEffects?.gasSummary;
    return summary == null
        ? null
        : TransactionGasSummary._fromValues(
            summary.computationCost,
            summary.storageCost,
            summary.storageRebate,
          );
  }

  SenderTransactionPage _parseTransactionsPage(
    List<generated.Fragment$TransactionHistoryFields> nodes, {
    required bool hasNextPage,
    String? endCursor,
  }) {
    return SenderTransactionPage(
      transactions: nodes.map(SenderTransaction._fromNode).toList(),
      hasNextPage: hasNextPage,
      endCursor: endCursor,
    );
  }

  /// Transaction digests involving [objectId].
  Future<TransactionDigestPage> queryTransactionsByObject(
    String objectId, {
    int first = 20,
    String? after,
  }) async {
    _checkPageSize(first);
    final data = await executeData(
      _transactionsByObjectOperation,
      generated.Variables$Query$TransactionsByObject(
        object: objectId,
        first: first,
        after: after,
      ),
    );
    final transactions = _required(
      data.transactions,
      'TransactionsByObject.transactions',
    );
    return TransactionDigestPage(
      digests: transactions.nodes.map((node) => node.digest).toList(),
      hasNextPage: transactions.pageInfo.hasNextPage,
      endCursor: transactions.pageInfo.endCursor,
    );
  }

  /// Summary of the current epoch, or [epochId] when provided.
  Future<EpochSummary> getEpochSummary({int? epochId}) async {
    final data = await executeData(
      _epochSummaryOperation,
      generated.Variables$Query$EpochSummary(epochId: epochId),
    );
    final epoch = _required(data.epoch, 'EpochSummary.epoch');
    return EpochSummary(
      epochId: epoch.epochId,
      referenceGasPrice: BigInt.parse(
        _required(
          epoch.referenceGasPrice,
          'EpochSummary.epoch.referenceGasPrice',
        ),
      ),
      totalTransactions: epoch.totalTransactions,
      startTimestamp: epoch.startTimestamp,
      endTimestamp: epoch.endTimestamp,
    );
  }

  /// One page of active validators for the current epoch.
  Future<ValidatorPage> getActiveValidatorsPage({
    int? epochId,
    int first = 50,
    String? after,
  }) async {
    _checkPageSize(first);
    final data = await executeData(
      _activeValidatorsOperation,
      generated.Variables$Query$ActiveValidators(
        epochId: epochId,
        first: first,
        after: after,
      ),
    );
    final connection = _required(
      data.epoch?.validatorSet?.activeValidators,
      'ActiveValidators.epoch.validatorSet.activeValidators',
    );
    return ValidatorPage(
      validators: connection.nodes
          .map(
            (node) => ValidatorInfo._fromJson(node.contents?.json ?? const {}),
          )
          .toList(),
      hasNextPage: connection.pageInfo.hasNextPage,
      endCursor: connection.pageInfo.endCursor,
    );
  }

  /// All active validators, paging from [after] with requests of [pageSize].
  Future<List<ValidatorInfo>> getActiveValidators({
    int? epochId,
    int pageSize = 50,
    String? after,
  }) async {
    _checkPageSize(pageSize, 'pageSize');
    final validators = <ValidatorInfo>[];
    var cursor = after;
    final seenCursors = <String?>{cursor};

    while (true) {
      final page = await getActiveValidatorsPage(
        epochId: epochId,
        first: pageSize,
        after: cursor,
      );
      validators.addAll(page.validators);
      if (!page.hasNextPage) break;
      final nextCursor = page.endCursor;
      if (nextCursor == null || !seenCursors.add(nextCursor)) {
        throw StateError('Invalid validator pagination cursor');
      }
      cursor = nextCursor;
    }
    return validators;
  }

  /// Staked SUI objects owned by [owner].
  Future<StakedSuiPage> getStakes(
    String owner, {
    int first = 50,
    String? after,
  }) async {
    _checkPageSize(first);
    final data = await executeData(
      _stakedSuiOperation,
      generated.Variables$Query$StakedSui(
        owner: owner,
        first: first,
        after: after,
      ),
    );
    if (data.address == null) {
      return const StakedSuiPage(stakes: [], hasNextPage: false);
    }
    final objects = _required(
      data.address!.objects,
      'StakedSui.address.objects',
    );
    return StakedSuiPage(
      stakes: objects.nodes.map(StakedSuiInfo._fromNode).toList(),
      hasNextPage: objects.pageInfo.hasNextPage,
      endCursor: objects.pageInfo.endCursor,
    );
  }

  /// Events emitted by [module] in [packageId].
  Future<SuiGraphQLEventPage> queryEventsByModule(
    String packageId,
    String module, {
    int first = 20,
    String? after,
  }) async {
    _checkPageSize(first);
    final data = await executeData(
      _eventsByModuleOperation,
      generated.Variables$Query$EventsByModule(
        module: '$packageId::$module',
        first: first,
        after: after,
      ),
    );
    final events = _required(data.events, 'EventsByModule.events');
    return SuiGraphQLEventPage(
      events: events.nodes.map(SuiGraphQLEvent._fromNode).toList(),
      hasNextPage: events.pageInfo.hasNextPage,
      endCursor: events.pageInfo.endCursor,
    );
  }
}

T _required<T>(T? value, String path) {
  if (value == null) {
    throw GraphQLRequestException('GraphQL response missing "$path"');
  }
  return value;
}

void _checkPageSize(int size, [String name = 'first']) {
  if (size < 1 || size > 50) throw RangeError.range(size, 1, 50, name);
}

class TransactionDigestPage {
  TransactionDigestPage({
    required this.digests,
    required this.hasNextPage,
    this.endCursor,
  });

  final List<String> digests;
  final bool hasNextPage;
  final String? endCursor;
}

class SenderTransactionPage {
  SenderTransactionPage({
    required this.transactions,
    required this.hasNextPage,
    this.endCursor,
  });

  final List<SenderTransaction> transactions;
  final bool hasNextPage;
  final String? endCursor;

  List<String> get digests => [
    for (final transaction in transactions) transaction.digest,
  ];
}

class ValidatorPage {
  const ValidatorPage({
    required this.validators,
    required this.hasNextPage,
    this.endCursor,
  });

  final List<ValidatorInfo> validators;
  final bool hasNextPage;
  final String? endCursor;
}

class TransactionHistoryOptions {
  const TransactionHistoryOptions({
    this.showBalanceChanges = true,
    this.showObjectChanges = false,
  });

  final bool showBalanceChanges;
  final bool showObjectChanges;
}

class SenderTransaction {
  SenderTransaction({
    required this.digest,
    required this.timestampMs,
    required this.success,
    required this.balanceChanges,
    this.senderAddress,
    this.isProgrammableTransaction = false,
    this.commandTypes = const [],
    this.commandTypesTruncated = false,
    this.gasSummary,
    this.objectChanges = const [],
    this.balanceChangesTruncated = false,
    this.objectChangesTruncated = false,
  });

  final String digest;
  final int? timestampMs;
  final bool success;
  final String? senderAddress;
  final bool isProgrammableTransaction;
  final List<String> commandTypes;
  final bool commandTypesTruncated;
  final TransactionGasSummary? gasSummary;
  final List<TxBalanceChange> balanceChanges;
  final List<TxObjectChange> objectChanges;
  final bool balanceChangesTruncated;
  final bool objectChangesTruncated;

  factory SenderTransaction._fromNode(
    generated.Fragment$TransactionHistoryFields node,
  ) {
    final effects = node.effects;
    final timestamp = effects?.timestamp;
    final kind = node.kind;
    final programmable =
        kind
            is generated.Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction
        ? kind
        : null;
    final gas = effects?.gasEffects?.gasSummary;
    final balances = effects?.balanceChanges?.nodes ?? const [];
    final objects = effects?.objectChanges?.nodes ?? const [];
    return SenderTransaction(
      digest: node.digest,
      timestampMs: timestamp == null
          ? null
          : DateTime.tryParse(timestamp)?.millisecondsSinceEpoch,
      success: effects?.status == schema.Enum$ExecutionStatus.SUCCESS,
      senderAddress: node.sender?.address,
      isProgrammableTransaction: programmable != null,
      commandTypes: [
        for (final command in programmable?.commands?.nodes ?? const [])
          command.$__typename,
      ],
      commandTypesTruncated:
          programmable?.commands?.pageInfo.hasNextPage ?? false,
      gasSummary: gas == null
          ? null
          : TransactionGasSummary._fromValues(
              gas.computationCost,
              gas.storageCost,
              gas.storageRebate,
            ),
      balanceChanges: [
        for (final balance in balances)
          TxBalanceChange(
            ownerAddress: balance.owner?.address,
            amount: balance.amount ?? '0',
            coinType: balance.coinType?.repr ?? '',
          ),
      ],
      objectChanges: [
        for (final object in objects) TxObjectChange._fromNode(object),
      ],
      balanceChangesTruncated:
          effects?.balanceChanges?.pageInfo.hasNextPage ?? false,
      objectChangesTruncated:
          effects?.objectChanges?.pageInfo.hasNextPage ?? false,
    );
  }
}

class TransactionGasSummary {
  TransactionGasSummary({
    required this.computationCost,
    required this.storageCost,
    required this.storageRebate,
  });

  factory TransactionGasSummary._fromValues(
    int? computationCost,
    int? storageCost,
    int? storageRebate,
  ) => TransactionGasSummary(
    computationCost: BigInt.from(computationCost ?? 0),
    storageCost: BigInt.from(storageCost ?? 0),
    storageRebate: BigInt.from(storageRebate ?? 0),
  );

  final BigInt computationCost;
  final BigInt storageCost;
  final BigInt storageRebate;

  BigInt get netCost {
    final value = computationCost + storageCost - storageRebate;
    return value.isNegative ? BigInt.zero : value;
  }
}

class StakedSuiPage {
  const StakedSuiPage({
    required this.stakes,
    required this.hasNextPage,
    this.endCursor,
  });

  final List<StakedSuiInfo> stakes;
  final bool hasNextPage;
  final String? endCursor;
}

class SuiGraphQLEventPage {
  const SuiGraphQLEventPage({
    required this.events,
    required this.hasNextPage,
    this.endCursor,
  });

  final List<SuiGraphQLEvent> events;
  final bool hasNextPage;
  final String? endCursor;
}

class SuiGraphQLEvent {
  const SuiGraphQLEvent({
    required this.module,
    required this.sender,
    required this.type,
    required this.json,
  });

  final String? module;
  final String? sender;
  final String? type;
  final Map<String, dynamic>? json;

  factory SuiGraphQLEvent._fromNode(
    generated.Query$EventsByModule$events$nodes node,
  ) {
    return SuiGraphQLEvent(
      module: node.transactionModule?.name,
      sender: node.sender?.address,
      type: node.contents?.type?.repr,
      json: node.contents?.json,
    );
  }
}

class TxBalanceChange {
  TxBalanceChange({
    required this.ownerAddress,
    required this.amount,
    required this.coinType,
  });

  final String? ownerAddress;
  final String amount;
  final String coinType;
}

class TxObjectChange {
  TxObjectChange({
    required this.objectId,
    required this.type,
    required this.kind,
    this.fromAddress,
    this.toAddress,
  });

  final String objectId;
  final String type;
  final String kind;
  final String? fromAddress;
  final String? toAddress;

  factory TxObjectChange._fromNode(
    generated.Fragment$TransactionHistoryFields$effects$objectChanges$nodes
    object,
  ) {
    final inputOwner = object.inputState?.owner;
    final outputState = object.outputState;
    final outputOwner = outputState?.owner;
    return TxObjectChange(
      objectId: object.address,
      type: outputState?.asMoveObject?.contents?.type?.repr ?? '',
      kind: object.idCreated == true
          ? 'created'
          : object.idDeleted == true
          ? 'deleted'
          : 'mutated',
      fromAddress:
          inputOwner
              is generated.Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner
          ? inputOwner.address?.address
          : null,
      toAddress:
          outputOwner
              is generated.Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner
          ? outputOwner.address?.address
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'objectId': objectId,
    'type': type,
    'kind': kind,
    'from': fromAddress,
    'to': toAddress,
  };
}

class ValidatorInfo {
  ValidatorInfo({
    required this.name,
    required this.suiAddress,
    required this.votingPower,
    required this.commissionRate,
    required this.nextEpochStake,
    required this.stakingPoolSuiBalance,
    required this.poolTokenBalance,
    required this.stakingPoolId,
    required this.activationEpoch,
    this.imageUrl,
    this.projectUrl,
    this.description,
  });

  final String? name;
  final String? suiAddress;
  final String? imageUrl;
  final String? projectUrl;
  final String? description;
  final int votingPower;
  final int commissionRate;
  final BigInt nextEpochStake;
  final BigInt stakingPoolSuiBalance;
  final BigInt poolTokenBalance;
  final String? stakingPoolId;
  final int activationEpoch;

  static BigInt _bigInt(dynamic value) =>
      value == null ? BigInt.zero : BigInt.parse(value.toString());

  factory ValidatorInfo._fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map? ?? const {};
    final stakingPool = json['staking_pool'] as Map? ?? const {};
    return ValidatorInfo(
      name: metadata['name'] as String?,
      suiAddress: metadata['sui_address'] as String?,
      imageUrl: metadata['image_url'] as String?,
      projectUrl: metadata['project_url'] as String?,
      description: metadata['description'] as String?,
      votingPower: int.tryParse('${json['voting_power']}') ?? 0,
      commissionRate: int.tryParse('${json['commission_rate']}') ?? 0,
      nextEpochStake: _bigInt(json['next_epoch_stake']),
      stakingPoolSuiBalance: _bigInt(stakingPool['sui_balance']),
      poolTokenBalance: _bigInt(stakingPool['pool_token_balance']),
      stakingPoolId: stakingPool['id']?.toString(),
      activationEpoch: int.tryParse('${stakingPool['activation_epoch']}') ?? 0,
    );
  }
}

class StakedSuiInfo {
  StakedSuiInfo({
    required this.stakedSuiId,
    required this.poolId,
    required this.principal,
    required this.stakeActivationEpoch,
  });

  final String stakedSuiId;
  final String? poolId;
  final BigInt principal;
  final int? stakeActivationEpoch;

  factory StakedSuiInfo._fromNode(
    generated.Query$StakedSui$address$objects$nodes node,
  ) {
    final json = node.contents?.json ?? const {};
    final rawPrincipal = json['principal'];
    return StakedSuiInfo(
      stakedSuiId: node.address,
      poolId: json['pool_id'] as String?,
      principal: rawPrincipal is Map
          ? BigInt.parse('${rawPrincipal['value'] ?? 0}')
          : BigInt.parse('${rawPrincipal ?? 0}'),
      stakeActivationEpoch: json['stake_activation_epoch'] == null
          ? null
          : int.tryParse('${json['stake_activation_epoch']}'),
    );
  }
}

class EpochSummary {
  EpochSummary({
    required this.epochId,
    required this.referenceGasPrice,
    required this.totalTransactions,
    required this.startTimestamp,
    required this.endTimestamp,
  });

  final int epochId;
  final BigInt referenceGasPrice;
  final int? totalTransactions;
  final String? startTimestamp;
  final String? endTimestamp;
}
