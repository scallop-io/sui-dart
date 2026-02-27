import 'dart:typed_data';

import 'package:grpc/grpc.dart';

import 'package:sui_dart/grpc/generated/sui/rpc/v2/ledger_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/move_package_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/name_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/signature_verification_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/state_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/subscription_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction_execution_service.pbgrpc.dart';

import 'package:sui_dart/sui.dart' as sui_dart;

import 'core.dart';
import 'types.dart';

export 'core.dart' show GrpcCoreClient;
export 'types.dart';

class SuiGrpcClientOptions {
  final String baseUrl;
  final int port;
  final ClientChannel? customChannel;

  SuiGrpcClientOptions({required this.baseUrl, this.customChannel, required this.port});
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

    core = GrpcCoreClient(this);
  }

  Future<List<GrpcObjectResult>> getObjects(List<String> ids, {ObjectIncludeOptions? include}) {
    return core.getObjects(ids, include: include);
  }

  Future<GrpcPage<GrpcObjectData>> listOwnedObjects(
    String owner, {
    String? objectType,
    String? cursor,
    int? limit,
    ObjectIncludeOptions? include,
  }) {
    return core.listOwnedObjects(
      owner,
      objectType: objectType,
      cursor: cursor,
      limit: limit,
      include: include,
    );
  }

  Future<GrpcPage<GrpcCoinData>> listCoins(
    String owner, {
    String coinType = '0x2::sui::SUI',
    String? cursor,
    int? limit,
  }) {
    return core.listCoins(owner, coinType: coinType, cursor: cursor, limit: limit);
  }

  Future<GrpcBalance> getBalance(String owner, {String coinType = '0x2::sui::SUI'}) {
    return core.getBalance(owner, coinType: coinType);
  }

  Future<List<GrpcBalance>> listBalances(String owner) {
    return core.listBalances(owner);
  }

  Future<GrpcCoinMetadata?> getCoinMetadata(String coinType) {
    return core.getCoinMetadata(coinType);
  }

  Future<GrpcTransactionResponse> getTransaction(
    String digest, {
    TransactionIncludeOptions? include,
  }) {
    return core.getTransaction(digest, include: include);
  }

  Future<GrpcTransactionResponse> executeTransaction(
    Uint8List transactionBytes,
    List<String> signatures, {
    TransactionIncludeOptions? include,
  }) {
    return core.executeTransaction(transactionBytes, signatures, include: include);
  }

  Future<GrpcTransactionResponse> simulateTransaction(
    sui_dart.Transaction transactionBlock, {
    TransactionIncludeOptions? include,
    bool? doGasSelection,
  }) {
    return core.simulateTransaction(
      transactionBlock,
      include: include,
      doGasSelection: doGasSelection,
    );
  }

  Future<String> getReferenceGasPrice() {
    return core.getReferenceGasPrice();
  }

  Future<GrpcSystemState> getCurrentSystemState() {
    return core.getCurrentSystemState();
  }

  Future<GrpcPage<GrpcDynamicFieldEntry>> listDynamicFields(
    String parentId, {
    String? cursor,
    int? limit,
  }) {
    return core.listDynamicFields(parentId, cursor: cursor, limit: limit);
  }

  Future<GrpcVerifySignatureResult> verifyZkLoginSignature(
    Uint8List bytes,
    String signature, {
    String? address,
  }) {
    return core.verifyZkLoginSignature(bytes, signature, address: address);
  }

  Future<String?> defaultNameServiceName(String address) {
    return core.defaultNameServiceName(address);
  }

  Future<GrpcMoveFunction> getMoveFunction(
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
