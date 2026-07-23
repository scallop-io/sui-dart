import 'dart:convert';
import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:grpc/grpc.dart';

import 'package:sui_dart/grpc/generated/sui/rpc/v2/ledger_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/move_package_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/name_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/signature_verification_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/state_service.pbgrpc.dart'
    hide Balance, CoinMetadata;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/subscription_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction_execution_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/forking/v1alpha/forking_service.pbgrpc.dart';

import 'package:sui_dart/sui.dart' as sui_dart;

import 'grpc_core_client.dart';
import 'types.dart';

export 'grpc_core_client.dart' show GrpcCoreClient;
export 'types.dart';

class SuiGrpcClientOptions {
  final String baseUrl;
  final int port;
  final ClientChannel? customChannel;

  SuiGrpcClientOptions({
    required this.baseUrl,
    this.customChannel,
    required this.port,
  });
}

class SuiGrpcClient {
  late final ClientChannel _channel;
  late final GrpcCoreClient core;

  late final TransactionExecutionServiceClient transactionExecutionService;
  late final LedgerServiceClient ledgerService;
  late final StateServiceClient stateService;
  late final SubscriptionServiceClient subscriptionService;
  late final MovePackageServiceClient movePackageService;
  late final SignatureVerificationServiceClient signatureVerificationService;
  late final NameServiceClient nameService;

  /// Admin-only service on `sui-fork` instances.
  late final ForkingServiceClient forkingService;

  SuiGrpcClient(SuiGrpcClientOptions options) {
    _channel =
        options.customChannel ??
        ClientChannel(
          options.baseUrl,
          port: options.port,
          options: ChannelOptions(credentials: ChannelCredentials.secure()),
        );

    transactionExecutionService = TransactionExecutionServiceClient(_channel);
    ledgerService = LedgerServiceClient(_channel);
    stateService = StateServiceClient(_channel);
    subscriptionService = SubscriptionServiceClient(_channel);
    movePackageService = MovePackageServiceClient(_channel);
    signatureVerificationService = SignatureVerificationServiceClient(_channel);
    nameService = NameServiceClient(_channel);
    forkingService = ForkingServiceClient(_channel);

    core = GrpcCoreClient(this);
  }

  Future<List<ObjectResult>> getObjects(
    List<String> ids, {
    ObjectIncludeOptions? include,
  }) {
    return core.getObjects(ids, include: include);
  }

  /// Derives the field UID from [parentId] + the encoded name and fetches it
  /// (`null` if absent).
  Future<ObjectData?> getDynamicFieldObject(
    String parentId,
    String nameType,
    dynamic nameValue, {
    ObjectIncludeOptions? include,
  }) async {
    final keyBcs = _encodeDynamicFieldName(nameType, nameValue);
    if (keyBcs == null) return null;

    final fieldId = sui_dart.deriveDynamicFieldId(
      parentObjectId: parentId,
      keyTypeTag: nameType,
      keyBcs: keyBcs,
    );

    final objects = await getObjects([
      fieldId,
    ], include: include ?? const ObjectIncludeOptions(json: true));
    if (objects.isNotEmpty && objects.first is ObjectSuccess) {
      return (objects.first as ObjectSuccess).data;
    }
    return null;
  }

  Future<Page<ObjectData>> getOwnedObjects(
    String owner, {
    String? objectType,
    String? cursor,
    int? limit,
    ObjectIncludeOptions? include,
  }) {
    return core.getOwnedObjects(
      owner,
      type: objectType,
      cursor: cursor,
      limit: limit,
      include: include,
    );
  }

  Future<Page<CoinData>> getCoins(
    String owner, {
    String coinType = '0x2::sui::SUI',
    String? cursor,
    int? limit,
  }) {
    return core.getCoins(
      owner,
      coinType: coinType,
      cursor: cursor,
      limit: limit,
    );
  }

  Future<Balance> getBalance(
    String owner, {
    String coinType = '0x2::sui::SUI',
  }) {
    return core.getBalance(owner, coinType: coinType);
  }

  Future<List<Balance>> getAllBalances(String owner) {
    return core.getAllBalances(owner);
  }

  Future<CoinMetadata?> getCoinMetadata(String coinType) {
    return core.getCoinMetadata(coinType);
  }

  Future<TransactionResponse> getTransaction(
    String digest, {
    TransactionIncludeOptions? include,
  }) {
    return core.getTransaction(digest, include: include);
  }

