// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sui_dart/bcs/sui_bcs.dart';
import 'package:sui_dart/builder/commands.dart';
import 'package:sui_dart/builder/inputs.dart';
import 'package:sui_dart/builder/pure.dart';
import 'package:sui_dart/builder/serializer.dart';
import 'package:sui_dart/builder/transaction_block_data.dart';
import 'package:sui_dart/builder/transaction_resolver.dart';
import 'package:sui_dart/builder/v1.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/sui_client.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/types/framework.dart';
import 'package:sui_dart/types/normalized.dart';
import 'package:sui_dart/types/objects.dart';
import 'package:sui_dart/types/sui_bcs.dart';
import 'package:sui_dart/types/transactions.dart';
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction.pb.dart'
    as grpc_transaction;

/// An async resolver for a named `$Intent` command. It may inspect and mutate
/// [transactionData] (e.g. via `replaceCommand`) and must call [next] to run the
/// rest of the resolver chain.
typedef IntentResolver =
    Future<void> Function(
      TransactionBlockDataBuilder transactionData,
      BuildOptions options,
      Future<void> Function() next,
    );

class TransactionResult {
  final int index;

  TransactionResult(this.index);

  Map<String, dynamic> get result => {"\$kind": 'Result', "Result": index};
  final Map<String, dynamic> _nestedResult = <String, dynamic>{};

  Map<String, dynamic> nestedResult(dynamic subIndex) {
    final result = {
      "\$kind": 'NestedResult',
      "NestedResult": [index, subIndex],
    };
    _nestedResult.addAll(result);
    return result;
  }

  dynamic operator [](dynamic indexKey) {
    if (result.containsKey(indexKey)) {
      return result[indexKey];
    }

    final subIndex = int.tryParse(indexKey.toString());
    if (subIndex == null) return null;
    if (subIndex < 0) {
      throw ArgumentError("Invalid index key $indexKey");
    }
    return nestedResult(subIndex);
  }

  bool containsKey(String key) {
    return result.containsKey(key);
  }

  Map<String, dynamic> toJson() {
    return _nestedResult.isNotEmpty ? _nestedResult : result;
  }
}

const DefaultOfflineLimits = {
  "maxPureArgumentSize": 16 * 1024,
  "maxTxGas": 50000000000,
  "maxGasObjects": 256,
  "maxTxSizeBytes": 128 * 1024,
};

SuiClient expectClient(BuildOptions options) {
  if (options.client == null) {
    throw ArgumentError(
      "No provider passed to Transaction#build, but transaction data was not sufficient to build offline.",
    );
  }

  return options.client!;
}

const LIMITS = {
  // The maximum gas that is allowed.
  "maxTxGas": 'max_tx_gas',
  // The maximum number of gas objects that can be selected for one transaction.
  "maxGasObjects": 'max_gas_payment_objects',
  // The maximum size (in bytes) that the transaction can be:
  "maxTxSizeBytes": 'max_tx_size_bytes',
  // The maximum size (in bytes) that pure arguments can be:
  "maxPureArgumentSize": 'max_pure_argument_size',
};

typedef Limits = dynamic;

// An amount of gas (in gas units) that is added to transactions as an overhead to ensure transactions do not fail.
final GAS_SAFE_OVERHEAD = BigInt.from(1000);

// The maximum objects that can be fetched at once using multiGetObjects.
const MAX_OBJECTS_PER_FETCH = 50;

List<List<T>> chunk<T>(List<T> arr, int size) {
  int length = (arr.length / size).ceil();

  return List<List<T>>.generate(length, (int i) {
    return arr.sublist(
      i * size,
      (i * size + size > arr.length) ? arr.length : i * size + size,
    );
  });
}

class BuildOptions {
  SuiClient? client;
  bool onlyTransactionKind;

  /// Define a protocol config to build against, instead of having it fetched from the provider at build time.
  dynamic protocolConfig;

  /// Define limits that are used when building the transaction. In general, we recommend using the protocol configuration instead of defining limits.
  Limits? limits;

  BuildOptions({
    this.client,
    this.onlyTransactionKind = false,
    this.protocolConfig,
    this.limits,
  });
}

class SerializeTransactionOptions extends BuildOptions {
  List<String>? supportedIntents;

  SerializeTransactionOptions({
    this.supportedIntents,
    super.client,
    super.onlyTransactionKind,
    super.protocolConfig,
    super.limits,
  });
}

class SignOptions extends BuildOptions {
  Keypair signer;

  SignOptions({
    required this.signer,
    super.client,
    super.onlyTransactionKind,
    super.protocolConfig,
    super.limits,
  });
}

class Transaction {
  late TransactionBlockDataBuilder _blockData;

