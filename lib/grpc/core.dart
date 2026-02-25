// ignore: constant_identifier_names
const _MAX_OBJECTS_PER_BATCH = 50;

class GrpcCoreClient {
  final SuiGrpcClient _client;

  GrpcCoreClient(this._client);

  Future<List<Map<String, dynamic>>> getObjects(
    List<String> ids, {
    Map<String, bool>? include,
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
        return <String, dynamic>{'error': result.error.message};
      }
      final obj = result.object;
      return _parseObject(obj, include);
    }).toList();
  }

  // 2. listOwnedObjects
  Future<Map<String, dynamic>> listOwnedObjects(
    String owner, {
    String? objectType,
    String? cursor,
    int? limit,
    Map<String, bool>? include,
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

    return {
      'data': response.objects.map((obj) => _parseObject(obj, include)).toList(),
      'hasNextPage': response.hasNextPageToken() && response.nextPageToken.isNotEmpty,
      'nextCursor': response.hasNextPageToken() && response.nextPageToken.isNotEmpty
          ? base64Encode(response.nextPageToken)
          : null,
    };
  }

  // 3. listCoins
  Future<Map<String, dynamic>> listCoins(
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

    return {
      'data': response.objects.map((obj) {
        return {
          'coinType': normalizedCoinType,
          'coinObjectId': obj.objectId,
          'version': obj.version.toString(),
          'digest': obj.digest,
          'balance': obj.balance.toString(),
          'previousTransaction': obj.previousTransaction,
        };
      }).toList(),
      'hasNextPage': response.hasNextPageToken() && response.nextPageToken.isNotEmpty,
      'nextCursor': response.hasNextPageToken() && response.nextPageToken.isNotEmpty
          ? base64Encode(response.nextPageToken)
          : null,
    };
  }

  // 4. getBalance
  Future<Map<String, dynamic>> getBalance(String owner, {String coinType = '0x2::sui::SUI'}) async {
    final normalizedCoinType = normalizeStructTagString(coinType);

    final response = await _client.stateService.getBalance(
      GetBalanceRequest(owner: owner, coinType: normalizedCoinType),
    );

    final balance = response.balance;
    return {'coinType': balance.coinType, 'totalBalance': balance.balance.toString()};
  }

  // 5. getCoinMetadata
  Future<Map<String, dynamic>?> getCoinMetadata(String coinType) async {
    final normalizedCoinType = normalizeStructTagString(coinType);

    final response = await _client.stateService.getCoinInfo(
      GetCoinInfoRequest(coinType: normalizedCoinType),
    );

    if (!response.hasMetadata()) return null;

    final metadata = response.metadata;
    return {
      'id': metadata.id,
      'decimals': metadata.decimals,
      'name': metadata.name,
      'symbol': metadata.symbol,
      'description': metadata.description,
      'iconUrl': metadata.iconUrl.isNotEmpty ? metadata.iconUrl : null,
    };
  }

  // 6. listBalances
  Future<List<Map<String, dynamic>>> listBalances(String owner) async {
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
      return {'coinType': balance.coinType, 'totalBalance': balance.balance.toString()};
    }).toList();
  }

  // 7. getTransaction
  Future<Map<String, dynamic>> getTransaction(String digest, {Map<String, bool>? include}) async {
    final readMask = _transactionReadMask(include);

    final response = await _client.ledgerService.getTransaction(
      GetTransactionRequest(digest: digest, readMask: readMask),
    );

    return parseTransaction(response.transaction, include);
  }

  // 8. executeTransaction
  Future<Map<String, dynamic>> executeTransaction(
    Uint8List transactionBytes,
    List<String> signatures, {
    Map<String, bool>? include,
  }) async {
    final readMask = _transactionReadMask(include);

    final response = await _client.transactionExecutionService.executeTransaction(
      ExecuteTransactionRequest(
        transaction: grpc_transaction.Transaction()..mergeFromBuffer(transactionBytes),
        signatures: signatures.map((sig) {
          return UserSignature(bcs: grpc_bcs.Bcs(value: base64Decode(sig)));
        }),
        readMask: readMask,
      ),
    );

    return parseTransaction(response.transaction, include);
  }

  // 9. simulateTransaction
  Future<Map<String, dynamic>> simulateTransaction(
    Uint8List transactionBytes, {
    Map<String, bool>? include,
    bool? doGasSelection,
  }) async {
    final readMask = _transactionReadMask(include);

    final response = await _client.transactionExecutionService.simulateTransaction(
      SimulateTransactionRequest(
        transaction: grpc_transaction.Transaction()..mergeFromBuffer(transactionBytes),
        readMask: readMask,
        doGasSelection: doGasSelection ?? true,
      ),
    );

    final result = parseTransaction(response.transaction, include);

    if (include?['commandOutputs'] == true) {
      result['commandOutputs'] = response.commandOutputs.map((cmdResult) {
        return {
          'returnValues': cmdResult.returnValues.map((output) {
            return {
              'value': output.hasValue() ? base64Encode(output.value.value) : null,
              'json': output.hasJson() ? output.json.writeToJsonMap() : null,
            };
          }).toList(),
          'mutatedByRef': cmdResult.mutatedByRef.map((output) {
            return {
              'value': output.hasValue() ? base64Encode(output.value.value) : null,
              'json': output.hasJson() ? output.json.writeToJsonMap() : null,
            };
          }).toList(),
        };
      }).toList();
    }

    return result;
  }

  // 10. getReferenceGasPrice
  Future<String> getReferenceGasPrice() async {
    final response = await _client.ledgerService.getEpoch(
      GetEpochRequest(readMask: FieldMask(paths: ['reference_gas_price'])),
    );

    return response.epoch.referenceGasPrice.toString();
  }

  // 11. getCurrentSystemState
  Future<Map<String, dynamic>> getCurrentSystemState() async {
    final response = await _client.ledgerService.getEpoch(
      GetEpochRequest(
        readMask: FieldMask(
          paths: ['epoch', 'reference_gas_price', 'system_state', 'start', 'end'],
        ),
      ),
    );

    final epoch = response.epoch;
    return {
      'epoch': epoch.epoch.toString(),
      'referenceGasPrice': epoch.referenceGasPrice.toString(),
      if (epoch.hasSystemState()) 'systemState': epoch.systemState.writeToJsonMap(),
      if (epoch.hasStart()) 'epochStartTimestampMs': epoch.start.seconds.toString(),
    };
  }

  // 12. listDynamicFields
  Future<Map<String, dynamic>> listDynamicFields(
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

    return {
      'data': response.dynamicFields.map((field) {
        final nameType = field.hasName() ? field.name.name : null;
        return {
          'name': {'type': nameType, if (field.hasName()) 'value': base64Encode(field.name.value)},
          'objectType': field.valueType,
          'objectId': field.childId.isNotEmpty ? field.childId : field.fieldId,
          'type': _mapDynamicFieldKind(field.kind),
        };
      }).toList(),
      'hasNextPage': response.hasNextPageToken() && response.nextPageToken.isNotEmpty,
      'nextCursor': response.hasNextPageToken() && response.nextPageToken.isNotEmpty
          ? base64Encode(response.nextPageToken)
          : null,
    };
  }

  // 13. verifyZkLoginSignature
  Future<Map<String, dynamic>> verifyZkLoginSignature(
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

    return {'isValid': response.isValid, if (response.hasReason()) 'reason': response.reason};
  }

  // 14. defaultNameServiceName
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

  // 15. getMoveFunction
  Future<Map<String, dynamic>> getMoveFunction(
    String packageId,
    String moduleName,
    String functionName,
  ) async {
    final response = await _client.movePackageService.getFunction(
      GetFunctionRequest(packageId: packageId, moduleName: moduleName, name: functionName),
    );

    final func = response.function;
    return {
      'name': func.name,
      'visibility': _mapVisibility(func.visibility),
      'isEntry': func.isEntry,
      'typeParameters': func.typeParameters.map((tp) {
        return {'abilities': tp.constraints.map((a) => _mapAbility(a)).toList()};
      }).toList(),
      'parameters': func.parameters.map(parseNormalizedSuiMoveType).toList(),
      'return': func.returns.map(parseNormalizedSuiMoveType).toList(),
    };
  }

  // 16. getChainIdentifier
  Future<String> getChainIdentifier() async {
    final response = await _client.ledgerService.getServiceInfo(GetServiceInfoRequest());
    return response.chainId;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  FieldMask _objectReadMask(Map<String, bool>? include) {
    final paths = <String>['object_id', 'version', 'digest', 'object_type'];

    if (include?['owner'] == true) paths.add('owner');
    if (include?['previousTransaction'] == true) paths.add('previous_transaction');
    if (include?['content'] == true) {
      paths.add('contents');
      paths.add('json');
    }
    if (include?['bcs'] == true) paths.add('bcs');
    if (include?['storageRebate'] == true) paths.add('storage_rebate');

    return FieldMask(paths: paths);
  }

  FieldMask _transactionReadMask(Map<String, bool>? include) {
    final paths = <String>['digest'];

    if (include?['rawTransaction'] == true) {
      paths.add('transaction');
    }
    if (include?['effects'] == true) {
      paths.add('effects');
    }
    if (include?['events'] == true) {
      paths.add('events');
    }
    if (include?['balanceChanges'] == true) {
      paths.add('balance_changes');
    }
    if (include?['rawEffects'] == true) {
      paths.add('effects.bcs');
    }
    if (include?['objectChanges'] == true) {
      paths.add('effects.changed_objects');
      paths.add('effects.unchanged_consensus_objects');
    }
    if (include?['checkpoint'] == true) {
      paths.add('checkpoint');
    }
    if (include?['timestampMs'] == true) {
      paths.add('timestamp');
    }

    return FieldMask(paths: paths);
  }

  Map<String, dynamic> _parseObject(grpc_object.Object obj, Map<String, bool>? include) {
    final result = <String, dynamic>{
      'objectId': obj.objectId,
      'version': obj.version.toString(),
      'digest': obj.digest,
      'type': obj.objectType,
    };

    if (include?['owner'] == true && obj.hasOwner()) {
      result['owner'] = mapOwner(obj.owner);
    }
    if (include?['previousTransaction'] == true) {
      result['previousTransaction'] = obj.previousTransaction;
    }
    if (include?['content'] == true) {
      if (obj.hasJson()) {
        result['content'] = obj.json.writeToJsonMap();
      }
      if (obj.hasContents()) {
        result['contentBcs'] = base64Encode(obj.contents.value);
      }
    }
    if (include?['bcs'] == true && obj.hasBcs()) {
      result['bcs'] = base64Encode(obj.bcs.value);
    }
    if (include?['storageRebate'] == true) {
      result['storageRebate'] = obj.storageRebate.toString();
    }

    return result;
  }

  String _mapDynamicFieldKind(DynamicField_DynamicFieldKind kind) {
    switch (kind) {
      case DynamicField_DynamicFieldKind.FIELD:
        return 'DynamicField';
      case DynamicField_DynamicFieldKind.OBJECT:
        return 'DynamicObject';
      default:
        return 'Unknown';
    }
  }

  String _mapVisibility(FunctionDescriptor_Visibility visibility) {
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

  String _mapAbility(Ability ability) {
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
}

// ---------------------------------------------------------------------------
// Top-level helper functions
// ---------------------------------------------------------------------------

Map<String, dynamic>? mapOwner(Owner owner) {
  switch (owner.kind) {
    case Owner_OwnerKind.ADDRESS:
      return {'AddressOwner': owner.address};
    case Owner_OwnerKind.OBJECT:
      return {'ObjectOwner': owner.address};
    case Owner_OwnerKind.SHARED:
      return {
        'Shared': {'initial_shared_version': owner.version.toString()},
      };
    case Owner_OwnerKind.IMMUTABLE:
      return 'Immutable' as dynamic;
    case Owner_OwnerKind.CONSENSUS_ADDRESS:
      return {
        'ConsensusAddress': {'address': owner.address, 'start_version': owner.version.toString()},
      };
    default:
      return null;
  }
}

Map<String, dynamic> parseGrpcExecutionError(ExecutionError error) {
  final result = <String, dynamic>{
    'description': error.description,
    'kind': mapErrorName(error.kind),
  };

  if (error.hasCommand()) {
    result['command'] = error.command.toString();
  }

  final errorDetails = error.whichErrorDetails();
  switch (errorDetails) {
    case ExecutionError_ErrorDetails.abort:
      result['abort'] = parseMoveAbort(error.abort);
      break;
    case ExecutionError_ErrorDetails.sizeError:
      result['sizeError'] = {
        'size': error.sizeError.size.toString(),
        'maxSize': error.sizeError.maxSize.toString(),
      };
      break;
    case ExecutionError_ErrorDetails.commandArgumentError:
      result['commandArgumentError'] = {
        'argument': error.commandArgumentError.argument,
        'kind': mapErrorName(error.commandArgumentError.kind),
      };
      break;
    case ExecutionError_ErrorDetails.typeArgumentError:
      result['typeArgumentError'] = {
        'typeArgument': error.typeArgumentError.typeArgument,
        'kind': mapErrorName(error.typeArgumentError.kind),
      };
      break;
    case ExecutionError_ErrorDetails.packageUpgradeError:
      result['packageUpgradeError'] = {
        'kind': mapErrorName(error.packageUpgradeError.kind),
        'packageId': error.packageUpgradeError.packageId,
      };
      break;
    case ExecutionError_ErrorDetails.indexError:
      result['indexError'] = {
        'index': error.indexError.index,
        'subresult': error.indexError.subresult,
      };
      break;
    case ExecutionError_ErrorDetails.objectId:
      result['objectId'] = error.objectId;
      break;
    case ExecutionError_ErrorDetails.coinDenyListError:
      result['coinDenyListError'] = {
        'address': error.coinDenyListError.address,
        'coinType': error.coinDenyListError.coinType,
      };
      break;
    case ExecutionError_ErrorDetails.congestedObjects:
      result['congestedObjects'] = error.congestedObjects.objects;
      break;
    case ExecutionError_ErrorDetails.notSet:
      break;
  }

  return result;
}

Map<String, dynamic> parseMoveAbort(MoveAbort abort) {
  final result = <String, dynamic>{'abortCode': abort.abortCode.toString()};

  if (abort.hasLocation()) {
    result['location'] = {
      'package': abort.location.package,
      'module': abort.location.module,
      'function': abort.location.function,
      'instruction': abort.location.instruction,
      if (abort.location.hasFunctionName()) 'functionName': abort.location.functionName,
    };
  }

  if (abort.hasCleverError()) {
    final cleverError = abort.cleverError;
    if (cleverError.whichValue() == CleverError_Value.rendered) {
      result['cleverError'] = cleverError.rendered;
    } else if (cleverError.whichValue() == CleverError_Value.raw) {
      result['cleverErrorRaw'] = base64Encode(cleverError.raw);
    }
  }

  return result;
}

String mapErrorName(ProtobufEnum? value) {
  if (value == null) return 'UNKNOWN';
  return value.name;
}

String? mapIdOperation(ChangedObject_IdOperation operation) {
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

String? mapInputObjectState(ChangedObject_InputObjectState state) {
  switch (state) {
    case ChangedObject_InputObjectState.INPUT_OBJECT_STATE_DOES_NOT_EXIST:
      return 'DoesNotExist';
    case ChangedObject_InputObjectState.INPUT_OBJECT_STATE_EXISTS:
      return 'Exists';
    default:
      return null;
  }
}

String? mapOutputObjectState(ChangedObject_OutputObjectState state) {
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

String? mapUnchangedConsensusObjectKind(
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

Map<String, dynamic>? parseTransactionEffects(TransactionEffects effects) {
  final result = <String, dynamic>{};

  if (effects.hasDigest()) {
    result['digest'] = effects.digest;
  }
  if (effects.hasTransactionDigest()) {
    result['transactionDigest'] = effects.transactionDigest;
  }
  if (effects.hasEpoch()) {
    result['epoch'] = effects.epoch.toString();
  }
  if (effects.hasLamportVersion()) {
    result['lamportVersion'] = effects.lamportVersion.toString();
  }

  if (effects.hasStatus()) {
    final status = effects.status;
    result['status'] = {
      'success': status.success,
      if (status.hasError()) 'error': parseGrpcExecutionError(status.error),
    };
  }

  if (effects.hasGasUsed()) {
    final gas = effects.gasUsed;
    result['gasUsed'] = {
      'computationCost': gas.computationCost.toString(),
      'storageCost': gas.storageCost.toString(),
      'storageRebate': gas.storageRebate.toString(),
      'nonRefundableStorageFee': gas.nonRefundableStorageFee.toString(),
    };
  }

  if (effects.hasGasObject()) {
    final gasObj = effects.gasObject;
    result['gasObject'] = {
      'objectId': gasObj.objectId,
      'inputState': mapInputObjectState(gasObj.inputState),
      'outputState': mapOutputObjectState(gasObj.outputState),
    };
  }

  if (effects.dependencies.isNotEmpty) {
    result['dependencies'] = effects.dependencies.toList();
  }

  if (effects.changedObjects.isNotEmpty) {
    result['changedObjects'] = effects.changedObjects.map((obj) {
      final entry = <String, dynamic>{
        'objectId': obj.objectId,
        'idOperation': mapIdOperation(obj.idOperation),
        'inputState': mapInputObjectState(obj.inputState),
        'outputState': mapOutputObjectState(obj.outputState),
      };
      if (obj.hasInputVersion()) {
        entry['inputVersion'] = obj.inputVersion.toString();
      }
      if (obj.hasInputDigest()) {
        entry['inputDigest'] = obj.inputDigest;
      }
      if (obj.hasInputOwner()) {
        entry['inputOwner'] = mapOwner(obj.inputOwner);
      }
      if (obj.hasOutputVersion()) {
        entry['outputVersion'] = obj.outputVersion.toString();
      }
      if (obj.hasOutputDigest()) {
        entry['outputDigest'] = obj.outputDigest;
      }
      if (obj.hasOutputOwner()) {
        entry['outputOwner'] = mapOwner(obj.outputOwner);
      }
      if (obj.objectType.isNotEmpty) {
        entry['objectType'] = obj.objectType;
      }
      return entry;
    }).toList();
  }

  if (effects.unchangedConsensusObjects.isNotEmpty) {
    result['unchangedConsensusObjects'] = effects.unchangedConsensusObjects.map((obj) {
      return {
        'kind': mapUnchangedConsensusObjectKind(obj.kind),
        'objectId': obj.objectId,
        'version': obj.version.toString(),
        if (obj.digest.isNotEmpty) 'digest': obj.digest,
        if (obj.objectType.isNotEmpty) 'objectType': obj.objectType,
      };
    }).toList();
  }

  if (effects.hasEventsDigest()) {
    result['eventsDigest'] = effects.eventsDigest;
  }

  if (effects.hasBcs()) {
    result['bcs'] = base64Encode(effects.bcs.value);
  }

  return result;
}

Map<String, dynamic> parseTransaction(ExecutedTransaction tx, Map<String, bool>? include) {
  final result = <String, dynamic>{'digest': tx.digest};

  if (include?['rawTransaction'] == true && tx.hasTransaction()) {
    result['rawTransaction'] = base64Encode(tx.transaction.writeToBuffer());
  }

  if (include?['effects'] == true && tx.hasEffects()) {
    result['effects'] = parseTransactionEffects(tx.effects);
  }

  if (include?['rawEffects'] == true && tx.hasEffects() && tx.effects.hasBcs()) {
    result['rawEffects'] = base64Encode(tx.effects.bcs.value);
  }

  if (include?['events'] == true && tx.hasEvents()) {
    result['events'] = tx.events.events.map((event) {
      return {
        'packageId': event.packageId,
        'transactionModule': event.module,
        'sender': event.sender,
        'type': event.eventType,
        if (event.hasJson()) 'parsedJson': event.json.writeToJsonMap(),
        if (event.hasContents()) 'bcs': base64Encode(event.contents.value),
      };
    }).toList();
  }

  if (include?['balanceChanges'] == true) {
    result['balanceChanges'] = tx.balanceChanges.map((change) {
      return {'owner': change.address, 'coinType': change.coinType, 'amount': change.amount};
    }).toList();
  }

  if (include?['objectChanges'] == true && tx.hasEffects()) {
    final effects = tx.effects;
    result['objectChanges'] = effects.changedObjects.map((obj) {
      final entry = <String, dynamic>{
        'objectId': obj.objectId,
        'idOperation': mapIdOperation(obj.idOperation),
        'inputState': mapInputObjectState(obj.inputState),
        'outputState': mapOutputObjectState(obj.outputState),
      };
      if (obj.hasOutputVersion()) {
        entry['version'] = obj.outputVersion.toString();
      }
      if (obj.hasOutputDigest()) {
        entry['digest'] = obj.outputDigest;
      }
      if (obj.hasOutputOwner()) {
        entry['owner'] = mapOwner(obj.outputOwner);
      }
      if (obj.objectType.isNotEmpty) {
        entry['objectType'] = obj.objectType;
      }
      return entry;
    }).toList();
  }

  if (include?['checkpoint'] == true && tx.hasCheckpoint()) {
    result['checkpoint'] = tx.checkpoint.toString();
  }

  if (include?['timestampMs'] == true && tx.hasTimestamp()) {
    result['timestampMs'] = (tx.timestamp.seconds * Int64(1000)).toString();
  }

  return result;
}

Map<String, dynamic> parseNormalizedSuiMoveType(OpenSignature sig) {
  final result = <String, dynamic>{};

  if (sig.reference == OpenSignature_Reference.IMMUTABLE) {
    result['Reference'] = parseNormalizedSuiMoveTypeBody(sig.body);
  } else if (sig.reference == OpenSignature_Reference.MUTABLE) {
    result['MutableReference'] = parseNormalizedSuiMoveTypeBody(sig.body);
  } else {
    return parseNormalizedSuiMoveTypeBody(sig.body);
  }

  return result;
}

Map<String, dynamic> parseNormalizedSuiMoveTypeBody(OpenSignatureBody body) {
  switch (body.type) {
    case OpenSignatureBody_Type.ADDRESS:
      return {'type': 'Address'};
    case OpenSignatureBody_Type.BOOL:
      return {'type': 'Bool'};
    case OpenSignatureBody_Type.U8:
      return {'type': 'U8'};
    case OpenSignatureBody_Type.U16:
      return {'type': 'U16'};
    case OpenSignatureBody_Type.U32:
      return {'type': 'U32'};
    case OpenSignatureBody_Type.U64:
      return {'type': 'U64'};
    case OpenSignatureBody_Type.U128:
      return {'type': 'U128'};
    case OpenSignatureBody_Type.U256:
      return {'type': 'U256'};
    case OpenSignatureBody_Type.VECTOR:
      if (body.typeParameterInstantiation.isNotEmpty) {
        return {'Vector': parseNormalizedSuiMoveTypeBody(body.typeParameterInstantiation.first)};
      }
      return {'Vector': null};
    case OpenSignatureBody_Type.DATATYPE:
      return {
        'Struct': {
          'address': body.typeName.split('::').first,
          'module': body.typeName.split('::').length > 1 ? body.typeName.split('::')[1] : '',
          'name': body.typeName.split('::').length > 2 ? body.typeName.split('::')[2] : '',
          'typeArguments': body.typeParameterInstantiation
              .map(parseNormalizedSuiMoveTypeBody)
              .toList(),
        },
      };
    case OpenSignatureBody_Type.TYPE_PARAMETER:
      return {'TypeParameter': body.typeParameter};
    default:
      return {'type': 'Unknown'};
  }
}
