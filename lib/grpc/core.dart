import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart';

import 'package:sui_dart/grpc/generated/sui/rpc/v2/bcs.pb.dart' as grpc_bcs;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/effects.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/execution_status.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/executed_transaction.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/ledger_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/move_package.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/move_package_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/name_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/object.pb.dart' as grpc_object;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/owner.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/signature.pb.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/signature_verification_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/state_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction_execution_service.pbgrpc.dart';

import 'package:sui_dart/builder/transaction.dart' show chunk;
import 'package:sui_dart/sui.dart' as sui_dart;
import 'package:sui_dart/types/common.dart';

import 'client.dart';

// ignore: constant_identifier_names
const _MAX_OBJECTS_PER_BATCH = 50;

class GrpcCoreClient {
  final SuiGrpcClient _client;

  GrpcCoreClient(this._client);

  Future<List<GrpcObjectResult>> getObjects(
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

    return results.map((result) {
      if (result.whichResult() == GetObjectResult_Result.error) {
        return GrpcObjectError(result.error.message);
      }
      return GrpcObjectSuccess(_parseObject(result.object, include));
    }).toList();
  }

  Future<GrpcPage<GrpcObjectData>> listOwnedObjects(
    String owner, {
    String? objectType,
    String? cursor,
    int? limit,
    ObjectIncludeOptions? include,
  }) async {
    final readMask = _objectReadMask(include);

    final response = await _client.stateService.listOwnedObjects(
      ListOwnedObjectsRequest(
        owner: owner,
        objectType: objectType,
        pageSize: limit,
        pageToken: cursor != null ? base64Decode(cursor) : null,
        readMask: readMask,
      ),
    );

    final hasNext = response.hasNextPageToken() && response.nextPageToken.isNotEmpty;
    return GrpcPage(
      data: response.objects.map((obj) => _parseObject(obj, include)).toList(),
      hasNextPage: hasNext,
      nextCursor: hasNext ? base64Encode(response.nextPageToken) : null,
    );
  }