  /// Builds a `Transaction` from a serialized transaction kind (byte array or base64).
  static Transaction fromKind(dynamic serialized) {
    final tx = Transaction();

    tx._blockData = TransactionBlockDataBuilder.fromKindBytes(
      serialized is String ? fromB64(serialized) : serialized,
    );

    return tx;
  }

  /// Builds a `Transaction` from a serialized format: either a `Transaction_serialize`
  /// string, or base64-encoded BCS transaction data.
  static Transaction from(String serialized) {
    final tx = Transaction();
    final trimmed = serialized.trim();
    if (trimmed.startsWith('{')) {
      tx._blockData = TransactionBlockDataBuilder.restore(jsonDecode(trimmed));
    } else {
      // base64-encoded BCS transaction data
      tx._blockData = TransactionBlockDataBuilder.fromBytes(fromB64(trimmed));
    }
    return tx;
  }

  static Transaction fromBytes(Uint8List bytes) {
    final tx = Transaction();
    tx._blockData = TransactionBlockDataBuilder.fromBytes(bytes);
    return tx;
  }

  void setSender(String sender) {
    _blockData.sender = sender;
  }

  /// Sets the sender only if not already set. Useful for sponsored transactions.
  void setSenderIfNotSet(String sender) {
    _blockData.sender ??= sender;
  }

  void setExpiration(int? epoch) {
    _blockData.expiration = TransactionExpiration(epoch: epoch);
  }

  void setGasPrice(BigInt price) {
    _blockData.gasData.price = price;
  }

  void setGasBudget(BigInt budget) {
    _blockData.gasData.budget = budget;
  }

  void setGasOwner(String owner) {
    _blockData.gasData.owner = owner;
  }

  void setGasPayment(List<SuiObjectRef> payments) {
    _blockData.gasData.payment = payments
        .map((p) => SuiObjectRef(p.digest, p.objectId, p.version))
        .toList();
  }

  @Deprecated('Use getData() instead')
  TransactionDataV1 get blockData {
    return serializeV1TransactionData(_blockData.snapshot());
  }

  TransactionData getData() {
    return _blockData.snapshot();
  }

  grpc_transaction.Transaction toGrpcTransaction() {
    return transactionDataToGrpcTransaction(_blockData.snapshot());
  }

  Pure? _pure;

  Pure get pure {
    _pure ??= createPure((dynamic value) {
      if (value is SerializedBcs) {
        return _blockData.addInput('pure', {
          '\$kind': 'Pure',
          'Pure': {'bytes': value.toBase64()},
        });
      }

      if (value is Map && (value['Object'] != null || value['Pure'] != null)) {
        return _blockData.addInput('pure', value['Object'] ?? value['Pure']);
      } else if (value is Uint8List) {
        return _blockData.addInput('pure', Inputs.pure(value));
      } else {
        return _blockData.addInput('pure', {
          '\$kind': 'UnresolvedPure',
          'UnresolvedPure': {'value': value},
        });
      }
    });
    return _pure!;
  }

  Transaction([Transaction? transaction]) {
    _blockData = TransactionBlockDataBuilder(transaction?.getData());
  }

  /// Returns an argument for the gas coin, to be used in a transaction.
  Map<String, dynamic> get gas {
    return {"\$kind": 'GasCoin', "GasCoin": true};
  }

  Map<String, dynamic> object(dynamic value) {
    if (value is Function) {
      return object(value(this));
    }

    // An argument produced by `add()` (e.g. a `coinWithBalance` result).
    if (value is TransactionResult) {
      return value.toJson();
    }

    if (value is Map && value['\$kind'] != null) {
      final kind = value['\$kind'];
      if (kind == 'GasCoin' ||
          kind == 'Input' ||
          kind == 'Result' ||
          kind == 'NestedResult') {
        return value as Map<String, dynamic>;
      }
    }

    final id = getIdFromCallArg(value);

    final inserted = _blockData.inputs.firstWhere(
      (i) => id == getIdFromCallArg(i),
      orElse: () => <String, dynamic>{},
    );

    // Upgrade shared object inputs to mutable if needed:
    if (inserted.isNotEmpty &&
        inserted['Object']?['SharedObject'] != null &&
        value is Map<String, dynamic> &&
        value['Object']?['SharedObject'] != null) {
      inserted['Object']['SharedObject']['mutable'] =
          inserted['Object']['SharedObject']['mutable'] ||
          value['Object']['SharedObject']['mutable'];
    }

    if (inserted.isNotEmpty) {
      return {
        '\$kind': 'Input',
        'Input': _blockData.inputs.indexOf(inserted),
        'type': 'object',
      };
    } else {
      return _blockData.addInput(
        'object',
        value is String
            ? {
                '\$kind': 'UnresolvedObject',
                'UnresolvedObject': {'objectId': normalizeSuiAddress(value)},
              }
            : value,
      );
    }
  }

  Map<String, dynamic> objectId(String value) {
    return object(value);
  }

