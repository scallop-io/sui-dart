import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:sui_dart/grpc/proto/sui/rpc/v2/argument.pb.dart';
import 'package:sui_dart/grpc/proto/sui/rpc/v2/input.pb.dart';
import 'package:sui_dart/grpc/proto/sui/rpc/v2/object_reference.pb.dart';
import 'package:sui_dart/sui.dart';
import 'package:sui_dart/grpc/proto/sui/rpc/v2/transaction.pb.dart' as GrpcTransaction;

Input callArgToGrpcInput(Map<String, dynamic> arg) {
  switch (arg['\$kind']) {
    case 'Pure':
      return Input(kind: Input_InputKind.PURE, pure: base64Decode(arg['Pure']['bytes']));
    case 'Object':
      final obj = arg['Object'];
      switch (obj['\$kind']) {
        case 'ImmOrOwnedObject':
          return Input(
            kind: Input_InputKind.IMMUTABLE_OR_OWNED,
            objectId: obj['ImmOrOwnedObject']['objectId'],
            version: Int64.parseRadix(obj['ImmOrOwnedObject']['version'], 10),
            digest: obj['ImmOrOwnedObject']['digest'],
          );

        case 'SharedObject':
          return Input(
            kind: Input_InputKind.SHARED,
            objectId: obj['SharedObject']['objectId'],
            version: Int64.parseRadix(obj['SharedObject']['initialSharedVersion'], 10),
            mutable: obj['SharedObject']['mutable'],
          );

        case 'Receiving':
          return Input(
            kind: Input_InputKind.RECEIVING,
            objectId: obj['Receiving']['objectId'],
            version: Int64.parseRadix(obj['Receiving']['version'], 10),
            digest: obj['Receiving']['digest'],
          );
      }
      throw Exception("Unknown object kind: $obj");

    case 'UnresolvedObject':
      final u = arg['UnresolvedObject'];
      return Input(
        objectId: u['objectId'],
        version: u['version'] != null
            ? Int64.parseRadix(u['version'], 10)
            : u['initialSharedVersion'] != null
            ? Int64.parseRadix(u['initialSharedVersion'], 10)
            : null,
        digest: u['digest'],
        mutable: u['mutable'],
      );
    case 'UnresolvedPure':
      throw Exception("UnresolvedPure must be resolved before converting to gRPC");
    default:
      throw Exception("Unknown CallArg: $arg");
  }
}

Argument argumentToGrpcArgument(Map<String, dynamic> arg) {
  if (arg['GasCoin'] != null) {
    return Argument()..kind = Argument_ArgumentKind.GAS;
  }
  if (arg['Input'] != null) {
    return Argument()
      ..kind = Argument_ArgumentKind.INPUT
      ..input = arg['Input'];
  }
  if (arg['Result'] != null) {
    return Argument()
      ..kind = Argument_ArgumentKind.RESULT
      ..result = arg['Result'];
  }
  if (arg['NestedResult'] != null) {
    return Argument()
      ..kind = Argument_ArgumentKind.RESULT
      ..result = arg['NestedResult'][0]
      ..subresult = arg['NestedResult'][1];
  }
  throw Exception("Unknown Argument: $arg");
}

