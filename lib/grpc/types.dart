import 'dart:typed_data';

import 'package:sui_dart/types/common.dart' as legacy_common;
import 'package:sui_dart/types/objects.dart' as legacy_objects;

class ObjectIncludeOptions {
  final bool content;
  final bool previousTransaction;
  final bool objectBcs;
  final bool json;

  const ObjectIncludeOptions({
    this.content = false,
    this.previousTransaction = false,
    this.objectBcs = false,
    this.json = false,
  });
}

class TransactionIncludeOptions {
  final bool transaction;
  final bool effects;
  final bool events;
  final bool balanceChanges;
  final bool objectTypes;
  final bool bcs;
  final bool commandResults;

  const TransactionIncludeOptions({
    this.transaction = false,
    this.effects = false,
    this.events = false,
    this.balanceChanges = false,
    this.objectTypes = false,
    this.bcs = false,
    this.commandResults = false,
  });
}

class Page<T> {
  final List<T> data;
  final bool hasNextPage;
  final String? nextCursor;

  const Page({
    required this.data,
    required this.hasNextPage,
    this.nextCursor,
  });
}

sealed class Owner {
  const Owner();
}

class AddressOwner extends Owner {
  final String address;
  const AddressOwner(this.address);
}

class ObjectOwner extends Owner {
  final String address;
  const ObjectOwner(this.address);
}

class SharedOwner extends Owner {
  final String initialSharedVersion;
  const SharedOwner(this.initialSharedVersion);
}

class ImmutableOwner extends Owner {
  const ImmutableOwner();
}

class ConsensusAddressOwner extends Owner {
  final String address;
  final String startVersion;
  const ConsensusAddressOwner({
    required this.address,
    required this.startVersion,
  });
}

class UnknownOwner extends Owner {
  const UnknownOwner();
}

sealed class ObjectResult {
  const ObjectResult();
}

class ObjectSuccess extends ObjectResult {
  final ObjectData data;
  const ObjectSuccess(this.data);
}

class ObjectError extends ObjectResult {
  final String error;
  const ObjectError(this.error);
}

class ObjectData {
  final String objectId;
  final String version;
  final String digest;
  final Owner owner;
  final String type;
  final Uint8List? content;
  final String? previousTransaction;
  final Uint8List? objectBcs;
  final Map<String, dynamic>? json;

  const ObjectData({
    required this.objectId,
    required this.version,
    required this.digest,
    required this.owner,
    required this.type,
    this.content,
    this.previousTransaction,
    this.objectBcs,
    this.json,
  });

  
}

class CoinData {
  final String objectId;
  final String version;
  final String digest;
  final Owner owner;
  final String type;
  final String balance;

  const CoinData({
    required this.objectId,
    required this.version,
    required this.digest,
    required this.owner,
    required this.type,
    required this.balance,
  });
}

class Balance {
  final String coinType;
  final String balance;
  final String coinBalance;
  final String addressBalance;

  const Balance({
    required this.coinType,
    required this.balance,
    required this.coinBalance,
    required this.addressBalance,
  });
}

class CoinMetadata {
  final String id;
  final int decimals;
  final String name;
  final String symbol;
  final String description;
  final String? iconUrl;

  const CoinMetadata({
    required this.id,
    required this.decimals,
    required this.name,
    required this.symbol,
    required this.description,
    this.iconUrl,
  });
}

class TransactionResponse {
  final String digest;
  final List<String> signatures;
  final String? epoch;
  final ExecutionStatus status;
  final String? transaction;
  final TransactionEffects? effects;
  final List<Event>? events;
  final List<BalanceChange>? balanceChanges;
  final Map<String, String>? objectTypes;
  final Uint8List? bcs;
  final String? checkpoint;
  final String? timestampMs;
  final List<CommandResult>? commandResults;

  const TransactionResponse({
    required this.digest,
    this.signatures = const [],
    this.epoch,
    this.status = const ExecutionStatus(success: true),
    this.transaction,
    this.effects,
    this.events,
    this.balanceChanges,
    this.objectTypes,
    this.bcs,
    this.checkpoint,
    this.timestampMs,
    this.commandResults,
  });