  /// Adds an object input from a fully-resolved object reference (use `object(id)` for an ID).
  Map<String, dynamic> objectRef(SuiObjectRef args) {
    return object(Inputs.objectRef(args));
  }

  /// Adds a shared object input from a resolved shared object reference (use `object(id)` for an ID).
  Map<String, dynamic> sharedObjectRef(SharedObjectRef args) {
    return object(Inputs.sharedObjectRef(args));
  }

  /// Adds a receiving object input from a fully-resolved object reference.
  Map<String, dynamic> receivingRef(SuiObjectRef args) {
    return object(Inputs.receivingRef(args));
  }

  Map<String, dynamic> pureInt(int value, [String type = LegacyBCS.U64]) {
    return pure.u64(BigInt.from(value));
  }

  Map<String, dynamic> pureBool(bool value) {
    return pure.boolean(value);
  }

  Map<String, dynamic> pureAddress(String address) {
    return pure.address(address);
  }

  Map<String, dynamic> pureString(String str) {
    return pure.string(str);
  }

  Map<String, dynamic> pureVector(
    List<dynamic> value, [
    String type = LegacyBCS.U64,
  ]) {
    return pure.vector(type, value);
  }

  TransactionResult add(dynamic transaction) {
    // Intent helpers (e.g. `coinWithBalance`) are passed as a function of the
    // transaction; invoke them so they can register resolvers and add commands.
    if (transaction is Function) {
      return transaction(this);
    }
    _blockData.commands.add(transaction);
    return TransactionResult(_blockData.commands.length - 1);
  }

  final Map<String, IntentResolver> _intentResolvers = {};

  /// Registers an async resolver for a named intent (`$Intent` command). The
  /// resolver runs during [build], replacing its intent commands with concrete
  /// ones. Registering the same intent twice with a different resolver throws.
  void addIntentResolver(String intent, IntentResolver resolver) {
    if (_intentResolvers.containsKey(intent) &&
        _intentResolvers[intent] != resolver) {
      throw ArgumentError('Intent $intent already has a conflicting resolver');
    }
    _intentResolvers[intent] = resolver;
  }

  /// Runs the resolver for every intent present in the commands (skipping any in
  /// [supportedIntents]), as a middleware chain. Throws if a present intent has
  /// no registered resolver.
  Future<void> _resolveIntents(
    BuildOptions options, {
    List<String>? supportedIntents,
  }) async {
    final present = <String>{};
    for (final command in _blockData.commands) {
      if (command['\$kind'] == '\$Intent') {
        present.add(command['\$Intent']['name']);
      }
    }

    final steps = <IntentResolver>[];
    for (final name in present) {
      if (supportedIntents != null && supportedIntents.contains(name)) continue;
      final resolver = _intentResolvers[name];
      if (resolver == null) {
        throw ArgumentError('Missing intent resolver for $name');
      }
      steps.add(resolver);
    }

    Future<void> run(int i) async {
      if (i >= steps.length) return;
      await steps[i](_blockData, options, () => run(i + 1));
    }

    await run(0);
  }

  /// Resolves intents so the transaction can be serialized to JSON, without
  /// requiring gas/sender/object versions (unlike [build]). Intents named in
  /// [SerializeTransactionOptions.supportedIntents] are left for the recipient.
  Future<void> prepareForSerialization([SerializeTransactionOptions? options]) {
    options ??= SerializeTransactionOptions();
    return _resolveIntents(options, supportedIntents: options.supportedIntents);
  }

  /// Whether the transaction has no unresolved `$Intent` commands (other than
  /// those in [supportedIntents]) — i.e. it can be serialized to JSON as-is.
  bool isPreparedForSerialization({List<String>? supportedIntents}) {
    return !_blockData.commands.any(
      (command) =>
          command['\$kind'] == '\$Intent' &&
          !(supportedIntents?.contains(command['\$Intent']['name']) ?? false),
    );
  }

  /// Resolves intents and serializes the transaction to a JSON string. Use this
  /// instead of the synchronous [toJson] when the transaction contains intents
  /// (e.g. `coinWithBalance`).
  Future<String> toJsonAsync([SerializeTransactionOptions? options]) async {
    await prepareForSerialization(options);
    return jsonEncode(
      _blockData.snapshot().toJson(),
      toEncodable: (v) => v is BigInt ? v.toString() : v,
    );
  }

  // Method shorthands:

  TransactionResult splitCoins(dynamic coin, List<dynamic> amounts) {
    final coinArg = coin is String ? object(coin) : coin;
    final result = amounts
        .map((x) => x is! Map ? pure.u64(BigInt.parse(x.toString())) : x)
        .toList();
    return add(Commands.splitCoins(coinArg, result));
  }

  TransactionResult mergeCoins(dynamic destination, List<dynamic> sources) {
    return add(
      Commands.mergeCoins(
        object(destination),
        sources.map((src) => object(src)).toList(),
      ),
    );
  }

