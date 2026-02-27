import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:sui_dart/grpc/types.dart';

void main() {
  group('ObjectIncludeOptions', () {
    test('defaults all fields to false', () {
      const options = ObjectIncludeOptions();
      expect(options.content, false);
      expect(options.previousTransaction, false);
      expect(options.objectBcs, false);
      expect(options.json, false);
    });

    test('allows setting individual fields to true', () {
      const options = ObjectIncludeOptions(content: true, json: true);
      expect(options.content, true);
      expect(options.previousTransaction, false);
      expect(options.objectBcs, false);
      expect(options.json, true);
    });

    test('allows setting all fields to true', () {
      const options = ObjectIncludeOptions(
        content: true,
        previousTransaction: true,
        objectBcs: true,
        json: true,
      );
      expect(options.content, true);
      expect(options.previousTransaction, true);
      expect(options.objectBcs, true);
      expect(options.json, true);
    });
  });

  group('TransactionIncludeOptions', () {
    test('defaults all fields to false', () {
      const options = TransactionIncludeOptions();
      expect(options.transaction, false);
      expect(options.effects, false);
      expect(options.events, false);
      expect(options.balanceChanges, false);
      expect(options.objectTypes, false);
      expect(options.bcs, false);
      expect(options.commandResults, false);
    });

    test('allows setting individual fields to true', () {
      const options = TransactionIncludeOptions(
        effects: true,
        events: true,
        commandResults: true,
      );
      expect(options.transaction, false);
      expect(options.effects, true);
      expect(options.events, true);
      expect(options.balanceChanges, false);
      expect(options.commandResults, true);
    });
  });

  group('GrpcPage', () {
    test('creates with required fields', () {
      final page = GrpcPage<String>(
        data: ['a', 'b', 'c'],
        hasNextPage: false,
      );
      expect(page.data, ['a', 'b', 'c']);
      expect(page.hasNextPage, false);
      expect(page.nextCursor, isNull);
    });

    test('creates with cursor when hasNextPage is true', () {
      final page = GrpcPage<int>(
        data: [1, 2, 3],
        hasNextPage: true,
        nextCursor: 'abc123',
      );
      expect(page.data.length, 3);
      expect(page.hasNextPage, true);
      expect(page.nextCursor, 'abc123');
    });

    test('works with complex generic types', () {
      final page = GrpcPage<GrpcObjectData>(
        data: [
          GrpcObjectData(
            objectId: '0x1',
            version: '1',
            digest: 'abc',
            owner: const GrpcImmutableOwner(),
            type: '0x2::coin::Coin<0x2::sui::SUI>',
          ),
        ],
        hasNextPage: false,
      );
      expect(page.data.length, 1);
      expect(page.data.first.objectId, '0x1');
    });

    test('handles empty data list', () {
      final page = GrpcPage<String>(data: [], hasNextPage: false);
      expect(page.data, isEmpty);
      expect(page.hasNextPage, false);
    });
  });

  group('GrpcOwner sealed class', () {
    test('GrpcAddressOwner holds address', () {
      const owner = GrpcAddressOwner('0xabc');
      expect(owner.address, '0xabc');
      expect(owner, isA<GrpcOwner>());
    });

    test('GrpcObjectOwner holds address', () {
      const owner = GrpcObjectOwner('0xdef');
      expect(owner.address, '0xdef');
      expect(owner, isA<GrpcOwner>());
    });

    test('GrpcSharedOwner holds initial shared version', () {
      const owner = GrpcSharedOwner('42');
      expect(owner.initialSharedVersion, '42');
      expect(owner, isA<GrpcOwner>());
    });

    test('GrpcImmutableOwner is singleton-like', () {
      const owner = GrpcImmutableOwner();
      expect(owner, isA<GrpcOwner>());
    });

    test('GrpcConsensusAddressOwner holds address and start version', () {
      const owner = GrpcConsensusAddressOwner(
        address: '0x123',
        startVersion: '10',
      );
      expect(owner.address, '0x123');
      expect(owner.startVersion, '10');
      expect(owner, isA<GrpcOwner>());
    });

    test('GrpcUnknownOwner is a valid owner variant', () {
      const owner = GrpcUnknownOwner();
      expect(owner, isA<GrpcOwner>());
    });

    test('pattern matching works on all owner variants', () {
      final owners = <GrpcOwner>[
        const GrpcAddressOwner('0x1'),
        const GrpcObjectOwner('0x2'),
        const GrpcSharedOwner('1'),
        const GrpcImmutableOwner(),
        const GrpcConsensusAddressOwner(address: '0x3', startVersion: '5'),
        const GrpcUnknownOwner(),
      ];

      final results = owners.map((owner) {
        return switch (owner) {
          GrpcAddressOwner(:final address) => 'address:$address',
          GrpcObjectOwner(:final address) => 'object:$address',
          GrpcSharedOwner(:final initialSharedVersion) => 'shared:$initialSharedVersion',
          GrpcImmutableOwner() => 'immutable',
          GrpcConsensusAddressOwner(:final address) => 'consensus:$address',
          GrpcUnknownOwner() => 'unknown',
        };
      }).toList();

      expect(results, [
        'address:0x1',
        'object:0x2',
        'shared:1',
        'immutable',
        'consensus:0x3',
        'unknown',
      ]);
    });
  });

  group('GrpcObjectResult sealed class', () {
    test('GrpcObjectSuccess wraps object data', () {
      final result = GrpcObjectSuccess(GrpcObjectData(
        objectId: '0x1',
        version: '5',
        digest: 'abc',
        owner: const GrpcAddressOwner('0xowner'),
        type: 'SomeType',
      ));
      expect(result, isA<GrpcObjectResult>());
      expect(result.data.objectId, '0x1');
      expect(result.data.version, '5');
    });

    test('GrpcObjectError wraps error message', () {
      const result = GrpcObjectError('Object not found');
      expect(result, isA<GrpcObjectResult>());
      expect(result.error, 'Object not found');
    });

    test('pattern matching works on result variants', () {
      final results = <GrpcObjectResult>[
        GrpcObjectSuccess(GrpcObjectData(
          objectId: '0x1',
          version: '1',
          digest: 'abc',
          owner: const GrpcImmutableOwner(),
          type: 'Coin',
        )),
        const GrpcObjectError('not found'),
      ];

      final messages = results.map((r) {
        return switch (r) {
          GrpcObjectSuccess(:final data) => 'ok:${data.objectId}',
          GrpcObjectError(:final error) => 'err:$error',
        };
      }).toList();

      expect(messages, ['ok:0x1', 'err:not found']);
    });
  });

  group('GrpcObjectData', () {
    test('creates with required fields only', () {
      final obj = GrpcObjectData(
        objectId: '0x1',
        version: '10',
        digest: 'abc123',
        owner: const GrpcAddressOwner('0xowner'),
        type: '0x2::coin::Coin<0x2::sui::SUI>',
      );
      expect(obj.objectId, '0x1');
      expect(obj.version, '10');
      expect(obj.digest, 'abc123');
      expect(obj.owner, isA<GrpcAddressOwner>());
      expect(obj.type, '0x2::coin::Coin<0x2::sui::SUI>');
      expect(obj.content, isNull);
      expect(obj.previousTransaction, isNull);
      expect(obj.objectBcs, isNull);
      expect(obj.json, isNull);
    });

    test('creates with all optional fields', () {
      final obj = GrpcObjectData(
        objectId: '0x1',
        version: '10',
        digest: 'abc123',
        owner: const GrpcAddressOwner('0xowner'),
        type: 'SomeType',
        previousTransaction: 'txdigest123',
        content: Uint8List.fromList([1, 2, 3]),
        objectBcs: Uint8List.fromList([4, 5, 6]),
        json: const {'fields': {'value': 42}},
      );
      expect(obj.previousTransaction, 'txdigest123');
      expect(obj.content, isNotNull);
      expect(obj.content!.length, 3);
      expect(obj.objectBcs, isNotNull);
      expect(obj.objectBcs!.length, 3);
      expect(obj.json, isNotNull);
    });
  });

  group('GrpcCoinData', () {
    test('creates with all required fields', () {
      const coin = GrpcCoinData(
        objectId: '0xabc',
        version: '5',
        digest: 'digest123',
        owner: GrpcAddressOwner('0xowner'),
        type: '0x2::sui::SUI',
        balance: '1000000000',
      );
      expect(coin.objectId, '0xabc');
      expect(coin.version, '5');
      expect(coin.digest, 'digest123');
      expect(coin.owner, isA<GrpcAddressOwner>());
      expect(coin.type, '0x2::sui::SUI');
      expect(coin.balance, '1000000000');
    });
  });

  group('GrpcBalance', () {
    test('creates with all fields', () {
      const balance = GrpcBalance(
        coinType: '0x2::sui::SUI',
        balance: '5000000000',
        coinBalance: '5000000000',
        addressBalance: '5000000000',
      );
      expect(balance.coinType, '0x2::sui::SUI');
      expect(balance.balance, '5000000000');
      expect(balance.coinBalance, '5000000000');
      expect(balance.addressBalance, '5000000000');
    });
  });

  group('GrpcCoinMetadata', () {
    test('creates with all fields', () {
      const meta = GrpcCoinMetadata(
        id: '0x1',
        decimals: 9,
        name: 'Sui',
        symbol: 'SUI',
        description: 'The native token',
        iconUrl: 'https://example.com/icon.png',
      );
      expect(meta.id, '0x1');
      expect(meta.decimals, 9);
      expect(meta.name, 'Sui');
      expect(meta.symbol, 'SUI');
      expect(meta.description, 'The native token');
      expect(meta.iconUrl, 'https://example.com/icon.png');
    });

    test('allows null iconUrl', () {
      const meta = GrpcCoinMetadata(
        id: '0x1',
        decimals: 6,
        name: 'USDC',
        symbol: 'USDC',
        description: 'USD Coin',
      );
      expect(meta.iconUrl, isNull);
    });
  });

  group('GrpcTransactionResponse', () {
    test('creates with digest only', () {
      const resp = GrpcTransactionResponse(digest: 'txdigest');
      expect(resp.digest, 'txdigest');
      expect(resp.signatures, isEmpty);
      expect(resp.epoch, isNull);
      expect(resp.status.success, true);
      expect(resp.transaction, isNull);
      expect(resp.effects, isNull);
      expect(resp.events, isNull);
      expect(resp.balanceChanges, isNull);
      expect(resp.objectTypes, isNull);
      expect(resp.bcs, isNull);
      expect(resp.checkpoint, isNull);
      expect(resp.timestampMs, isNull);
      expect(resp.commandResults, isNull);
    });

    test('creates with all optional fields', () {
      final resp = GrpcTransactionResponse(
        digest: 'txdigest',
        signatures: const ['sig1', 'sig2'],
        epoch: '100',
        status: const GrpcExecutionStatus(success: true),
        transaction: 'base64tx',
        effects: const GrpcTransactionEffects(transactionDigest: 'effectsdigest'),
        events: [
          GrpcEvent(
            packageId: '0x2',
            module: 'coin',
            sender: '0xsender',
            eventType: '0x2::coin::CoinEvent',
            bcs: Uint8List(0),
          ),
        ],
        balanceChanges: const [
          GrpcBalanceChange(address: '0xowner', coinType: 'SUI', amount: '100'),
        ],
        objectTypes: const {'0x1': '0x2::coin::Coin'},
        bcs: Uint8List.fromList([1, 2, 3]),
        checkpoint: '1000',
        timestampMs: '1700000000000',
        commandResults: const [
          GrpcCommandResult(returnValues: [], mutatedReferences: []),
        ],
      );
      expect(resp.signatures.length, 2);
      expect(resp.epoch, '100');
      expect(resp.events!.length, 1);
      expect(resp.balanceChanges!.length, 1);
      expect(resp.objectTypes!['0x1'], '0x2::coin::Coin');
      expect(resp.commandResults!.length, 1);
    });

    test('copyWith replaces specified fields', () {
      const original = GrpcTransactionResponse(
        digest: 'original',
        checkpoint: '100',
      );
      final copied = original.copyWith(
        checkpoint: '200',
        timestampMs: '1700000000000',
      );
      expect(copied.digest, 'original');
      expect(copied.checkpoint, '200');
      expect(copied.timestampMs, '1700000000000');
    });

    test('copyWith preserves unspecified fields', () {
      final original = GrpcTransactionResponse(
        digest: 'txdigest',
        signatures: const ['sig1'],
        epoch: '5',
        effects: const GrpcTransactionEffects(lamportVersion: '10'),
        events: [
          GrpcEvent(
            packageId: '0x2',
            module: 'coin',
            sender: '0x1',
            eventType: 'EventType',
            bcs: Uint8List(0),
          ),
        ],
      );
      final copied = original.copyWith(
        commandResults: const [
          GrpcCommandResult(returnValues: [], mutatedReferences: []),
        ],
      );
      expect(copied.digest, 'txdigest');
      expect(copied.signatures, ['sig1']);
      expect(copied.epoch, '5');
      expect(copied.effects!.lamportVersion, '10');
      expect(copied.events!.length, 1);
      expect(copied.commandResults!.length, 1);
    });
  });

  group('GrpcTransactionEffects', () {
    test('creates with all null optional fields', () {
      const effects = GrpcTransactionEffects();
      expect(effects.bcs, isNull);
      expect(effects.version, isNull);
      expect(effects.transactionDigest, isNull);
      expect(effects.lamportVersion, isNull);
      expect(effects.status, isNull);
      expect(effects.gasUsed, isNull);
      expect(effects.dependencies, isNull);
      expect(effects.changedObjects, isNull);
      expect(effects.auxiliaryDataDigest, isNull);
    });

    test('creates with full status and gas info', () {
      final effects = GrpcTransactionEffects(
        bcs: Uint8List.fromList([1, 2, 3]),
        version: 2,
        transactionDigest: 'txdigest',
        lamportVersion: '50',
        status: const GrpcExecutionStatus(success: true),
        gasUsed: const GrpcGasUsed(
          computationCost: '1000',
          storageCost: '2000',
          storageRebate: '500',
          nonRefundableStorageFee: '100',
        ),
        gasObject: const GrpcGasObject(
          objectId: '0xgas',
          inputState: 'Exists',
          outputState: 'ObjectWrite',
        ),
        dependencies: const ['dep1', 'dep2'],
        auxiliaryDataDigest: 'auxdigest',
      );
      expect(effects.bcs!.length, 3);
      expect(effects.version, 2);
      expect(effects.status!.success, true);
      expect(effects.gasUsed!.computationCost, '1000');
      expect(effects.gasObject!.objectId, '0xgas');
      expect(effects.dependencies!.length, 2);
      expect(effects.auxiliaryDataDigest, 'auxdigest');
    });
  });

  group('GrpcExecutionError and error details', () {
    test('creates error without detail', () {
      const error = GrpcExecutionError(
        message: 'Something failed',
        kind: 'MOVE_ABORT',
      );
      expect(error.message, 'Something failed');
      expect(error.kind, 'MOVE_ABORT');
      expect(error.command, isNull);
      expect(error.detail, isNull);
    });

    test('creates error with command and abort detail', () {
      const error = GrpcExecutionError(
        message: 'Move abort',
        kind: 'MOVE_ABORT',
        command: 0,
        detail: GrpcAbortDetail(GrpcMoveAbort(
          abortCode: '1',
          location: GrpcMoveAbortLocation(
            package: '0x2',
            module: 'coin',
            function: 3,
            instruction: 10,
            functionName: 'transfer',
          ),
        )),
      );
      expect(error.command, 0);
      final detail = error.detail as GrpcAbortDetail;
      expect(detail.abort.abortCode, '1');
      expect(detail.abort.location!.package, '0x2');
      expect(detail.abort.location!.functionName, 'transfer');
    });

    test('pattern matching works on all error detail variants', () {
      final details = <GrpcExecutionErrorDetail>[
        const GrpcAbortDetail(GrpcMoveAbort(abortCode: '1')),
        const GrpcSizeErrorDetail(size: '100', maxSize: '50'),
        const GrpcCommandArgumentErrorDetail(argument: 0, kind: 'TYPE_MISMATCH'),
        const GrpcTypeArgumentErrorDetail(typeArgument: 1, kind: 'CONSTRAINT_NOT_SATISFIED'),
        const GrpcPackageUpgradeErrorDetail(kind: 'INCOMPATIBLE', packageId: '0x5'),
        const GrpcIndexErrorDetail(index: 0, subresult: 1),
        const GrpcObjectIdErrorDetail('0xobj'),
        const GrpcCoinDenyListErrorDetail(address: '0xaddr', coinType: 'SUI'),
        const GrpcCongestedObjectsDetail(['0xa', '0xb']),
      ];

      expect(details.length, 9);

      for (final detail in details) {
        final matched = switch (detail) {
          GrpcAbortDetail() => 'abort',
          GrpcSizeErrorDetail() => 'size',
          GrpcCommandArgumentErrorDetail() => 'cmdArg',
          GrpcTypeArgumentErrorDetail() => 'typeArg',
          GrpcPackageUpgradeErrorDetail() => 'pkgUpgrade',
          GrpcIndexErrorDetail() => 'index',
          GrpcObjectIdErrorDetail() => 'objectId',
          GrpcCoinDenyListErrorDetail() => 'coinDeny',
          GrpcCongestedObjectsDetail() => 'congested',
        };
        expect(matched.isNotEmpty, true);
      }
    });
  });

  group('GrpcMoveAbort', () {
    test('creates with abort code only', () {
      const abort = GrpcMoveAbort(abortCode: '42');
      expect(abort.abortCode, '42');
      expect(abort.location, isNull);
      expect(abort.cleverError, isNull);
      expect(abort.cleverErrorRaw, isNull);
    });

    test('creates with location and clever error', () {
      const abort = GrpcMoveAbort(
        abortCode: '1',
        location: GrpcMoveAbortLocation(
          package: '0x2',
          module: 'transfer',
          function: 0,
          instruction: 5,
          functionName: 'do_transfer',
        ),
        cleverError: 'EInsufficientBalance',
      );
      expect(abort.location!.module, 'transfer');
      expect(abort.location!.function, 0);
      expect(abort.location!.instruction, 5);
      expect(abort.cleverError, 'EInsufficientBalance');
    });
  });

  group('GrpcChangedObject', () {
    test('creates with required objectId only', () {
      const obj = GrpcChangedObject(objectId: '0x1');
      expect(obj.objectId, '0x1');
      expect(obj.idOperation, isNull);
      expect(obj.inputOwner, isNull);
      expect(obj.outputOwner, isNull);
    });

    test('creates with full input/output state', () {
      const obj = GrpcChangedObject(
        objectId: '0x1',
        idOperation: 'Created',
        inputState: 'DoesNotExist',
        outputState: 'ObjectWrite',
        outputVersion: '1',
        outputDigest: 'digest',
        outputOwner: GrpcAddressOwner('0xowner'),
        objectType: '0x2::coin::Coin<0x2::sui::SUI>',
      );
      expect(obj.idOperation, 'Created');
      expect(obj.inputState, 'DoesNotExist');
      expect(obj.outputOwner, isA<GrpcAddressOwner>());
    });
  });

  group('GrpcEvent', () {
    test('creates with required fields', () {
      final event = GrpcEvent(
        packageId: '0x2',
        module: 'coin',
        sender: '0xsender',
        eventType: '0x2::coin::MintEvent',
        bcs: Uint8List(0),
      );
      expect(event.packageId, '0x2');
      expect(event.module, 'coin');
      expect(event.sender, '0xsender');
      expect(event.eventType, '0x2::coin::MintEvent');
      expect(event.bcs, isNotNull);
    });

    test('creates with BCS data', () {
      final event = GrpcEvent(
        packageId: '0x2',
        module: 'coin',
        sender: '0xsender',
        eventType: '0x2::coin::MintEvent',
        bcs: Uint8List.fromList([1, 2, 3, 4]),
      );
      expect(event.bcs.length, 4);
    });
  });

  group('GrpcBalanceChange', () {
    test('creates with all required fields', () {
      const change = GrpcBalanceChange(
        address: '0xowner',
        coinType: '0x2::sui::SUI',
        amount: '-1000000',
      );
      expect(change.address, '0xowner');
      expect(change.coinType, '0x2::sui::SUI');
      expect(change.amount, '-1000000');
    });
  });

  group('GrpcDynamicFieldEntry', () {
    test('creates with all fields', () {
      final entry = GrpcDynamicFieldEntry(
        name: GrpcDynamicFieldName(type: 'u64', bcs: Uint8List.fromList([1, 2])),
        objectType: '0x2::coin::Coin<0x2::sui::SUI>',
        objectId: '0xchild',
        type: 'DynamicField',
      );
      expect(entry.name.type, 'u64');
      expect(entry.name.bcs!.length, 2);
      expect(entry.objectType, '0x2::coin::Coin<0x2::sui::SUI>');
      expect(entry.type, 'DynamicField');
    });

    test('GrpcDynamicFieldName allows null type and bcs', () {
      const name = GrpcDynamicFieldName();
      expect(name.type, isNull);
      expect(name.bcs, isNull);
    });
  });

  group('GrpcSystemState', () {
    test('creates with required fields', () {
      const state = GrpcSystemState(
        epoch: '100',
        referenceGasPrice: '750',
      );
      expect(state.epoch, '100');
      expect(state.referenceGasPrice, '750');
      expect(state.systemState, isNull);
      expect(state.epochStartTimestampMs, isNull);
    });

    test('creates with all fields', () {
      const state = GrpcSystemState(
        epoch: '100',
        referenceGasPrice: '750',
        systemState: {'validators': []},
        epochStartTimestampMs: '1700000000',
      );
      expect(state.systemState, isNotNull);
      expect(state.epochStartTimestampMs, '1700000000');
    });
  });

  group('GrpcVerifySignatureResult', () {
    test('creates valid result', () {
      const result = GrpcVerifySignatureResult(isValid: true);
      expect(result.isValid, true);
      expect(result.reason, isNull);
    });

    test('creates invalid result with reason', () {
      const result = GrpcVerifySignatureResult(
        isValid: false,
        reason: 'Invalid proof',
      );
      expect(result.isValid, false);
      expect(result.reason, 'Invalid proof');
    });
  });

  group('GrpcMoveFunction', () {
    test('creates with all fields', () {
      const func = GrpcMoveFunction(
        name: 'transfer',
        visibility: 'Public',
        isEntry: true,
        typeParameters: [
          GrpcTypeParameter(abilities: ['Store', 'Key']),
        ],
        parameters: [
          MoveTypePrimitive('Address'),
          MoveTypeStruct(
            address: '0x2',
            module: 'coin',
            name: 'Coin',
            typeArguments: [MoveTypeParameter(0)],
          ),
        ],
        returnTypes: [],
      );
      expect(func.name, 'transfer');
      expect(func.visibility, 'Public');
      expect(func.isEntry, true);
      expect(func.typeParameters.length, 1);
      expect(func.typeParameters.first.abilities, ['Store', 'Key']);
      expect(func.parameters.length, 2);
      expect(func.returnTypes, isEmpty);
    });
  });

  group('NormalizedMoveType sealed class', () {
    test('MoveTypePrimitive stores type name', () {
      const t = MoveTypePrimitive('U64');
      expect(t.typeName, 'U64');
      expect(t, isA<NormalizedMoveType>());
    });

    test('MoveTypeVector stores element type', () {
      const t = MoveTypeVector(MoveTypePrimitive('U8'));
      expect(t.element, isA<MoveTypePrimitive>());
      expect((t.element as MoveTypePrimitive).typeName, 'U8');
    });

    test('MoveTypeVector allows null element', () {
      const t = MoveTypeVector(null);
      expect(t.element, isNull);
    });

    test('MoveTypeStruct stores address, module, name, and type arguments', () {
      const t = MoveTypeStruct(
        address: '0x2',
        module: 'coin',
        name: 'Coin',
        typeArguments: [MoveTypePrimitive('U64')],
      );
      expect(t.address, '0x2');
      expect(t.module, 'coin');
      expect(t.name, 'Coin');
      expect(t.typeArguments.length, 1);
    });

    test('MoveTypeParameter stores index', () {
      const t = MoveTypeParameter(0);
      expect(t.index, 0);
    });

    test('MoveTypeReference wraps body', () {
      const t = MoveTypeReference(MoveTypePrimitive('Address'));
      expect(t.body, isA<MoveTypePrimitive>());
    });

    test('MoveTypeMutableReference wraps body', () {
      const t = MoveTypeMutableReference(MoveTypePrimitive('Address'));
      expect(t.body, isA<MoveTypePrimitive>());
    });

    test('pattern matching works on all type variants', () {
      final types = <NormalizedMoveType>[
        const MoveTypePrimitive('Bool'),
        const MoveTypeVector(MoveTypePrimitive('U8')),
        const MoveTypeStruct(
          address: '0x1',
          module: 'string',
          name: 'String',
          typeArguments: [],
        ),
        const MoveTypeParameter(0),
        const MoveTypeReference(MoveTypePrimitive('U64')),
        const MoveTypeMutableReference(MoveTypePrimitive('U128')),
      ];

      final labels = types.map((t) {
        return switch (t) {
          MoveTypePrimitive(:final typeName) => 'primitive:$typeName',
          MoveTypeVector() => 'vector',
          MoveTypeStruct(:final name) => 'struct:$name',
          MoveTypeParameter(:final index) => 'typeParam:$index',
          MoveTypeReference() => 'ref',
          MoveTypeMutableReference() => 'mutRef',
        };
      }).toList();

      expect(labels, [
        'primitive:Bool',
        'vector',
        'struct:String',
        'typeParam:0',
        'ref',
        'mutRef',
      ]);
    });

    test('nested complex move type structure', () {
      // Coin<T> where T is a type parameter, wrapped in a reference
      const complexType = MoveTypeReference(
        MoveTypeStruct(
          address: '0x2',
          module: 'coin',
          name: 'Coin',
          typeArguments: [MoveTypeParameter(0)],
        ),
      );

      expect(complexType.body, isA<MoveTypeStruct>());
      final struct = complexType.body as MoveTypeStruct;
      expect(struct.name, 'Coin');
      expect(struct.typeArguments.first, isA<MoveTypeParameter>());
    });
  });

  group('GrpcCommandResult', () {
    test('creates with empty lists', () {
      const result = GrpcCommandResult(returnValues: [], mutatedReferences: []);
      expect(result.returnValues, isEmpty);
      expect(result.mutatedReferences, isEmpty);
    });

    test('creates with values', () {
      final result = GrpcCommandResult(
        returnValues: [
          GrpcCommandOutput(bcs: Uint8List.fromList([1, 2, 3])),
          GrpcCommandOutput(bcs: Uint8List.fromList([4, 5])),
        ],
        mutatedReferences: [
          GrpcCommandOutput(bcs: Uint8List.fromList([6, 7, 8])),
        ],
      );
      expect(result.returnValues.length, 2);
      expect(result.returnValues[0].bcs.length, 3);
      expect(result.returnValues[1].bcs.length, 2);
      expect(result.mutatedReferences.length, 1);
    });
  });

  group('GrpcUnchangedConsensusObject', () {
    test('creates with required fields', () {
      const obj = GrpcUnchangedConsensusObject(
        objectId: '0x1',
        version: '10',
      );
      expect(obj.objectId, '0x1');
      expect(obj.version, '10');
      expect(obj.kind, isNull);
      expect(obj.digest, isNull);
    });

    test('creates with all fields', () {
      const obj = GrpcUnchangedConsensusObject(
        kind: 'ReadOnlyRoot',
        objectId: '0x1',
        version: '10',
        digest: 'abc',
        objectType: 'SomeType',
      );
      expect(obj.kind, 'ReadOnlyRoot');
      expect(obj.objectType, 'SomeType');
    });
  });

  group('GrpcGasUsed', () {
    test('stores all gas cost fields as strings', () {
      const gas = GrpcGasUsed(
        computationCost: '1000',
        storageCost: '2000',
        storageRebate: '500',
        nonRefundableStorageFee: '100',
      );
      expect(gas.computationCost, '1000');
      expect(gas.storageCost, '2000');
      expect(gas.storageRebate, '500');
      expect(gas.nonRefundableStorageFee, '100');
    });
  });

  group('GrpcExecutionStatus', () {
    test('creates successful status', () {
      const status = GrpcExecutionStatus(success: true);
      expect(status.success, true);
      expect(status.error, isNull);
    });

    test('creates failed status with error', () {
      const status = GrpcExecutionStatus(
        success: false,
        error: GrpcExecutionError(
          message: 'Execution failed',
          kind: 'MOVE_ABORT',
        ),
      );
      expect(status.success, false);
      expect(status.error!.message, 'Execution failed');
    });
  });
}