  Future<GrpcPage<GrpcCoinData>> listCoins(
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
            'previous_transaction',
            'balance',
          ],
        ),
      ),
    );

    final hasNext = response.hasNextPageToken() && response.nextPageToken.isNotEmpty;
    return GrpcPage(
      data: response.objects.map((obj) {
        return GrpcCoinData(
          coinType: normalizedCoinType,
          coinObjectId: obj.objectId,
          version: obj.version.toString(),
          digest: obj.digest,
          balance: obj.balance.toString(),
          previousTransaction: obj.previousTransaction,
        );
      }).toList(),
      hasNextPage: hasNext,
      nextCursor: hasNext ? base64Encode(response.nextPageToken) : null,
    );
  }

  Future<GrpcBalance> getBalance(String owner, {String coinType = '0x2::sui::SUI'}) async {
    final normalizedCoinType = normalizeStructTagString(coinType);

    final response = await _client.stateService.getBalance(
      GetBalanceRequest(owner: owner, coinType: normalizedCoinType),
    );

    final balance = response.balance;
    return GrpcBalance(
      coinType: balance.coinType,
      totalBalance: balance.balance.toString(),
    );
  }

  Future<GrpcCoinMetadata?> getCoinMetadata(String coinType) async {
    final normalizedCoinType = normalizeStructTagString(coinType);

    final response = await _client.stateService.getCoinInfo(
      GetCoinInfoRequest(coinType: normalizedCoinType),
    );

    if (!response.hasMetadata()) return null;

    final metadata = response.metadata;
    return GrpcCoinMetadata(
      id: metadata.id,
      decimals: metadata.decimals,
      name: metadata.name,
      symbol: metadata.symbol,
      description: metadata.description,
      iconUrl: metadata.iconUrl.isNotEmpty ? metadata.iconUrl : null,
    );
  }

  Future<List<GrpcBalance>> listBalances(String owner) async {
    final allBalances = <Balance>[];
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
      return GrpcBalance(
        coinType: balance.coinType,
        totalBalance: balance.balance.toString(),
      );
    }).toList();
  }

  Future<GrpcTransactionResponse> getTransaction(
    String digest, {
    TransactionIncludeOptions? include,
  }) async {
    final readMask = _transactionReadMask(include);

    final response = await _client.ledgerService.getTransaction(
      GetTransactionRequest(digest: digest, readMask: readMask),
    );

    return _parseTransaction(response.transaction, include);
  }

  Future<GrpcTransactionResponse> executeTransaction(
    Uint8List transactionBytes,
    List<String> signatures, {
    TransactionIncludeOptions? include,
  }) async {
    final readMask = _transactionReadMask(include);
    

    final response = await _client.transactionExecutionService.executeTransaction(
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

  Future<GrpcTransactionResponse> simulateTransaction(
    sui_dart.Transaction transactionBlock, {
    TransactionIncludeOptions? include,
    bool? doGasSelection,
  }) async {
    final readMask = _transactionReadMask(include);

    final response = await _client.transactionExecutionService.simulateTransaction(
      SimulateTransactionRequest(
        transaction: transactionBlock.toGrpcTransaction(),
        readMask: readMask,
        doGasSelection: doGasSelection ?? true,
      ),
    );

    var result = _parseTransaction(response.transaction, include);

    if (include?.commandOutputs == true) {
      result = result.copyWith(
        commandOutputs: response.commandOutputs.map((cmdResult) {
          return GrpcCommandOutput(
            returnValues: cmdResult.returnValues.map((output) {
              return GrpcCommandOutputValue(
                value: output.hasValue() ? base64Encode(output.value.value) : null,
                json: output.hasJson() ? output.json.writeToJsonMap() : null,
              );
            }).toList(),
            mutatedByRef: cmdResult.mutatedByRef.map((output) {
              return GrpcCommandOutputValue(
                value: output.hasValue() ? base64Encode(output.value.value) : null,
                json: output.hasJson() ? output.json.writeToJsonMap() : null,
              );
            }).toList(),
          );
        }).toList(),
      );
    }

    return result;
  }

  Future<String> getReferenceGasPrice() async {
    final response = await _client.ledgerService.getEpoch(
      GetEpochRequest(readMask: FieldMask(paths: ['reference_gas_price'])),
    );

    return response.epoch.referenceGasPrice.toString();
  }

  Future<GrpcSystemState> getCurrentSystemState() async {
    final response = await _client.ledgerService.getEpoch(
      GetEpochRequest(
        readMask: FieldMask(
          paths: ['epoch', 'reference_gas_price', 'system_state', 'start', 'end'],
        ),
      ),
    );

    final epoch = response.epoch;
    return GrpcSystemState(
      epoch: epoch.epoch.toString(),
      referenceGasPrice: epoch.referenceGasPrice.toString(),
      systemState: epoch.hasSystemState() ? epoch.systemState.writeToJsonMap() : null,
      epochStartTimestampMs: epoch.hasStart() ? epoch.start.seconds.toString() : null,
    );
  }

  Future<GrpcPage<GrpcDynamicFieldEntry>> listDynamicFields(
    String parentId, {
    String? cursor,
    int? limit,
  }) async {
    final response = await _client.stateService.listDynamicFields(
      ListDynamicFieldsRequest(
        parent: parentId,
        pageSize: limit,
        pageToken: cursor != null ? base64Decode(cursor) : null,
        readMask: FieldMask(paths: ['kind', 'field_id', 'name', 'value_type', 'child_id']),
      ),
    );

    final hasNext = response.hasNextPageToken() && response.nextPageToken.isNotEmpty;
    return GrpcPage(
      data: response.dynamicFields.map((field) {
        return GrpcDynamicFieldEntry(
          name: GrpcDynamicFieldName(
            type: field.hasName() ? field.name.name : null,
            value: field.hasName() ? base64Encode(field.name.value) : null,
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

  Future<GrpcVerifySignatureResult> verifyZkLoginSignature(
    Uint8List bytes,
    String signature, {
    String? address,
  }) async {
    final response = await _client.signatureVerificationService.verifySignature(
      VerifySignatureRequest(
        message: grpc_bcs.Bcs(name: 'TransactionData', value: bytes),
        signature: UserSignature(bcs: grpc_bcs.Bcs(value: base64Decode(signature))),
        address: address,
      ),
    );

    return GrpcVerifySignatureResult(
      isValid: response.isValid,
      reason: response.hasReason() ? response.reason : null,
    );
  }

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

  Future<GrpcMoveFunction> getMoveFunction(
    String packageId,
    String moduleName,
    String functionName,
  ) async {
    final response = await _client.movePackageService.getFunction(
      GetFunctionRequest(packageId: packageId, moduleName: moduleName, name: functionName),
    );

    final func = response.function;
    return GrpcMoveFunction(
      name: func.name,
      visibility: _mapVisibility(func.visibility),
      isEntry: func.isEntry,
      typeParameters: func.typeParameters.map((tp) {
        return GrpcTypeParameter(abilities: tp.constraints.map(_mapAbility).toList());
      }).toList(),
      parameters: func.parameters.map(_parseNormalizedMoveType).toList(),
      returnTypes: func.returns.map(_parseNormalizedMoveType).toList(),
    );
  }

  Future<String> getChainIdentifier() async {
    final response = await _client.ledgerService.getServiceInfo(GetServiceInfoRequest());
    return response.chainId;
  }

  

  FieldMask _objectReadMask(ObjectIncludeOptions? include) {
    final paths = <String>['object_id', 'version', 'digest', 'object_type'];

    if (include?.owner == true) paths.add('owner');
    if (include?.previousTransaction == true) paths.add('previous_transaction');
    if (include?.content == true) {
      paths.add('contents');
      paths.add('json');
    }
    if (include?.bcs == true) paths.add('bcs');
    if (include?.storageRebate == true) paths.add('storage_rebate');

    return FieldMask(paths: paths);
  }

  FieldMask _transactionReadMask(TransactionIncludeOptions? include) {
    final paths = <String>['digest'];

    if (include?.rawTransaction == true) paths.add('transaction');
    if (include?.effects == true) paths.add('effects');
    if (include?.events == true) paths.add('events');
    if (include?.balanceChanges == true) paths.add('balance_changes');
    if (include?.rawEffects == true) paths.add('effects.bcs');
    if (include?.objectChanges == true) {
      paths.add('effects.changed_objects');
      paths.add('effects.unchanged_consensus_objects');
    }
    if (include?.checkpoint == true) paths.add('checkpoint');
    if (include?.timestampMs == true) paths.add('timestamp');

    return FieldMask(paths: paths);
  }

  GrpcObjectData _parseObject(grpc_object.Object obj, ObjectIncludeOptions? include) {
    return GrpcObjectData(
      objectId: obj.objectId,
      version: obj.version.toString(),
      digest: obj.digest,
      type: obj.objectType,
      owner: (include?.owner == true && obj.hasOwner()) ? _mapOwner(obj.owner) : null,
      previousTransaction:
          include?.previousTransaction == true ? obj.previousTransaction : null,
      content: (include?.content == true && obj.hasJson())
          ? obj.json.writeToJsonMap()
          : null,
      contentBcs: (include?.content == true && obj.hasContents())
          ? base64Encode(obj.contents.value)
          : null,
      bcs: (include?.bcs == true && obj.hasBcs()) ? base64Encode(obj.bcs.value) : null,
      storageRebate: include?.storageRebate == true ? obj.storageRebate.toString() : null,
    );
  }

  GrpcTransactionResponse _parseTransaction(
    ExecutedTransaction tx,
    TransactionIncludeOptions? include,
  ) {
    return GrpcTransactionResponse(
      digest: tx.digest,
      rawTransaction: (include?.rawTransaction == true && tx.hasTransaction())
          ? base64Encode(tx.transaction.writeToBuffer())
          : null,
      effects: (include?.effects == true && tx.hasEffects())
          ? _parseTransactionEffects(tx.effects)
          : null,
      rawEffects: (include?.rawEffects == true && tx.hasEffects() && tx.effects.hasBcs())
          ? base64Encode(tx.effects.bcs.value)
          : null,
      events: (include?.events == true && tx.hasEvents())
          ? tx.events.events.map((event) {
              return GrpcEvent(
                packageId: event.packageId,
                transactionModule: event.module,
                sender: event.sender,
                type: event.eventType,
                parsedJson: event.hasJson() ? event.json.writeToJsonMap() : null,
                bcs: event.hasContents() ? base64Encode(event.contents.value) : null,
              );
            }).toList()
          : null,
      balanceChanges: include?.balanceChanges == true
          ? tx.balanceChanges.map((change) {
              return GrpcBalanceChange(
                owner: change.address,
                coinType: change.coinType,
                amount: change.amount,
              );
            }).toList()
          : null,
      objectChanges: (include?.objectChanges == true && tx.hasEffects())
          ? tx.effects.changedObjects.map((obj) {
              return GrpcObjectChange(
                objectId: obj.objectId,
                idOperation: _mapIdOperation(obj.idOperation),
                inputState: _mapInputObjectState(obj.inputState),
                outputState: _mapOutputObjectState(obj.outputState),
                version: obj.hasOutputVersion() ? obj.outputVersion.toString() : null,
                digest: obj.hasOutputDigest() ? obj.outputDigest : null,
                owner: obj.hasOutputOwner() ? _mapOwner(obj.outputOwner) : null,
                objectType: obj.objectType.isNotEmpty ? obj.objectType : null,
              );
            }).toList()
          : null,
      checkpoint: (include?.checkpoint == true && tx.hasCheckpoint())
          ? tx.checkpoint.toString()
          : null,
      timestampMs: (include?.timestampMs == true && tx.hasTimestamp())
          ? (tx.timestamp.seconds * Int64(1000)).toString()
          : null,
    );
  }

  GrpcTransactionEffects _parseTransactionEffects(TransactionEffects effects) {
    return GrpcTransactionEffects(
      digest: effects.hasDigest() ? effects.digest : null,
      transactionDigest: effects.hasTransactionDigest() ? effects.transactionDigest : null,
      epoch: effects.hasEpoch() ? effects.epoch.toString() : null,
      lamportVersion: effects.hasLamportVersion() ? effects.lamportVersion.toString() : null,
      status: effects.hasStatus()
          ? GrpcExecutionStatus(
              success: effects.status.success,
              error: effects.status.hasError()
                  ? _parseExecutionError(effects.status.error)
                  : null,
            )
          : null,
      gasUsed: effects.hasGasUsed()
          ? GrpcGasUsed(
              computationCost: effects.gasUsed.computationCost.toString(),
              storageCost: effects.gasUsed.storageCost.toString(),
              storageRebate: effects.gasUsed.storageRebate.toString(),
              nonRefundableStorageFee: effects.gasUsed.nonRefundableStorageFee.toString(),
            )
          : null,
      gasObject: effects.hasGasObject()
          ? GrpcGasObject(
              objectId: effects.gasObject.objectId,
              inputState: _mapInputObjectState(effects.gasObject.inputState),
              outputState: _mapOutputObjectState(effects.gasObject.outputState),
            )
          : null,
      dependencies:
          effects.dependencies.isNotEmpty ? effects.dependencies.toList() : null,
      changedObjects: effects.changedObjects.isNotEmpty
          ? effects.changedObjects.map((obj) {
              return GrpcChangedObject(
                objectId: obj.objectId,
                idOperation: _mapIdOperation(obj.idOperation),
                inputState: _mapInputObjectState(obj.inputState),
                outputState: _mapOutputObjectState(obj.outputState),
                inputVersion: obj.hasInputVersion() ? obj.inputVersion.toString() : null,
                inputDigest: obj.hasInputDigest() ? obj.inputDigest : null,
                inputOwner: obj.hasInputOwner() ? _mapOwner(obj.inputOwner) : null,
                outputVersion: obj.hasOutputVersion() ? obj.outputVersion.toString() : null,
                outputDigest: obj.hasOutputDigest() ? obj.outputDigest : null,
                outputOwner: obj.hasOutputOwner() ? _mapOwner(obj.outputOwner) : null,
                objectType: obj.objectType.isNotEmpty ? obj.objectType : null,
              );
            }).toList()
          : null,
      unchangedConsensusObjects: effects.unchangedConsensusObjects.isNotEmpty
          ? effects.unchangedConsensusObjects.map((obj) {
              return GrpcUnchangedConsensusObject(
                kind: _mapUnchangedConsensusObjectKind(obj.kind),
                objectId: obj.objectId,
                version: obj.version.toString(),
                digest: obj.digest.isNotEmpty ? obj.digest : null,
                objectType: obj.objectType.isNotEmpty ? obj.objectType : null,
              );
            }).toList()
          : null,
      eventsDigest: effects.hasEventsDigest() ? effects.eventsDigest : null,
      bcs: effects.hasBcs() ? base64Encode(effects.bcs.value) : null,
    );
  }

  GrpcExecutionError _parseExecutionError(ExecutionError error) {
    GrpcExecutionErrorDetail? detail;

    switch (error.whichErrorDetails()) {
      case ExecutionError_ErrorDetails.abort:
        detail = GrpcAbortDetail(_parseMoveAbort(error.abort));
        break;
      case ExecutionError_ErrorDetails.sizeError:
        detail = GrpcSizeErrorDetail(
          size: error.sizeError.size.toString(),
          maxSize: error.sizeError.maxSize.toString(),
        );
        break;
      case ExecutionError_ErrorDetails.commandArgumentError:
        detail = GrpcCommandArgumentErrorDetail(
          argument: error.commandArgumentError.argument,
          kind: _mapErrorName(error.commandArgumentError.kind),
        );
        break;
      case ExecutionError_ErrorDetails.typeArgumentError:
        detail = GrpcTypeArgumentErrorDetail(
          typeArgument: error.typeArgumentError.typeArgument,
          kind: _mapErrorName(error.typeArgumentError.kind),
        );
        break;
      case ExecutionError_ErrorDetails.packageUpgradeError:
        detail = GrpcPackageUpgradeErrorDetail(
          kind: _mapErrorName(error.packageUpgradeError.kind),
          packageId: error.packageUpgradeError.packageId,
        );
        break;
      case ExecutionError_ErrorDetails.indexError:
        detail = GrpcIndexErrorDetail(
          index: error.indexError.index,
          subresult: error.indexError.subresult,
        );
        break;
      case ExecutionError_ErrorDetails.objectId:
        detail = GrpcObjectIdErrorDetail(error.objectId);
        break;
      case ExecutionError_ErrorDetails.coinDenyListError:
        detail = GrpcCoinDenyListErrorDetail(
          address: error.coinDenyListError.address,
          coinType: error.coinDenyListError.coinType,
        );
        break;
      case ExecutionError_ErrorDetails.congestedObjects:
        detail = GrpcCongestedObjectsDetail(error.congestedObjects.objects.toList());
        break;
      case ExecutionError_ErrorDetails.notSet:
        break;
    }

    return GrpcExecutionError(
      description: error.description,
      kind: _mapErrorName(error.kind),
      command: error.hasCommand() ? error.command.toString() : null,
      detail: detail,
    );
  }

  GrpcMoveAbort _parseMoveAbort(MoveAbort abort) {
    String? cleverError;
    String? cleverErrorRaw;

    if (abort.hasCleverError()) {
      final ce = abort.cleverError;
      if (ce.whichValue() == CleverError_Value.rendered) {
        cleverError = ce.rendered;
      } else if (ce.whichValue() == CleverError_Value.raw) {
        cleverErrorRaw = base64Encode(ce.raw);
      }
    }

    return GrpcMoveAbort(
      abortCode: abort.abortCode.toString(),
      location: abort.hasLocation()
          ? GrpcMoveAbortLocation(
              package: abort.location.package,
              module: abort.location.module,
              function: abort.location.function,
              instruction: abort.location.instruction,
              functionName:
                  abort.location.hasFunctionName() ? abort.location.functionName : null,
            )
          : null,
      cleverError: cleverError,
      cleverErrorRaw: cleverErrorRaw,
    );
  }

  

  static GrpcOwner? _mapOwner(Owner owner) {
    switch (owner.kind) {
      case Owner_OwnerKind.ADDRESS:
        return GrpcAddressOwner(owner.address);
      case Owner_OwnerKind.OBJECT:
        return GrpcObjectOwner(owner.address);
      case Owner_OwnerKind.SHARED:
        return GrpcSharedOwner(owner.version.toString());
      case Owner_OwnerKind.IMMUTABLE:
        return const GrpcImmutableOwner();
      case Owner_OwnerKind.CONSENSUS_ADDRESS:
        return GrpcConsensusAddressOwner(
          address: owner.address,
          startVersion: owner.version.toString(),
        );
      default:
        return null;
    }
  }

  static String _mapErrorName(ProtobufEnum? value) {
    if (value == null) return 'UNKNOWN';
    return value.name;
  }

  static String? _mapIdOperation(ChangedObject_IdOperation operation) {
    switch (operation) {
      case ChangedObject_IdOperation.NONE:
        return 'None';
      case ChangedObject_IdOperation.CREATED:
        return 'Created';
      case ChangedObject_IdOperation.DELETED:
        return 'Deleted';
      default:
        return null;
    }
  }

  static String? _mapInputObjectState(ChangedObject_InputObjectState state) {
    switch (state) {
      case ChangedObject_InputObjectState.INPUT_OBJECT_STATE_DOES_NOT_EXIST:
        return 'DoesNotExist';
      case ChangedObject_InputObjectState.INPUT_OBJECT_STATE_EXISTS:
        return 'Exists';
      default:
        return null;
    }
  }

  static String? _mapOutputObjectState(ChangedObject_OutputObjectState state) {
    switch (state) {
      case ChangedObject_OutputObjectState.OUTPUT_OBJECT_STATE_DOES_NOT_EXIST:
        return 'DoesNotExist';
      case ChangedObject_OutputObjectState.OUTPUT_OBJECT_STATE_OBJECT_WRITE:
        return 'ObjectWrite';
      case ChangedObject_OutputObjectState.OUTPUT_OBJECT_STATE_PACKAGE_WRITE:
        return 'PackageWrite';
      case ChangedObject_OutputObjectState.OUTPUT_OBJECT_STATE_ACCUMULATOR_WRITE:
        return 'AccumulatorWrite';
      default:
        return null;
    }
  }

  static String? _mapUnchangedConsensusObjectKind(
    UnchangedConsensusObject_UnchangedConsensusObjectKind kind,
  ) {
    switch (kind) {
      case UnchangedConsensusObject_UnchangedConsensusObjectKind.READ_ONLY_ROOT:
        return 'ReadOnlyRoot';
      case UnchangedConsensusObject_UnchangedConsensusObjectKind.MUTATE_CONSENSUS_STREAM_ENDED:
        return 'MutateConsensusStreamEnded';
      case UnchangedConsensusObject_UnchangedConsensusObjectKind.READ_CONSENSUS_STREAM_ENDED:
        return 'ReadConsensusStreamEnded';
      case UnchangedConsensusObject_UnchangedConsensusObjectKind.CANCELED:
        return 'Canceled';
      case UnchangedConsensusObject_UnchangedConsensusObjectKind.PER_EPOCH_CONFIG:
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

  static NormalizedMoveType _parseNormalizedMoveTypeBody(OpenSignatureBody body) {
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
              ? _parseNormalizedMoveTypeBody(body.typeParameterInstantiation.first)
              : null,
        );
      case OpenSignatureBody_Type.DATATYPE:
        final parts = body.typeName.split('::');
        return MoveTypeStruct(
          address: parts.first,
          module: parts.length > 1 ? parts[1] : '',
          name: parts.length > 2 ? parts[2] : '',
          typeArguments:
              body.typeParameterInstantiation.map(_parseNormalizedMoveTypeBody).toList(),
        );
      case OpenSignatureBody_Type.TYPE_PARAMETER:
        return MoveTypeParameter(body.typeParameter);
      default:
        return const MoveTypePrimitive('Unknown');
    }
  }
}