  TransactionResult publish(List<dynamic> modules, List<String> dependencies) {
    return add(Commands.publish(modules: modules, dependencies: dependencies));
  }

  TransactionResult upgrade({
    required List<dynamic> modules,
    required List<String> dependencies,
    required String packageId,
    required dynamic ticket,
  }) {
    return add(
      Commands.upgrade(
        modules: modules,
        dependencies: dependencies,
        package: packageId,
        ticket: ticket,
      ),
    );
  }

  TransactionResult moveCall(
    String target, {
    List? typeArguments,
    List? arguments,
  }) {
    return add(
      Commands.moveCall({
        "target": target,
        "typeArguments": typeArguments,
        "arguments": arguments,
      }),
    );
  }

  TransactionResult transferObjects(List<dynamic> objects, dynamic address) {
    final result = address is! Map ? pure.address(address) : address;
    return add(
      Commands.transferObjects(
        objects.map((obj) => object(obj)).toList(),
        result,
      ),
    );
  }

  TransactionResult makeMoveVec({required dynamic objects, String? type}) {
    final elements = (objects as List).map((obj) => object(obj)).toList();
    return add(Commands.makeMoveVec(elements: elements, type: type));
  }

  /// Serializes to a JSON string (not BCS bytes), so an incomplete transaction
  /// can be passed around and finished elsewhere.
  @Deprecated('Use toJson() instead')
  String serialize() {
    return jsonEncode(serializeV1TransactionData(_blockData.snapshot()));
  }

  String toJson([SerializeTransactionOptions? options]) {
    return jsonEncode(_blockData.snapshot());
  }

  String _getConfig(String key, BuildOptions options) {
    if (options.limits != null && options.limits[key] is int) {
      return options.limits[key]!.toString();
    }

    if (options.protocolConfig == null) {
      return DefaultOfflineLimits[key].toString();
    }

    final attribute = options.protocolConfig?["attributes"][LIMITS[key]];
    if (attribute == null) {
      throw ArgumentError('Missing expected protocol config: "${LIMITS[key]}"');
    }

    final value = attribute["u64"] ?? (attribute["u32"] ?? attribute["f64"]);
    if (value == null) {
      throw ArgumentError(
        'Unexpected protocol config value found for: "${LIMITS[key]}"',
      );
    }

    return value.toString();
  }

  /// Build the transaction to BCS bytes, and sign it with the provided keypair.
  Future<SignatureWithBytes> sign(SignOptions options) async {
    final bytes = await build(options);
    return options.signer.signTransactionBlock(bytes);
  }

  /// Build the transaction to BCS bytes.
  Future<Uint8List> build([BuildOptions? options]) async {
    options ??= BuildOptions();
    await _prepare(options);
    return _blockData.build(onlyTransactionKind: options.onlyTransactionKind);
  }

  /// Derive transaction digest
  Future<String> getDigest(BuildOptions options) async {
    await _prepare(options);
    return _blockData.getDigest();
  }

  void _validate(BuildOptions options) {
    final maxPureArgumentSize = int.parse(
      _getConfig('maxPureArgumentSize', options),
    );
    for (var i = 0; i < _blockData.inputs.length; i++) {
      final input = _blockData.inputs[i];
      if (input["value"] is Map && input["value"].containsKey("Pure")) {
        if (input["value"]["Pure"].length > maxPureArgumentSize) {
          throw ArgumentError(
            "Input at index $i is too large, max pure input size is $maxPureArgumentSize bytes, got ${input["value"]["Pure"].length} bytes",
          );
        }
      }
    }
  }

  void normalizeRawArgument(dynamic arg, BcsType schema) {
    if (arg is! Map) {
      return;
    }
    if (arg["Input"] == null) {
      return;
    }
    final input = _blockData.inputs[arg["Input"]];

    if (input["UnresolvedPure"] == null) {
      return;
    }

    _blockData.inputs[arg["Input"]] = Inputs.pure(
      schema.serialize(input["UnresolvedPure"]["value"]),
    );
  }

