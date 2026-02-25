import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
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
import 'package:sui_dart/grpc/generated/sui/rpc/v2/subscription_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction_execution_service.pbgrpc.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction.pb.dart' as grpc_transaction;

import 'package:sui_dart/builder/transaction.dart' show chunk;
import 'package:sui_dart/types/common.dart';


class SuiGrpcClientOptions {
  final String baseUrl;
  final int port;
  final ClientChannel? customChannel;

  SuiGrpcClientOptions({required this.baseUrl, this.customChannel, required this.port});
}

class SuiGrpcClient {
  late final ClientChannel _channel;

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
  }

  Future<void> shutdown() async {
    await _channel.shutdown();
  }
}
