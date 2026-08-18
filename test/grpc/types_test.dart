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

  group('Page', () {
    test('creates with required fields', () {
      final page = Page<String>(data: ['a', 'b', 'c'], hasNextPage: false);
      expect(page.data, ['a', 'b', 'c']);
      expect(page.hasNextPage, false);
      expect(page.nextCursor, isNull);
    });

    test('creates with cursor when hasNextPage is true', () {
      final page = Page<int>(
        data: [1, 2, 3],
        hasNextPage: true,
        nextCursor: 'abc123',
      );
      expect(page.data.length, 3);
      expect(page.hasNextPage, true);
      expect(page.nextCursor, 'abc123');
    });

    test('works with complex generic types', () {
      final page = Page<ObjectData>(
        data: [
          ObjectData(
            objectId: '0x1',
            version: '1',
            digest: 'abc',
            owner: const ImmutableOwner(),
            type: '0x2::coin::Coin<0x2::sui::SUI>',
          ),
        ],
        hasNextPage: false,
      );
      expect(page.data.length, 1);
      expect(page.data.first.objectId, '0x1');
    });

    test('handles empty data list', () {
      final page = Page<String>(data: [], hasNextPage: false);
      expect(page.data, isEmpty);
      expect(page.hasNextPage, false);
    });
  });

  group('Owner sealed class', () {
    test('AddressOwner holds address', () {
      const owner = AddressOwner('0xabc');
      expect(owner.address, '0xabc');
      expect(owner, isA<Owner>());
    });

    test('ObjectOwner holds address', () {
      const owner = ObjectOwner('0xdef');
      expect(owner.address, '0xdef');
      expect(owner, isA<Owner>());
    });

    test('SharedOwner holds initial shared version', () {
      const owner = SharedOwner('42');
      expect(owner.initialSharedVersion, '42');
      expect(owner, isA<Owner>());
    });

    test('ImmutableOwner is singleton-like', () {
      const owner = ImmutableOwner();
      expect(owner, isA<Owner>());
    });

    test('ConsensusAddressOwner holds address and start version', () {
      const owner = ConsensusAddressOwner(address: '0x123', startVersion: '10');
      expect(owner.address, '0x123');
      expect(owner.startVersion, '10');
      expect(owner, isA<Owner>());
    });

    test('UnknownOwner is a valid owner variant', () {
      const owner = UnknownOwner();
      expect(owner, isA<Owner>());
    });

    test('pattern matching works on all owner variants', () {
      final owners = <Owner>[
        const AddressOwner('0x1'),
        const ObjectOwner('0x2'),
        const SharedOwner('1'),
        const ImmutableOwner(),
        const ConsensusAddressOwner(address: '0x3', startVersion: '5'),
        const UnknownOwner(),
      ];

      final results = owners.map((owner) {
        return switch (owner) {
          AddressOwner(:final address) => 'address:$address',
          ObjectOwner(:final address) => 'object:$address',
          SharedOwner(:final initialSharedVersion) =>
            'shared:$initialSharedVersion',
          ImmutableOwner() => 'immutable',
          ConsensusAddressOwner(:final address) => 'consensus:$address',
          UnknownOwner() => 'unknown',
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

  group('ObjectResult sealed class', () {
    test('ObjectSuccess wraps object data', () {
      final result = ObjectSuccess(
        ObjectData(
          objectId: '0x1',
          version: '5',
          digest: 'abc',
          owner: const AddressOwner('0xowner'),
          type: 'SomeType',
        ),
      );
      expect(result, isA<ObjectResult>());
      expect(result.data.objectId, '0x1');
      expect(result.data.version, '5');
    });

    test('ObjectError wraps error message', () {
      const result = ObjectError('Object not found');
      expect(result, isA<ObjectResult>());
      expect(result.error, 'Object not found');
      expect(result.code, 'unknown');
      expect(result.reason, ObjectErrorReason.unknown);
      expect(result.objectId, isNull);
    });

    test('ObjectError carries lookup details', () {
      const result = ObjectError(
        'Object 0x1 not found',
        code: 'notExists',
        reason: ObjectErrorReason.notFound,
        objectId: '0x1',
        cause: 'transport status',
      );
      expect(result.reason, ObjectErrorReason.notFound);
      expect(result.code, 'notExists');
      expect(result.objectId, '0x1');
      expect(result.cause, 'transport status');
    });

    test('pattern matching works on result variants', () {
      final results = <ObjectResult>[
        ObjectSuccess(
          ObjectData(
            objectId: '0x1',
            version: '1',
            digest: 'abc',
            owner: const ImmutableOwner(),
            type: 'Coin',
          ),
        ),
        const ObjectError('not found'),
      ];

      final messages = results.map((r) {
        return switch (r) {
          ObjectSuccess(:final data) => 'ok:${data.objectId}',
          ObjectError(:final error) => 'err:$error',
        };
      }).toList();

      expect(messages, ['ok:0x1', 'err:not found']);
    });

    test('TransactionError reports the digest it looked up', () {
      const error = TransactionError(TransactionErrorReason.notFound, '0xdead');
      expect(error, isA<Exception>());
      expect(error.message, 'Transaction 0xdead not found');
      expect(error.toString(), contains('0xdead'));
    });
  });

  group('ObjectData', () {
    test('creates with required fields only', () {
      final obj = ObjectData(
        objectId: '0x1',
        version: '10',
        digest: 'abc123',
        owner: const AddressOwner('0xowner'),
        type: '0x2::coin::Coin<0x2::sui::SUI>',
      );
      expect(obj.objectId, '0x1');
      expect(obj.version, '10');
      expect(obj.digest, 'abc123');
      expect(obj.owner, isA<AddressOwner>());
      expect(obj.type, '0x2::coin::Coin<0x2::sui::SUI>');
      expect(obj.content, isNull);
      expect(obj.previousTransaction, isNull);
      expect(obj.objectBcs, isNull);
      expect(obj.json, isNull);
    });

    test('creates with all optional fields', () {
      final obj = ObjectData(
        objectId: '0x1',
        version: '10',
        digest: 'abc123',
        owner: const AddressOwner('0xowner'),
        type: 'SomeType',
        previousTransaction: 'txdigest123',
        content: Uint8List.fromList([1, 2, 3]),
        objectBcs: Uint8List.fromList([4, 5, 6]),
        json: const {
          'fields': {'value': 42},
        },
      );
      expect(obj.previousTransaction, 'txdigest123');
      expect(obj.content, isNotNull);
      expect(obj.content!.length, 3);
      expect(obj.objectBcs, isNotNull);
      expect(obj.objectBcs!.length, 3);
      expect(obj.json, isNotNull);
    });
  });

  group('CoinData', () {
    test('creates with all required fields', () {
      const coin = CoinData(
        objectId: '0xabc',
        version: '5',
        digest: 'digest123',
        owner: AddressOwner('0xowner'),
        type: '0x2::sui::SUI',
        balance: '1000000000',
      );
      expect(coin.objectId, '0xabc');
      expect(coin.version, '5');
      expect(coin.digest, 'digest123');
      expect(coin.owner, isA<AddressOwner>());
      expect(coin.type, '0x2::sui::SUI');
      expect(coin.balance, '1000000000');
    });
  });

  group('Balance', () {
    test('creates with all fields', () {
      const balance = Balance(
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

  group('CoinMetadata', () {
    test('creates with all fields', () {
      const meta = CoinMetadata(
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
      const meta = CoinMetadata(
        id: '0x1',
        decimals: 6,
        name: 'USDC',
        symbol: 'USDC',
        description: 'USD Coin',
      );
      expect(meta.iconUrl, isNull);
    });
  });

  group('TransactionResponse', () {
    test('creates with digest only', () {
      const resp = TransactionResponse(digest: 'txdigest');
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
      final resp = TransactionResponse(
        digest: 'txdigest',
        signatures: const ['sig1', 'sig2'],
        epoch: '100',
        status: const ExecutionStatus(success: true),
        transaction: 'base64tx',
        effects: const TransactionEffects(transactionDigest: 'effectsdigest'),
        events: [
          Event(
            packageId: '0x2',
            module: 'coin',
            sender: '0xsender',
            eventType: '0x2::coin::CoinEvent',
            bcs: Uint8List(0),
          ),
        ],
        balanceChanges: const [
          BalanceChange(address: '0xowner', coinType: 'SUI', amount: '100'),
        ],
        objectTypes: const {'0x1': '0x2::coin::Coin'},
        bcs: Uint8List.fromList([1, 2, 3]),
        checkpoint: '1000',
        timestampMs: '1700000000000',
        commandResults: const [
          CommandResult(returnValues: [], mutatedReferences: []),
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
      const original = TransactionResponse(
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
      final original = TransactionResponse(
        digest: 'txdigest',
        signatures: const ['sig1'],
        epoch: '5',
        effects: const TransactionEffects(lamportVersion: '10'),
        events: [
          Event(
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
          CommandResult(returnValues: [], mutatedReferences: []),
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

  group('TransactionEffects', () {
    test('creates with all null optional fields', () {
      const effects = TransactionEffects();
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
      final effects = TransactionEffects(
        bcs: Uint8List.fromList([1, 2, 3]),
        version: 2,
        transactionDigest: 'txdigest',
        lamportVersion: '50',
        status: const ExecutionStatus(success: true),
        gasUsed: const GasUsed(
          computationCost: '1000',
          storageCost: '2000',
          storageRebate: '500',
          nonRefundableStorageFee: '100',
        ),
        gasObject: const GasObject(
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

  group('ExecutionError and error details', () {
    test('creates error without detail', () {
      const error = ExecutionError(
        message: 'Something failed',
        kind: 'MOVE_ABORT',
      );
      expect(error.message, 'Something failed');
      expect(error.kind, 'MOVE_ABORT');
      expect(error.command, isNull);
      expect(error.detail, isNull);
    });

    test('creates error with command and abort detail', () {
      const error = ExecutionError(
        message: 'Move abort',
        kind: 'MOVE_ABORT',
        command: 0,
        detail: AbortDetail(
          MoveAbort(
            abortCode: '1',
            location: MoveAbortLocation(
              package: '0x2',
              module: 'coin',
              function: 3,
              instruction: 10,
              functionName: 'transfer',
            ),
          ),
        ),
      );
      expect(error.command, 0);
      final detail = error.detail as AbortDetail;
      expect(detail.abort.abortCode, '1');
      expect(detail.abort.location!.package, '0x2');
      expect(detail.abort.location!.functionName, 'transfer');
    });

    test('pattern matching works on all error detail variants', () {
      final details = <ExecutionErrorDetail>[
        const AbortDetail(MoveAbort(abortCode: '1')),
        const SizeErrorDetail(size: '100', maxSize: '50'),
        const CommandArgumentErrorDetail(argument: 0, kind: 'TYPE_MISMATCH'),
        const TypeArgumentErrorDetail(
          typeArgument: 1,
          kind: 'CONSTRAINT_NOT_SATISFIED',
        ),
        const PackageUpgradeErrorDetail(kind: 'INCOMPATIBLE', packageId: '0x5'),
        const IndexErrorDetail(index: 0, subresult: 1),
        const ObjectIdErrorDetail('0xobj'),
        const CoinDenyListErrorDetail(address: '0xaddr', coinType: 'SUI'),
        const CongestedObjectsDetail(['0xa', '0xb']),
      ];

      expect(details.length, 9);

      for (final detail in details) {
        final matched = switch (detail) {
          AbortDetail() => 'abort',
          SizeErrorDetail() => 'size',
          CommandArgumentErrorDetail() => 'cmdArg',
          TypeArgumentErrorDetail() => 'typeArg',
          PackageUpgradeErrorDetail() => 'pkgUpgrade',
          IndexErrorDetail() => 'index',
          ObjectIdErrorDetail() => 'objectId',
          CoinDenyListErrorDetail() => 'coinDeny',
          CongestedObjectsDetail() => 'congested',
        };
        expect(matched.isNotEmpty, true);
      }
    });
  });

  group('MoveAbort', () {
    test('creates with abort code only', () {
      const abort = MoveAbort(abortCode: '42');
      expect(abort.abortCode, '42');
      expect(abort.location, isNull);
      expect(abort.cleverError, isNull);
      expect(abort.cleverErrorRaw, isNull);
    });

    test('creates with location and clever error', () {
      const abort = MoveAbort(
        abortCode: '1',
        location: MoveAbortLocation(
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

  group('ChangedObject', () {
    test('creates with required objectId only', () {
      const obj = ChangedObject(objectId: '0x1');
      expect(obj.objectId, '0x1');
      expect(obj.idOperation, isNull);
      expect(obj.inputOwner, isNull);
      expect(obj.outputOwner, isNull);
    });

    test('creates with full input/output state', () {
      const obj = ChangedObject(
        objectId: '0x1',
        idOperation: 'Created',
        inputState: 'DoesNotExist',
        outputState: 'ObjectWrite',
        outputVersion: '1',
        outputDigest: 'digest',
        outputOwner: AddressOwner('0xowner'),
        objectType: '0x2::coin::Coin<0x2::sui::SUI>',
      );
      expect(obj.idOperation, 'Created');
      expect(obj.inputState, 'DoesNotExist');
      expect(obj.outputOwner, isA<AddressOwner>());
    });
  });

  group('Event', () {
    test('creates with required fields', () {
      final event = Event(
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
      final event = Event(
        packageId: '0x2',
        module: 'coin',
        sender: '0xsender',
        eventType: '0x2::coin::MintEvent',
        bcs: Uint8List.fromList([1, 2, 3, 4]),
      );
      expect(event.bcs.length, 4);
    });
  });

  group('BalanceChange', () {
    test('creates with all required fields', () {
      const change = BalanceChange(
        address: '0xowner',
        coinType: '0x2::sui::SUI',
        amount: '-1000000',
      );
      expect(change.address, '0xowner');
      expect(change.coinType, '0x2::sui::SUI');
      expect(change.amount, '-1000000');
    });
  });

  group('DynamicFieldEntry', () {
    test('creates with all fields', () {
      final entry = DynamicFieldEntry(
        name: DynamicFieldName(type: 'u64', bcs: Uint8List.fromList([1, 2])),
        objectType: '0x2::coin::Coin<0x2::sui::SUI>',
        objectId: '0xchild',
        type: 'DynamicField',
      );
      expect(entry.name.type, 'u64');
      expect(entry.name.bcs!.length, 2);
      expect(entry.objectType, '0x2::coin::Coin<0x2::sui::SUI>');
      expect(entry.type, 'DynamicField');
    });

    test('DynamicFieldName allows null type and bcs', () {
      const name = DynamicFieldName();
      expect(name.type, isNull);
      expect(name.bcs, isNull);
    });
  });

  group('SystemState', () {
    test('creates with required fields', () {
      const state = SystemState(epoch: '100', referenceGasPrice: '750');
      expect(state.epoch, '100');
      expect(state.referenceGasPrice, '750');
      expect(state.systemState, isNull);
      expect(state.epochStartTimestampMs, isNull);
    });

    test('creates with all fields', () {
      const state = SystemState(
        epoch: '100',
        referenceGasPrice: '750',
        systemState: {'validators': []},
        epochStartTimestampMs: '1700000000',
      );
      expect(state.systemState, isNotNull);
      expect(state.epochStartTimestampMs, '1700000000');
    });
  });

  group('VerifySignatureResult', () {
    test('creates valid result', () {
      const result = VerifySignatureResult(isValid: true);
      expect(result.isValid, true);
      expect(result.reason, isNull);
    });

    test('creates invalid result with reason', () {
      const result = VerifySignatureResult(
        isValid: false,
        reason: 'Invalid proof',
      );
      expect(result.isValid, false);
      expect(result.reason, 'Invalid proof');
    });
  });

  group('MoveFunction', () {
    test('creates with all fields', () {
      const func = MoveFunction(
        name: 'transfer',
        visibility: 'Public',
        isEntry: true,
        typeParameters: [
          TypeParameter(abilities: ['Store', 'Key']),
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

  group('CommandResult', () {
    test('creates with empty lists', () {
      const result = CommandResult(returnValues: [], mutatedReferences: []);
      expect(result.returnValues, isEmpty);
      expect(result.mutatedReferences, isEmpty);
    });

    test('creates with values', () {
      final result = CommandResult(
        returnValues: [
          CommandOutput(bcs: Uint8List.fromList([1, 2, 3])),
          CommandOutput(bcs: Uint8List.fromList([4, 5])),
        ],
        mutatedReferences: [
          CommandOutput(bcs: Uint8List.fromList([6, 7, 8])),
        ],
      );
      expect(result.returnValues.length, 2);
      expect(result.returnValues[0].bcs.length, 3);
      expect(result.returnValues[1].bcs.length, 2);
      expect(result.mutatedReferences.length, 1);
    });
  });

  group('UnchangedConsensusObject', () {
    test('creates with required fields', () {
      const obj = UnchangedConsensusObject(objectId: '0x1', version: '10');
      expect(obj.objectId, '0x1');
      expect(obj.version, '10');
      expect(obj.kind, isNull);
      expect(obj.digest, isNull);
    });

    test('creates with all fields', () {
      const obj = UnchangedConsensusObject(
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

  group('GasUsed', () {
    test('stores all gas cost fields as strings', () {
      const gas = GasUsed(
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

  group('ExecutionStatus', () {
    test('creates successful status', () {
      const status = ExecutionStatus(success: true);
      expect(status.success, true);
      expect(status.error, isNull);
    });

    test('creates failed status with error', () {
      const status = ExecutionStatus(
        success: false,
        error: ExecutionError(message: 'Execution failed', kind: 'MOVE_ABORT'),
      );
      expect(status.success, false);
      expect(status.error!.message, 'Execution failed');
    });
  });
}