  Future<void> resolveObjectReferences(BuildOptions options) async {
    // Unresolved object inputs (kept by-reference to avoid re-resolving).
    final objectsToResolve = _blockData.inputs.where((input) {
      return (input["UnresolvedObject"] != null &&
          (input["UnresolvedObject"]["version"] == null &&
              input["UnresolvedObject"]["initialSharedVersion"] == null));
    });

    final dedupedIds = Set.from(
      objectsToResolve.map(
        (input) => normalizeSuiObjectId(input["UnresolvedObject"]["objectId"]),
      ),
    ).toList();

    final objectChunks = dedupedIds.isNotEmpty
        ? chunk(dedupedIds, MAX_OBJECTS_PER_FETCH)
        : [];

    final resolved = <SuiObjectResponse>[];
    final objectsResult = (await Future.wait(
      objectChunks.map(
        (chunk) => expectClient(options).multiGetObjects(
          chunk.cast<String>(),
          options: SuiObjectDataOptions(showOwner: true),
        ),
      ),
    ));
    for (var item in objectsResult) {
      resolved.addAll(item);
    }

    final responsesById = Map.fromIterables(
      dedupedIds,
      dedupedIds
          .asMap()
          .map((index, id) => MapEntry(index, resolved[index]))
          .values,
    );

    final invalidObjects = responsesById.entries
        .where((entry) => entry.value.error != null)
        .map((entry) => entry.value.error?.toJson())
        .toList();

    if (invalidObjects.isNotEmpty) {
      throw ArgumentError(
        "The following input objects are invalid: ${invalidObjects.join(', ')}",
      );
    }

    final objects = resolved.map((object) {
      if (object.error != null || object.data == null) {
        throw ArgumentError("Failed to fetch object: ${object.error}");
      }
      final owner = object.data?.owner;
      final initialSharedVersion = owner?.shared?.initialSharedVersion;

      return {
        "objectId": object.data?.objectId,
        "digest": object.data?.digest,
        "version": object.data?.version,
        "initialSharedVersion": initialSharedVersion,
      };
    }).toList();

    final objectsById = Map.fromIterables(
      dedupedIds,
      dedupedIds
          .asMap()
          .map((index, id) => MapEntry(index, objects[index]))
          .values,
    );

    for (int index = 0; index < _blockData.inputs.length; index++) {
      final input = _blockData.inputs[index];
      if (input["UnresolvedObject"] == null) {
        continue;
      }

      CallArg updated;
      final id = normalizeSuiAddress(input["UnresolvedObject"]["objectId"]);
      final object = objectsById[id];

      if ((input["UnresolvedObject"]?["initialSharedVersion"] ??
              object?["initialSharedVersion"]) !=
          null) {
        updated = Inputs.sharedObjectRef({
          "objectId": id,
          "initialSharedVersion":
              input["UnresolvedObject"]["initialSharedVersion"] ??
              object?["initialSharedVersion"],
          "mutable":
              (input["UnresolvedObject"]?["mutable"] ?? false) ||
              isUsedAsMutable(_blockData, index),
        });
      } else if (isUsedAsReceiving(_blockData, index)) {
        updated = Inputs.receivingRef(
          SuiObjectRef(
            input["UnresolvedObject"]["digest"] ?? object?["digest"],
            id,
            input["UnresolvedObject"]["version"] ?? object?["version"],
          ),
        );
      }

      _blockData.inputs[_blockData.inputs.indexOf(input)] =
          updated ??
          Inputs.objectRef(
            SuiObjectRef(
              input["UnresolvedObject"]["digest"] ?? object?["digest"],
              id,
              input["UnresolvedObject"]["version"] ?? object?["version"],
            ),
          );
    }
  }