  TransactionResponse copyWith({
    String? digest,
    List<String>? signatures,
    String? epoch,
    ExecutionStatus? status,
    String? transaction,
    TransactionEffects? effects,
    List<Event>? events,
    List<BalanceChange>? balanceChanges,
    Map<String, String>? objectTypes,
    Uint8List? bcs,
    String? checkpoint,
    String? timestampMs,
    List<CommandResult>? commandResults,
  }) {
    return TransactionResponse(
      digest: digest ?? this.digest,
      signatures: signatures ?? this.signatures,
      epoch: epoch ?? this.epoch,
      status: status ?? this.status,
      transaction: transaction ?? this.transaction,
      effects: effects ?? this.effects,
      events: events ?? this.events,
      balanceChanges: balanceChanges ?? this.balanceChanges,
      objectTypes: objectTypes ?? this.objectTypes,
      bcs: bcs ?? this.bcs,
      checkpoint: checkpoint ?? this.checkpoint,
      timestampMs: timestampMs ?? this.timestampMs,
      commandResults: commandResults ?? this.commandResults,
    );
  }
}

class TransactionEffects {
  final Uint8List? bcs;
  final int? version;
  final String? transactionDigest;
  final String? lamportVersion;
  final ExecutionStatus? status;
  final GasUsed? gasUsed;
  final GasObject? gasObject;
  final List<String>? dependencies;
  final List<ChangedObject>? changedObjects;
  final List<UnchangedConsensusObject>? unchangedConsensusObjects;
  final String? eventsDigest;
  final String? auxiliaryDataDigest;

  const TransactionEffects({
    this.bcs,
    this.version,
    this.transactionDigest,
    this.lamportVersion,
    this.status,
    this.gasUsed,
    this.gasObject,
    this.dependencies,
    this.changedObjects,
    this.unchangedConsensusObjects,
    this.eventsDigest,
    this.auxiliaryDataDigest,
  });
}

class ExecutionStatus {
  final bool success;
  final ExecutionError? error;

  const ExecutionStatus({
    required this.success,
    this.error,
  });
}

class GasUsed {
  final String computationCost;
  final String storageCost;
  final String storageRebate;
  final String nonRefundableStorageFee;

  const GasUsed({
    required this.computationCost,
    required this.storageCost,
    required this.storageRebate,
    required this.nonRefundableStorageFee,
  });
}

class GasObject {
  final String objectId;
  final String? inputState;
  final String? outputState;

  const GasObject({
    required this.objectId,
    this.inputState,
    this.outputState,
  });
}

class ExecutionError {
  final String message;
  final String kind;
  final int? command;
  final ExecutionErrorDetail? detail;

  const ExecutionError({
    required this.message,
    required this.kind,
    this.command,
    this.detail,
  });
}

sealed class ExecutionErrorDetail {
  const ExecutionErrorDetail();
}

class AbortDetail extends ExecutionErrorDetail {
  final MoveAbort abort;
  const AbortDetail(this.abort);
}

class SizeErrorDetail extends ExecutionErrorDetail {
  final String size;
  final String maxSize;
  const SizeErrorDetail({required this.size, required this.maxSize});
}

class CommandArgumentErrorDetail extends ExecutionErrorDetail {
  final int argument;
  final String kind;
  const CommandArgumentErrorDetail({
    required this.argument,
    required this.kind,
  });
}

class TypeArgumentErrorDetail extends ExecutionErrorDetail {
  final int typeArgument;
  final String kind;
  const TypeArgumentErrorDetail({
    required this.typeArgument,
    required this.kind,
  });
}

class PackageUpgradeErrorDetail extends ExecutionErrorDetail {
  final String kind;
  final String packageId;
  const PackageUpgradeErrorDetail({
    required this.kind,
    required this.packageId,
  });
}

class IndexErrorDetail extends ExecutionErrorDetail {
  final int index;
  final int subresult;
  const IndexErrorDetail({required this.index, required this.subresult});
}

class ObjectIdErrorDetail extends ExecutionErrorDetail {
  final String objectId;
  const ObjectIdErrorDetail(this.objectId);
}

class CoinDenyListErrorDetail extends ExecutionErrorDetail {
  final String address;
  final String coinType;
  const CoinDenyListErrorDetail({
    required this.address,
    required this.coinType,
  });
}

class CongestedObjectsDetail extends ExecutionErrorDetail {
  final List<String> objects;
  const CongestedObjectsDetail(this.objects);
}

class MoveAbort {
  final String abortCode;
  final MoveAbortLocation? location;
  final String? cleverError;
  final String? cleverErrorRaw;