GrpcTransaction.Command commandToGrpcCommand(Map<dynamic, dynamic> cmd) {
  switch (cmd['\$kind']) {
    case 'MoveCall':
      return GrpcTransaction.Command(
        moveCall: (GrpcTransaction.MoveCall(
          package: cmd['MoveCall']['package'],
          module: cmd['MoveCall']['module'],
          function: cmd['MoveCall']['function'],
          typeArguments: cmd['MoveCall']['typeArguments'],
          arguments: toIterableGrpcArguments(cmd['MoveCall']['arguments']),
        )),
      );

    case 'TransferObjects':
      return GrpcTransaction.Command(
        transferObjects: GrpcTransaction.TransferObjects(
          objects: toIterableGrpcArguments(cmd['TransferObjects']?['objects']),
          address: toIterableGrpcArguments([(cmd['TransferObjects']['address'])])[0],
        ),
      );

    case 'SplitCoins':
      return GrpcTransaction.Command(
        splitCoins: GrpcTransaction.SplitCoins(
          coin: toIterableGrpcArguments([cmd['SplitCoins']['coin']])[0],
          amounts: toIterableGrpcArguments(cmd['SplitCoins']['amounts']),
        ),
      );

    case 'MergeCoins':
      return GrpcTransaction.Command(
        mergeCoins: GrpcTransaction.MergeCoins(
          coin: toIterableGrpcArguments([cmd['MergeCoins']['destination']])[0],
          coinsToMerge: toIterableGrpcArguments(cmd['MergeCoins']['sources']),
        ),
      );

    case 'Publish':
      return GrpcTransaction.Command(
        publish: GrpcTransaction.Publish(
          modules: cmd['Publish']['modules']
              .map<Uint8List>((module) => base64Decode(module as String))
              .toList(),
          dependencies: List.from(cmd['Publish']['dependencies'] ?? []),
        ),
      );

    case 'MakeMoveVec':
      return GrpcTransaction.Command(
        makeMoveVector: (GrpcTransaction.MakeMoveVector(
          elementType: cmd['MakeMoveVec']['type'],
          elements: toIterableGrpcArguments(cmd['MakeMoveVec']['elements']),
        )),
      );

    case 'Upgrade':
      return GrpcTransaction.Command(
        upgrade: GrpcTransaction.Upgrade(
          // modules are base64-encoded strings in internal format
          modules: cmd['Upgrade']['modules']
              .map<Uint8List>((module) => base64Decode(module as String))
              .toList(),
          dependencies: List.from(cmd['Upgrade']['dependencies'] ?? []),
          package: cmd['Upgrade']['package'],
          ticket: toIterableGrpcArguments([cmd['Upgrade']['ticket']])[0],
        ),
      );

    default:
      throw Exception("Unknown Command kind: $cmd");
  }
}

GrpcTransaction.Transaction transactionDataToGrpcTransaction(TransactionData data) {
  final inputs = data.inputs?.map(callArgToGrpcInput).toList();

  final commands = data.commands?.map(commandToGrpcCommand).toList();

  final tx = GrpcTransaction.Transaction(
    version: 1,
    sender: data.sender,
    kind: GrpcTransaction.TransactionKind(
      kind: GrpcTransaction.TransactionKind_Kind.PROGRAMMABLE_TRANSACTION,
      programmableTransaction: (GrpcTransaction.ProgrammableTransaction()
        ..inputs.addAll(inputs ?? [])
        ..commands.addAll(commands ?? [])),
    ),
    gasPayment: GrpcTransaction.GasPayment(
      objects: data.gasData.payment
          ?.map(
            (ref) => ObjectReference()
              ..objectId = ref.objectId
              ..version = Int64.parseRadix(ref.version.toString(), 10)
              ..digest = ref.digest,
          )
          .toList(),
      owner: data.gasData.owner ?? data.sender,
      price: data.gasData.price != null
          ? Int64.parseRadix(data.gasData.price.toString(), 10)
          : null,
      budget: data.gasData.budget != null
          ? Int64.parseRadix(data.gasData.budget.toString(), 10)
          : null,
    ),
  );

  if (data.expiration != null) {
    if (data.expiration?.epoch == null) {
      tx.expiration = (GrpcTransaction.TransactionExpiration()
        ..kind = GrpcTransaction.TransactionExpiration_TransactionExpirationKind.NONE);
    } else {
      tx.expiration = (GrpcTransaction.TransactionExpiration()
        ..kind = GrpcTransaction.TransactionExpiration_TransactionExpirationKind.EPOCH
        ..epoch = Int64.parseRadix(data.expiration!.epoch.toString(), 10));
    }
  }

  return tx;
}

List<Argument> toIterableGrpcArguments(List? args) {
  return (args ?? [])
      .map((e) {
        if (e is TransactionResult) {
          return e.toJson();
        }
        return e;
      })
      .cast<Map<String, dynamic>>()
      .map(argumentToGrpcArgument)
      .toList();
}

// void applyGrpcResolvedTransaction(
//   TransactionBlockDataBuilder builder,
//   GrpcTransaction.Transaction resolved, {
//   bool onlyTransactionKind = false,
// }) {
//   final resolvedBuilder = TransactionBlockDataBuilder.fromBytes(resolved.bcs.value as Uint8List);
//   final snapshot = resolvedBuilder.snapshot();

//   if (onlyTransactionKind) {
//     builder.applyResolvedData(
//       snapshot.copyWith(
//         gasData: GasData(budget: null, owner: null, payment: null, price: null),
//         expiration: null,
//       ),
//     );
//   } else {
//     builder.applyResolvedData(snapshot);
//   }
// }

// List<Map<String, String>> grpcObjectReferencesToBcs(List<ObjectReference> refs) {
//   return refs
//       .map(
//         (ref) => {
//           'objectId': ref.objectId,
//           'version': ref.version.toString(),
//           'digest': ref.digest,
//         },
//       )
//       .toList();
// }
