// ignore_for_file: constant_identifier_names, non_constant_identifier_names, deprecated_member_use_from_same_package
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:sui_dart/bcs/sui_bcs.dart';
import 'package:sui_dart/builder/commands.dart';
import 'package:sui_dart/builder/inputs.dart';
import 'package:sui_dart/builder/pure.dart';
import 'package:sui_dart/builder/transaction_block_data.dart';
import 'package:sui_dart/builder/transaction_resolver.dart';
import 'package:sui_dart/builder/v1.dart';
import 'package:sui_dart/core/sui_core_client.dart';
import 'package:sui_dart/cryptography/keypair.dart';
import 'package:sui_dart/grpc/types.dart'
    show ExecutionStatus, TransactionIncludeOptions;
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/types/objects.dart';
import 'package:sui_dart/types/sui_bcs.dart';
import 'package:sui_dart/utils/error.dart' show SimulationError;
import 'package:sui_dart/grpc/generated/sui/rpc/v2/transaction.pb.dart'
    as grpc_transaction;

/// An async resolver for a named `$Intent` command. It may inspect and mutate
/// [transactionData] (e.g. via `replaceCommand`) and must call [next] to run the
/// rest of the resolver chain.
typedef TransactionPlugin = IntentResolver;

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

SuiCoreClient expectClient(BuildOptions options) {
  if (options.client == null) {
    throw ArgumentError(
      "No provider passed to Transaction#build, but transaction data was not sufficient to build offline.",
    );
  }

  return options.client!;
}

/// A command referencing an earlier one holds a [TransactionResult] rather than a
/// map. Its `result` is the right form: a stored bare result means the whole
/// result, while its own `toJson` can report a nested index read elsewhere.
Object? _jsonEncodable(dynamic value) {
  if (value is BigInt) return value.toString();
  if (value is TransactionResult) return value.result;
  return value;
}

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
  /// Transport-agnostic client used for all build-time reads (coins, objects,
  /// gas price, dry run, move-function signatures). Pass `suiGrpcClient.core`
  /// or `suiGraphQLClient.core`.
  SuiCoreClient? client;

  bool onlyTransactionKind;

  /// Resolves `coinWithBalance` from the address balance, no lookups. With price,
  /// budget, a `ValidDuring`/`Validity` expiry and no `tx.gas`, payment is `[]`.
  bool assumeSufficientAddressBalances;

  BuildOptions({
    this.client,
    this.onlyTransactionKind = false,
    this.assumeSufficientAddressBalances = false,
  });
}

class SerializeTransactionOptions extends BuildOptions {
  List<String>? supportedIntents;

  SerializeTransactionOptions({
    this.supportedIntents,
    super.client,
    super.onlyTransactionKind,
    super.assumeSufficientAddressBalances,
  });
}

class SignOptions extends BuildOptions {
  Keypair signer;