  const MoveAbort({
    required this.abortCode,
    this.location,
    this.cleverError,
    this.cleverErrorRaw,
  });
}

class MoveAbortLocation {
  final String package;
  final String module;
  final int function;
  final int instruction;
  final String? functionName;

  const MoveAbortLocation({
    required this.package,
    required this.module,
    required this.function,
    required this.instruction,
    this.functionName,
  });
}

class ChangedObject {
  final String objectId;
  final String? idOperation;
  final String? inputState;
  final String? outputState;
  final String? inputVersion;
  final String? inputDigest;
  final Owner? inputOwner;
  final String? outputVersion;
  final String? outputDigest;
  final Owner? outputOwner;
  final String? objectType;

  const ChangedObject({
    required this.objectId,
    this.idOperation,
    this.inputState,
    this.outputState,
    this.inputVersion,
    this.inputDigest,
    this.inputOwner,
    this.outputVersion,
    this.outputDigest,
    this.outputOwner,
    this.objectType,
  });
}

class UnchangedConsensusObject {
  final String? kind;
  final String objectId;
  final String version;
  final String? digest;
  final String? objectType;

  const UnchangedConsensusObject({
    this.kind,
    required this.objectId,
    required this.version,
    this.digest,
    this.objectType,
  });
}

class Event {
  final String packageId;
  final String module;
  final String sender;
  final String eventType;
  final Uint8List bcs;

  const Event({
    required this.packageId,
    required this.module,
    required this.sender,
    required this.eventType,
    required this.bcs,
  });
}

class BalanceChange {
  final String address;
  final String coinType;
  final String amount;

  const BalanceChange({
    required this.address,
    required this.coinType,
    required this.amount,
  });
}

class DynamicFieldEntry {
  final DynamicFieldName name;
  final String objectType;
  final String objectId;
  final String type;

  const DynamicFieldEntry({
    required this.name,
    required this.objectType,
    required this.objectId,
    required this.type,
  });
}

class DynamicFieldName {
  final String? type;
  final Uint8List? bcs;

  const DynamicFieldName({this.type, this.bcs});
}

class SystemState {
  final String epoch;
  final String referenceGasPrice;
  final Map<String, dynamic>? systemState;
  final String? epochStartTimestampMs;

  const SystemState({
    required this.epoch,
    required this.referenceGasPrice,
    this.systemState,
    this.epochStartTimestampMs,
  });
}

class VerifySignatureResult {
  final bool isValid;
  final String? reason;

  const VerifySignatureResult({
    required this.isValid,
    this.reason,
  });
}

class MoveFunction {
  final String name;
  final String visibility;
  final bool isEntry;
  final List<TypeParameter> typeParameters;
  final List<NormalizedMoveType> parameters;
  final List<NormalizedMoveType> returnTypes;

  const MoveFunction({
    required this.name,
    required this.visibility,
    required this.isEntry,
    required this.typeParameters,
    required this.parameters,
    required this.returnTypes,
  });
}

class TypeParameter {
  final List<String> abilities;
  const TypeParameter({required this.abilities});
}

sealed class NormalizedMoveType {
  const NormalizedMoveType();
}

class MoveTypePrimitive extends NormalizedMoveType {
  final String typeName;
  const MoveTypePrimitive(this.typeName);
}

class MoveTypeVector extends NormalizedMoveType {
  final NormalizedMoveType? element;
  const MoveTypeVector(this.element);
}

class MoveTypeStruct extends NormalizedMoveType {
  final String address;
  final String module;
  final String name;
  final List<NormalizedMoveType> typeArguments;

  const MoveTypeStruct({
    required this.address,
    required this.module,
    required this.name,
    required this.typeArguments,
  });
}

class MoveTypeParameter extends NormalizedMoveType {
  final int index;
  const MoveTypeParameter(this.index);
}

class MoveTypeReference extends NormalizedMoveType {
  final NormalizedMoveType body;
  const MoveTypeReference(this.body);
}

class MoveTypeMutableReference extends NormalizedMoveType {
  final NormalizedMoveType body;
  const MoveTypeMutableReference(this.body);
}

class CommandResult {
  final List<CommandOutput> returnValues;
  final List<CommandOutput> mutatedReferences;

  const CommandResult({
    required this.returnValues,
    required this.mutatedReferences,
  });
}

class CommandOutput {
  final Uint8List bcs;

  const CommandOutput({required this.bcs});
}