  Future<void> normalizeInputs(BuildOptions options) async {
    final inputs = _blockData.inputs;
    final commands = _blockData.commands;
    final moveCallsToResolve = [];
    final moveFunctionsToResolve = <String>{};

    for (var command in commands) {
      if (command["MoveCall"] != null) {
        // Args needing encoding require the normalized move module; skip if types are known.
        if (command["MoveCall"]?["_argumentTypes"] != null) {
          continue;
        }

        final inputs = (command["MoveCall"]["arguments"] as Iterable).map((
          arg,
        ) {
          if (arg is Map && arg["Input"] != null) {
            return _blockData.inputs[arg["Input"]];
          }
          return null;
        }).toList();
        final needsResolution = inputs.firstWhere(
          (input) =>
              input?["UnresolvedPure"] != null ||
              input?["UnresolvedObject"] != null,
          orElse: () => null,
        );

        if (needsResolution != null) {
          final functionName =
              "${command["MoveCall"]["package"]}::${command["MoveCall"]["module"]}::${command["MoveCall"]["function"]}";
          moveFunctionsToResolve.add(functionName);
          moveCallsToResolve.add(command["MoveCall"]);
        }
      }

      // Legacy wellKnownEncoding values (data hydrated from an old SDK version).
      if (command["SplitCoins"] != null) {
        command["SplitCoins"]["amounts"].forEach((amount) {
          normalizeRawArgument(amount, SuiBcs.U64);
        });
      } else if (command["TransferObjects"] != null) {
        normalizeRawArgument(
          command["TransferObjects"]["address"],
          SuiBcs.Address,
        );
      }
    }

    final moveFunctionParameters = <String, List<dynamic>>{};
    if (moveFunctionsToResolve.isNotEmpty) {
      final client = expectClient(options);
      await Future.wait(
        [...moveFunctionsToResolve].map((functionName) async {
          final [packageId, moduleId, functionId] = functionName.split('::');
          final def = await client.getNormalizedMoveFunction(
            packageId,
            moduleId,
            functionId,
          );

          moveFunctionParameters[functionName] = def.parameters
              .map((param) => normalizedTypeToMoveTypeSignature(param))
              .toList();
        }),
      );
    }

    if (moveCallsToResolve.isNotEmpty) {
      for (var moveCall in moveCallsToResolve) {
        final parameters =
            moveFunctionParameters["${moveCall["package"]}::${moveCall["module"]}::${moveCall["function"]}"];
        if (parameters != null && parameters.isNotEmpty) {
          // Entry functions may take a trailing &mut TxContext that the caller omits.
          final hasTxContext = isTxContext(parameters.last!);
          final params = hasTxContext
              ? parameters.sublist(0, parameters.length - 1)
              : parameters;

          moveCall["_argumentTypes"] = params;
        }
      }
    }

    for (var command in commands) {
      if (command["MoveCall"] == null) {
        continue;
      }

      final moveCall = command["MoveCall"];
      final fnName =
          "${moveCall["package"]}::${moveCall["module"]}::${moveCall["function"]}";
      final params = moveCall["_argumentTypes"];

      if (params == null) {
        continue;
      }

      if (params.length != command["MoveCall"]["arguments"].length) {
        throw ArgumentError("Incorrect number of arguments for $fnName");
      }

      final callArgs = moveCall["arguments"].toList();
      for (var i = 0; i < params.length; i++) {
        final param = params[i];
        final arg = callArgs[i];
        if (arg["Input"] == null) continue;
        final input = inputs[arg["Input"]];

        // Skip already-resolved inputs.
        if (input["UnresolvedPure"] == null &&
            input["UnresolvedObject"] == null) {
          continue;
        }

        final inputValue =
            input["UnresolvedPure"]?["value"] ??
            input["UnresolvedObject"]?["objectId"];

        final schema = getPureBcsSchema(param["body"]);
        if (schema != null) {
          arg["type"] = 'pure';
          inputs[inputs.indexOf(input)] = Inputs.pure(
            schema.serialize(inputValue),
          );
          continue;
        }

        if (inputValue is! String) {
          throw ArgumentError(
            "Expect the argument to be an object id string, got $inputValue",
          );
        }

        arg["type"] = 'object';
        final unresolvedObject = input["UnresolvedPure"] != null
            ? {
                "UnresolvedObject": {"objectId": inputValue},
              }
            : input;

        inputs[arg["Input"]] = unresolvedObject;
      }
    }
  }

  Future<void> _prepareGasPayment(BuildOptions options) async {
    if (_blockData.gasData.payment != null) {
      final maxGasObjects = int.parse(_getConfig('maxGasObjects', options));
      if (_blockData.gasData.payment!.length > maxGasObjects) {
        throw ArgumentError(
          "Payment objects exceed maximum amount: $maxGasObjects",
        );
      }
    }

    if ((options.onlyTransactionKind) || _blockData.gasData.payment != null) {
      return;
    }

    final gasOwner = _blockData.gasData.owner ?? _blockData.sender;

    final coins = await expectClient(
      options,
    ).getCoins(gasOwner!, coinType: SUI_TYPE_ARG);

    final paymentCoins = coins.data
        // Exclude coins already used as input.
        .where((coin) {
          final matchingInput = _blockData.inputs.indexWhere((input) {
            if (input["Object"]?["ImmOrOwnedObject"] != null) {
              return coin.coinObjectId ==
                  input["Object"]["ImmOrOwnedObject"]["objectId"];
            }

            return false;
          });

          return matchingInput == -1;
        })
        .toList();

    int end = min(
      paymentCoins.length,
      int.parse(_getConfig('maxGasObjects', options)) - 1,
    );

    final usePaymentCoins = paymentCoins
        .sublist(0, end)
        .map(
          (coin) => SuiObjectRef(coin.digest, coin.coinObjectId, coin.version),
        )
        .toList();

    if (paymentCoins.isEmpty) {
      throw ArgumentError('No valid gas coins found for the transaction.');
    }

    setGasPayment(usePaymentCoins);
  }

  Future<void> _prepareGasPrice(BuildOptions options) async {
    if (options.onlyTransactionKind || _blockData.gasData.price != null) {
      return;
    }

    final gasPrice = await expectClient(options).getReferenceGasPrice();
    setGasPrice(gasPrice);
  }

  bool isBuilderCallArg(dynamic arg) {
    if (arg is! Map) return false;
    return arg.containsKey("Pure") || arg.containsKey("Object");
  }