  SignOptions({
    required this.signer,
    super.client,
    super.onlyTransactionKind,
    super.assumeSufficientAddressBalances,
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
    _blockData.expiration = epoch == null
        ? null
        : TransactionExpiration(epoch: epoch);
  }

  void setTransactionExpiration(TransactionExpiration? expiration) {
    _blockData.expiration = expiration;
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

    // A pure input has no id either, so a null match would return a pure argument.
    final inserted = id == null
        ? <String, dynamic>{}
        : _blockData.inputs.firstWhere(
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
      toEncodable: _jsonEncodable,
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
    return jsonEncode(
      serializeV1TransactionData(_blockData.snapshot()).toJson(),
      toEncodable: _jsonEncodable,
    );
  }

  /// [toJsonAsync] resolves intents first; prefer it when the block may hold any.
  String toJson([SerializeTransactionOptions? options]) {
    return jsonEncode(
      _blockData.snapshot().toJson(),
      toEncodable: _jsonEncodable,
    );
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

  void _validate() {
    for (var i = 0; i < _blockData.inputs.length; i++) {
      final input = _blockData.inputs[i];
      if (input['Object'] == null &&
          input['Pure'] == null &&
          input['FundsWithdrawal'] == null) {
        throw ArgumentError(
          'Input at index $i has not been resolved. Expected a Pure, Object, '
          'or FundsWithdrawal input, but found $input',
        );
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

  void _normalizeRawArguments() {
    for (final command in _blockData.commands) {
      if (command["SplitCoins"] != null) {
        for (final amount in command["SplitCoins"]["amounts"]) {
          normalizeRawArgument(amount, SuiBcs.U64);
        }
      } else if (command["TransferObjects"] != null) {
        normalizeRawArgument(
          command["TransferObjects"]["address"],
          SuiBcs.Address,
        );
      }
    }
  }

  /// Validates the transaction data and resolves all inputs so it can be built into bytes.
  Future<void> _prepare(BuildOptions options) async {
    if (!options.onlyTransactionKind && _blockData.sender == null) {
      throw ArgumentError('Missing transaction sender');
    }

    await _resolveIntents(options);

    if (_assumesAddressBalanceGas(options)) setGasPayment(const []);

    _normalizeRawArguments();

    if (_needsResolution(options)) {
      await expectClient(options).resolveTransactionPlugin()(
        _blockData,
        options,
        () async {},
      );
    }

    _validate();
  }

  bool _needsResolution(BuildOptions options) {
    final unresolved = _blockData.inputs.any(
      (input) =>
          input['UnresolvedObject'] != null || input['UnresolvedPure'] != null,
    );
    if (unresolved) return true;
    if (options.onlyTransactionKind) return false;

    final gas = _blockData.gasData;
    return gas.price == null ||
        gas.budget == null ||
        gas.payment == null ||
        (gas.payment!.isEmpty && _blockData.expiration == null);
  }

  bool _assumesAddressBalanceGas(BuildOptions options) {
    if (!options.assumeSufficientAddressBalances ||
        options.onlyTransactionKind) {
      return false;
    }

    final gasData = _blockData.gasData;
    if (gasData.payment != null ||
        gasData.price == null ||
        gasData.budget == null) {
      return false;
    }

    // empty payment has no replay guard: needs ValidDuring/Validity, not Epoch
    final expiration = _blockData.expiration;
    if (expiration?.validDuring == null && expiration?.validity == null) {
      return false;
    }

    final unresolved = _blockData.inputs.any(
      (input) =>
          input['UnresolvedObject'] != null || input['UnresolvedPure'] != null,
    );
    if (unresolved) return false;

    var usesGasCoin = false;
    _blockData.mapArguments((arg, command, index) {
      if (arg is Map && arg['GasCoin'] != null) usesGasCoin = true;
      return arg;
    });
    return !usesGasCoin;
  }
}

typedef ResolvedSimulation = ({
  Uint8List? bcs,
  String? epoch,
  ExecutionStatus status,
});

typedef ResolveSimulate =
    Future<ResolvedSimulation> Function(
      Transaction request, {
      required bool doGasSelection,
      required bool checksEnabled,
    });

/// The node fills in object versions, gas price, budget and payment, selecting
/// gas when budget or payment is unset. [simulate] defaults to simulateTransaction.
TransactionPlugin simulationResolvePlugin(
  SuiCoreClient client, {
  ResolveSimulate? simulate,
}) {
  simulate ??=
      (request, {required doGasSelection, required checksEnabled}) async {
        final result = await client.simulateTransaction(
          request,
          doGasSelection: doGasSelection,
          checksEnabled: checksEnabled,
          include: const TransactionIncludeOptions(effects: true, bcs: true),
        );
        return (bcs: result.bcs, epoch: result.epoch, status: result.status);
      };

  return (data, options, next) async {
    final original = data.snapshot();
    final onlyKind = options.onlyTransactionKind;
    final doGasSelection =
        !onlyKind &&
        (original.gasData.budget == null || original.gasData.payment == null);

    final request = Transaction()
      .._blockData = TransactionBlockDataBuilder(data.snapshot());
    request._blockData.sender ??= normalizeSuiAddress('0x0');

    final ResolvedSimulation result;
    try {
      result = await simulate!(
        request,
        doGasSelection: doGasSelection,
        checksEnabled: !onlyKind,
      );
    } on Exception catch (error) {
      throw SimulationError(
        error is GrpcError ? (error.message ?? '$error') : '$error',
        cause: error,
      );
    }

    if (!onlyKind && !result.status.success) {
      final executionError = result.status.error;
      throw SimulationError(
        'Transaction resolution failed: '
        '${executionError?.message ?? 'Transaction failed'}',
        executionError: executionError,
      );
    }
    final bytes = result.bcs;
    if (bytes == null) {
      throw StateError('simulateTransaction returned no resolved transaction');
    }

    final resolved = TransactionBlockDataBuilder.fromBytes(bytes).snapshot();
    if (onlyKind) {
      resolved
        ..sender = null
        ..expiration = null
        ..gasData = GasConfig();
    }
    data.applyResolvedData(resolved);

    // an explicit empty payment has no coin version to stop a replay
    final current = data.expiration;
    final hasWindow =
        current != null &&
        (current.epoch != null ||
            current.validDuring != null ||
            current.validity != null);
    if (!onlyKind &&
        !doGasSelection &&
        original.expiration == null &&
        original.gasData.payment?.isEmpty == true &&
        !hasWindow) {
      final chain = await client.getChainIdentifier();
      final epoch = BigInt.parse(
        result.epoch ?? (await client.getCurrentSystemState()).epoch,
      );
      data.expiration = TransactionExpiration(
        validDuring: {
          'minEpoch': epoch.toString(),
          'maxEpoch': (epoch + BigInt.one).toString(),
          'minTimestamp': null,
          'maxTimestamp': null,
          'chain': chain,
          'nonce': Random().nextInt(0x100000000),
        },
      );
    }

    return next();
  };
}