  Future<TransactionResponse> executeTransaction(
    Uint8List transactionBytes,
    List<String> signatures, {
    TransactionIncludeOptions? include,
  }) {
    return core.executeTransaction(
      transactionBytes,
      signatures,
      include: include,
    );
  }

  Future<TransactionResponse> simulateTransaction(
    sui_dart.Transaction transactionBlock, {
    TransactionIncludeOptions? include,
    bool? doGasSelection,
    bool? checksEnabled,
  }) {
    return core.simulateTransaction(
      transactionBlock,
      include: include,
      doGasSelection: doGasSelection,
      checksEnabled: checksEnabled,
    );
  }

  Future<String> getReferenceGasPrice() {
    return core.getReferenceGasPrice();
  }

  Future<SystemState> getCurrentSystemState() {
    return core.getCurrentSystemState();
  }

  Future<Page<DynamicFieldEntry>> getDynamicFields(
    String parentId, {
    String? cursor,
    int? limit,
  }) {
    return core.getDynamicFields(parentId, cursor: cursor, limit: limit);
  }

  Future<VerifySignatureResult> verifyZkLoginSignature(
    Uint8List bytes,
    String signature, {
    String? address,
  }) {
    return core.verifyZkLoginSignature(bytes, signature, address: address);
  }

  Future<String?> defaultNameServiceName(String address) {
    return core.defaultNameServiceName(address);
  }

  Future<MoveFunction> getMoveFunction(
    String packageId,
    String moduleName,
    String functionName,
  ) {
    return core.getMoveFunction(packageId, moduleName, functionName);
  }

  Future<String> getChainIdentifier() {
    return core.getChainIdentifier();
  }

  Future<void> shutdown() async {
    await _channel.shutdown();
  }
}

/// BCS-encodes a dynamic-field name (address/ID, integers, `vector<u8>`,
/// or a single-field wrapper struct). Null if it can't be encoded.
Uint8List? _encodeDynamicFieldName(String nameType, dynamic nameValue) {
  if (nameValue == null) return null;
  try {
    final t = nameType.trim();
    final tl = t.toLowerCase();

    // 32-byte address keys, incl. TypedID<T>.
    if (tl == 'address' ||
        tl.endsWith('::object::id') ||
        tl.contains('::typed_id::typedid')) {
      if (nameValue is! String) return null;
      return Bcs.bytes(sui_dart.SUI_ADDRESS_LENGTH)
          .serialize(
            Uint8List.fromList(
              fromHEX(sui_dart.normalizeSuiAddress(nameValue)),
            ),
          )
          .toBytes();
    }

    if (t == 'u8') return Bcs.u8().serialize(nameValue as int).toBytes();
    if (t == 'u16') return Bcs.u16().serialize(nameValue as int).toBytes();
    if (t == 'u32') return Bcs.u32().serialize(nameValue as int).toBytes();
    if (t == 'u64') return Bcs.u64().serialize(nameValue).toBytes();
    if (t == 'u128') return Bcs.u128().serialize(nameValue).toBytes();
    if (t == 'u256') return Bcs.u256().serialize(nameValue).toBytes();

    if (t == 'vector<u8>') {
      List<int> bytes;
      if (nameValue is String) {
        bytes = utf8.encode(nameValue);
      } else if (nameValue is List<int>) {
        bytes = nameValue;
      } else if (nameValue is List) {
        bytes = nameValue.cast<int>();
      } else {
        return null;
      }
      return Bcs.vector(Bcs.u8()).serialize(bytes).toBytes();
    }

    // Single-bool wrapper struct.
    if (nameValue is Map && nameValue['dummy_field'] is bool) {
      return Bcs.boolean()
          .serialize(nameValue['dummy_field'] as bool)
          .toBytes();
    }

    // Single-bytes wrapper struct.
    if (nameValue is Map && nameValue['bytes'] is List) {
      return Bcs.vector(
        Bcs.u8(),
      ).serialize((nameValue['bytes'] as List).cast<int>()).toBytes();
    }

    // String fallback: ascii/string::String, TypeName, or similar.
    final s = nameValue is String
        ? nameValue
        : (nameValue is Map ? (nameValue['name'] ?? nameValue['bytes']) : null);
    if (s is String) {
      return Bcs.vector(Bcs.u8()).serialize(utf8.encode(s)).toBytes();
    }
  } catch (_) {
    return null;
  }
  return null;
}
