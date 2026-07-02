import 'dart:typed_data';

import 'package:sui_dart/builder/transaction.dart';
import 'package:sui_dart/builder/tx_resolution_client.dart';
import 'package:sui_dart/grpc/client.dart';
import 'package:sui_dart/grpc/types.dart' as grpc;
import 'package:sui_dart/sui_account.dart';
import 'package:sui_dart/types/coins.dart';
import 'package:sui_dart/types/normalized.dart';
import 'package:sui_dart/types/objects.dart';
import 'package:sui_dart/types/transactions.dart';

/// [TxResolutionClient] over gRPC ([SuiGrpcClient]): converts gRPC responses
/// into the shapes the builder consumes, so transactions build over gRPC.
class GrpcResolutionClient implements TxResolutionClient {
  final SuiGrpcClient client;

  GrpcResolutionClient(this.client);

  @override
  Future<PaginatedCoins> getCoins(
    String owner, {
    String? coinType,
    String? cursor,
    int? limit,
  }) async {
    final page = await client.listCoins(
      owner,
      coinType: coinType ?? '0x2::sui::SUI',
      cursor: cursor,
      limit: limit,
    );
    final coins = page.data
        .map(
          (c) => CoinStruct(
            c.type,
            c.objectId,
            int.parse(c.version),
            c.digest,
            c.balance,
            '',
          ),
        )
        .toList();
    return PaginatedCoins(coins, page.nextCursor, page.hasNextPage);
  }

  @override
  Future<List<SuiObjectResponse>> multiGetObjects(
    List<String> objectIds, {
    SuiObjectDataOptions? options,
  }) async {
    final results = await client.getObjects(objectIds);
    return results.map((result) {
      switch (result) {
        case grpc.ObjectSuccess(:final data):
          return SuiObjectResponse.fromJson({
            'data': {
              'objectId': data.objectId,
              'version': data.version,
              'digest': data.digest,
              if (_ownerJson(data.owner) != null)
                'owner': _ownerJson(data.owner),
            },
          });
        case grpc.ObjectError(:final error):
          return SuiObjectResponse.fromJson({
            'error': {'code': 'displayError', 'error': error},
          });
      }
    }).toList();
  }

  @override
  Future<BigInt> getReferenceGasPrice() async {
    return BigInt.parse(await client.getReferenceGasPrice());
  }

  @override
  Future<DryRunTransactionBlockResponse> dryRunTransaction(
    Uint8List bytes, {
    String? signerAddress,
  }) async {
    // No bytes dry-run in gRPC: rebuild the tx and simulate (the node picks gas,
    // since the builder dry-runs with empty payment to estimate a budget).
    final tx = Transaction.fromBytes(bytes);
    final response = await client.simulateTransaction(
      tx,
      doGasSelection: true,
      include: const TransactionIncludeOptions(effects: true),
    );
    final effects = response.effects;
    final success = effects?.status?.success ?? response.status.success;
    final gas = effects?.gasUsed;

    return DryRunTransactionBlockResponse.fromJson({
      'effects': {
        'status': success
            ? {'status': 'success'}
            : {
                'status': 'failure',
                'error':
                    effects?.status?.error?.message ??
                    response.status.error?.message,
              },
        'gasUsed': {
          'computationCost': gas?.computationCost ?? '0',
          'storageCost': gas?.storageCost ?? '0',
          'storageRebate': gas?.storageRebate ?? '0',
          'nonRefundableStorageFee': gas?.nonRefundableStorageFee ?? '0',
        },
        'transactionDigest': effects?.transactionDigest ?? response.digest,
        // A placeholder gas object; the builder only reads status + gasUsed.
        'gasObject': {
          'owner': {'AddressOwner': '0x0'},
          'reference': {
            'objectId': '0x0',
            'version': '0',
            'digest': '11111111111111111111111111111111',
          },
        },
      },
    });
  }

  @override
  Future<SuiMoveNormalizedFunction> getNormalizedMoveFunction(
    String package,
    String module,
    String function,
  ) async {
    final fn = await client.getMoveFunction(package, module, function);
    return SuiMoveNormalizedFunction.fromJson({
      'visibility': fn.visibility,
      'isEntry': fn.isEntry,
      // The builder only reads `parameters`; keep the rest minimal.
      'typeParameters': const [],
      'parameters': fn.parameters.map(normalizedMoveTypeToJson).toList(),
      'return': fn.returnTypes.map(normalizedMoveTypeToJson).toList(),
    });
  }

  @override
  Future<dynamic> getProtocolConfig() async => null;
}

/// Builds, signs, and executes transactions entirely over gRPC.
extension SuiGrpcClientTransactions on SuiGrpcClient {
  /// Builds [tx] to BCS bytes, resolving coins/objects/gas over gRPC.
  Future<Uint8List> buildTransaction(Transaction tx, {String? sender}) {
    if (sender != null) tx.setSenderIfNotSet(sender);
    return tx.build(BuildOptions(resolutionClient: GrpcResolutionClient(this)));
  }

  /// Builds [tx] over gRPC, signs it with [account], and executes it over gRPC.
  Future<grpc.TransactionResponse> signAndExecuteTransaction(
    SuiAccount account,
    Transaction tx, {
    grpc.TransactionIncludeOptions? include,
  }) async {
    tx.setSenderIfNotSet(account.getAddress());
    final bytes = await buildTransaction(tx);
    final signed = account.keyPair.signTransactionBlock(bytes);
    return executeTransaction(bytes, [signed.signature], include: include);
  }
}

/// The builder only needs the shared-object initial version (to detect a shared
/// input); everything else resolves as an owned/immutable ref.
dynamic _ownerJson(grpc.Owner owner) {
  return switch (owner) {
    grpc.SharedOwner(:final initialSharedVersion) => {
      'Shared': {'initial_shared_version': int.parse(initialSharedVersion)},
    },
    grpc.AddressOwner(:final address) => {'AddressOwner': address},
    grpc.ObjectOwner(:final address) => {'ObjectOwner': address},
    grpc.ImmutableOwner() => 'Immutable',
    _ => null,
  };
}

/// Converts a gRPC [grpc.NormalizedMoveType] into the JSON-RPC
/// `SuiMoveNormalizedType` representation the builder's serializer expects.
/// Exposed for testing — both sides are structured, so this is a 1:1 recursion.
dynamic normalizedMoveTypeToJson(grpc.NormalizedMoveType type) {
  return switch (type) {
    grpc.MoveTypePrimitive(:final typeName) => typeName,
    grpc.MoveTypeVector(:final element) => {
      'Vector': element == null ? null : normalizedMoveTypeToJson(element),
    },
    grpc.MoveTypeStruct(
      :final address,
      :final module,
      :final name,
      :final typeArguments,
    ) =>
      {
        'Struct': {
          'address': address,
          'module': module,
          'name': name,
          'typeArguments': typeArguments.map(normalizedMoveTypeToJson).toList(),
        },
      },
    grpc.MoveTypeParameter(:final index) => {'TypeParameter': index},
    grpc.MoveTypeReference(:final body) => {
      'Reference': normalizedMoveTypeToJson(body),
    },
    grpc.MoveTypeMutableReference(:final body) => {
      'MutableReference': normalizedMoveTypeToJson(body),
    },
  };
}