  Future<void> _prepareTransactions(BuildOptions options) async {
    final inputs = _blockData.inputs;
    final transactions = _blockData.commands;

    final moveModulesToResolve = [];

    // Unresolved object inputs (kept by-reference to avoid re-resolving).
    final objectsToResolve = [];

    for (var input in inputs) {
      if (input['type'] == 'object' && input['value'] is String) {
        // String input to resolve into an object reference.
        objectsToResolve.add({
          "id": normalizeSuiAddress(input['value']),
          "input": input,
        });
        continue;
      }
    }

    for (var transaction in transactions) {
      if (transaction["kind"] == "MoveCall") {
        bool needsResolution = (transaction["arguments"] as List).any(
          (arg) =>
              arg is Map &&
              arg['kind'] == 'Input' &&
              !(isBuilderCallArg(inputs[arg['index']]["value"])),
        );
        if (needsResolution) {
          moveModulesToResolve.add(transaction);
        }
      }

      // Legacy wellKnownEncoding values (data hydrated from an old SDK version).
      if (transaction["kind"] == 'SplitCoins') {
        for (var amount in (transaction["amounts"] as List)) {
          if (amount["kind"] == 'Input') {
            final input = inputs[amount['index']];
            if (input["value"] is! Map) {
              input['value'] = Inputs.pure(input['value'], LegacyBCS.U64);
            }
          }
        }
      }

      if (transaction["kind"] == 'TransferObjects') {
        if (transaction['address']['kind'] == 'Input') {
          final input = inputs[transaction['address']['index']];
          if (input["value"] is! Map) {
            input['value'] = Inputs.pure(input['value'], LegacyBCS.ADDRESS);
          }
        }
      }
    }

    if (moveModulesToResolve.isNotEmpty) {
      final resolveResults = await Future.wait(
        moveModulesToResolve.map((moveCall) async {
          final target = moveCall["target"].split('::');
          final packageId = target[0];
          final moduleName = target[1];
          final functionName = target[2];

          final normalized = await expectClient(options)
              .getNormalizedMoveFunction(
                normalizeSuiObjectId(packageId),
                moduleName,
                functionName,
              );

          // Entry functions may take a trailing &mut TxContext that the caller omits.
          final hasTxContext =
              normalized.parameters.isNotEmpty &&
              isTxContext(normalized.parameters.last);

          final params = hasTxContext
              ? normalized.parameters.sublist(
                  0,
                  normalized.parameters.length - 1,
                )
              : normalized.parameters;

          final callArgs = moveCall["arguments"].toList();
          if (params.length != callArgs.length) {
            throw ArgumentError('Incorrect number of arguments.');
          }

          final localObjectsToResolve = [];

          for (int i = 0; i < params.length; i++) {
            final param = params[i];
            final arg = callArgs[i];
            if (arg["kind"] != 'Input') continue;
            final input = inputs[arg["index"]];
            // Skip already-resolved inputs.
            if (isBuilderCallArg(input["value"])) continue;

            final inputValue = input["value"];

            final serType = getPureSerializationType(param, inputValue);

            if (serType != null) {
              input["value"] = Inputs.pure(inputValue, serType);
              continue;
            }

            final structVal = extractStructTag(param);
            if (structVal != null ||
                (param is Map && param["TypeParameter"] != null)) {
              if (inputValue is! String) {
                throw ArgumentError(
                  "Expect the argument to be an object id string, got ${jsonEncode(inputValue)}",
                );
              }
              localObjectsToResolve.add({
                "id": inputValue,
                "input": input,
                "normalizedType": param,
              });
            } else {
              throw ArgumentError(
                "Unknown call arg type ${jsonEncode(param)} for value ${jsonEncode(inputValue)}",
              );
            }
          }

          return localObjectsToResolve;
        }),
      );

      for (var result in resolveResults) {
        objectsToResolve.addAll(result);
      }
    }

    if (objectsToResolve.isNotEmpty) {
      final dedupedIds = Set<String>.from(
        objectsToResolve.map((o) => o["id"]),
      ).toList();
      final objectChunks = chunk(dedupedIds, MAX_OBJECTS_PER_FETCH);
      final objects = (await Future.wait(
        objectChunks.map(
          (chunk) => expectClient(options).multiGetObjects(
            chunk,
            options: SuiObjectDataOptions(showOwner: true),
          ),
        ),
      )).expand((element) => element).toList();

      final objectsById = <String, SuiObjectResponse>{};
      for (int index = 0; index < dedupedIds.length; index++) {
        objectsById[dedupedIds[index]] = objects[index];
      }

      final invalidObjects = objectsById.entries
          .where((entry) => entry.value.error != null)
          .map((entry) => entry.key)
          .toList();
      if (invalidObjects.isNotEmpty) {
        throw ArgumentError(
          "The following input objects are invalid: ${invalidObjects.join(', ')}",
        );
      }

      for (var item in objectsToResolve) {
        final id = item["id"];
        final input = item["input"];
        final normalizedType = item["normalizedType"];

        final object = objectsById[id];
        final owner = object?.data?.owner;
        final initialSharedVersion = owner?.shared?.initialSharedVersion;

        if (initialSharedVersion != null) {
          // Mark shared input mutable if any referencing command needs it mutable.
          final isByValue =
              normalizedType != null &&
              extractMutableReference(normalizedType) == null &&
              extractReference(normalizedType) == null;
          final mutable =
              isMutableSharedObjectInput(input["value"]) ||
              isByValue ||
              (normalizedType != null &&
                  extractMutableReference(normalizedType) != null);

          input["value"] = Inputs.sharedObjectRef({
            "objectId": id,
            "initialSharedVersion": initialSharedVersion,
            "mutable": mutable,
          });
        } else if (normalizedType != null && isReceivingType(normalizedType)) {
          input["value"] = Inputs.receivingRef(getObjectReference(object!)!);
        } else {
          input["value"] = Inputs.objectRef(getObjectReference(object!)!);
        }
      }
    }
  }

  /// Validates the transaction data and resolves all inputs so it can be built into bytes.
  Future<void> _prepare(BuildOptions options) async {
    if (!options.onlyTransactionKind && _blockData.sender == null) {
      throw ArgumentError('Missing transaction sender');
    }

    final client = options.client;

    if (options.protocolConfig == null &&
        options.limits == null &&
        client != null) {
      options.protocolConfig = await client.getProtocolConfig();
    }

    await _resolveIntents(options);

    await normalizeInputs(options);
    await resolveObjectReferences(options);

    await Future.wait([
      _prepareGasPrice(options),
      _prepareTransactions(options),
    ]);

    if (options.onlyTransactionKind != true) {
      await _prepareGasPayment(options);

      if (_blockData.gasData.budget == null) {
        final dryRunResult = await expectClient(options).dryRunTransaction(
          _blockData.build(
            gasConfig: GasConfig(
              budget: BigInt.tryParse(_getConfig('maxTxGas', options)),
              payment: [],
            ),
          ),
          signerAddress: _blockData.sender,
        );

        if (dryRunResult.effects.status.status != ExecutionStatusType.success) {
          throw ArgumentError(
            "Dry run failed, could not automatically determine a budget: ${dryRunResult.effects.status.error}",
          );
        }

        final safeOverhead =
            GAS_SAFE_OVERHEAD * (_blockData.gasData.price ?? BigInt.one);

        final baseComputationCostWithOverhead =
            BigInt.from(dryRunResult.effects.gasUsed.computationCost) +
            safeOverhead;

        final gasBudget =
            baseComputationCostWithOverhead +
            BigInt.from(dryRunResult.effects.gasUsed.storageCost) -
            BigInt.from(dryRunResult.effects.gasUsed.storageRebate);

        // Set the budget to max(computation, computation + storage - rebate)
        setGasBudget(
          gasBudget > baseComputationCostWithOverhead
              ? gasBudget
              : baseComputationCostWithOverhead,
        );
      }
    }

    _validate(options);
  }

  bool isUsedAsMutable(TransactionBlockDataBuilder transactionData, int index) {
    var usedAsMutable = false;

    transactionData.getInputUses(index, (arg, tx) {
      if (tx["MoveCall"]?["_argumentTypes"] != null) {
        final arguments = tx["MoveCall"]["arguments"].toList();
        final argIndex = arguments.indexWhere(
          (element) => DeepCollectionEquality().equals(element, arg),
        );
        if (argIndex != -1) {
          usedAsMutable =
              tx["MoveCall"]["_argumentTypes"][argIndex]["ref"] != '&' ||
              usedAsMutable;
        }
      } else if (tx["MakeMoveVec"] != null ||
          tx["MergeCoins"] != null ||
          tx["SplitCoins"] != null) {
        usedAsMutable = true;
      }
    });

    return usedAsMutable;
  }

  bool isUsedAsReceiving(
    TransactionBlockDataBuilder transactionData,
    int index,
  ) {
    var usedAsReceiving = false;

    transactionData.getInputUses(index, (arg, tx) {
      if (tx["MoveCall"]?["_argumentTypes"] != null) {
        final arguments = tx["MoveCall"]["arguments"].toList();
        final argIndex = arguments.indexWhere(
          (element) => DeepCollectionEquality().equals(element, arg),
        );
        if (argIndex != -1) {
          usedAsReceiving =
              isReceivingType(tx["MoveCall"]["_argumentTypes"][argIndex]) ||
              usedAsReceiving;
        }
      }
    });

    return usedAsReceiving;
  }

  bool isReceivingType(dynamic type) {
    if (type["body"] is! Map || type["body"]["datatype"] is! Map) {
      return false;
    }

    return (type["body"]["datatype"]["package"] == '0x2' &&
        type["body"]["datatype"]["module"] == 'transfer' &&
        type["body"]["datatype"]["type"] == 'Receiving');
  }
}
