// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';
import 'package:sui_dart/bcs/type_tag_serializer.dart';
import 'package:sui_dart/types/common.dart';

class SuiBcs {
  static const SUI_ADDRESS_LENGTH = 32;

  static final U8 = Bcs.u8();
  static final U16 = Bcs.u16();
  static final U32 = Bcs.u32();
  static final U64 = Bcs.u64();
  static final U128 = Bcs.u128();
  static final U256 = Bcs.u256();
  static final ULEB128 = Bcs.uleb128();
  static final BOOL = Bcs.boolean();
  static final STRING = Bcs.string();
  static const VECTOR = Bcs.vector;

  static BcsType<int, dynamic> unsafe_u64([
    BcsTypeOptions<int, dynamic>? options,
  ]) {
    return Bcs.u64(
      BcsTypeOptions(name: 'unsafe_u64', validate: options?.validate),
    ).transform(
      input: (dynamic val) => val is int ? val : int.parse(val.toString()),
      output: (BigInt val) => val.toInt(),
    );
  }

  static BcsType<Map<String, dynamic>, dynamic> OptionEnum<T>(
    BcsType<T, dynamic> type,
  ) {
    return Bcs.enumeration('Option', {'None': null, 'Some': type});
  }

  static final Address = Bcs.bytes(SUI_ADDRESS_LENGTH).transform(
    validate: (dynamic val) {
      final address = val is String ? val : toHEX(val);
      if (address.isEmpty || !isValidSuiAddress(normalizeSuiAddress(address))) {
        throw Exception('Invalid Sui address $address');
      }
    },
    input: (dynamic val) =>
        val is String ? fromHEX(normalizeSuiAddress(val)) : val,
    output: (Uint8List val) => normalizeSuiAddress(toHEX(val)),
  );

  static final ObjectDigest = Bcs.vector(Bcs.u8()).transform(
    name: 'ObjectDigest',
    input: (String value) => fromB58(value),
    output: (List<int> value) => toB58(Uint8List.fromList(value)),
    validate: (String value) {
      if (fromB58(value).length != 32) {
        throw Exception('ObjectDigest must be 32 bytes');
      }
    },
  );

  static final SuiObjectRef = Bcs.struct('SuiObjectRef', {
    'objectId': Address,
    'version': Bcs.u64(),
    'digest': ObjectDigest,
  });

  static final SharedObjectRef = Bcs.struct('SharedObjectRef', {
    'objectId': Address,
    'initialSharedVersion': Bcs.u64(),
    'mutable': Bcs.boolean(),
  });

  static final ObjectArg = Bcs.enumeration('ObjectArg', {
    'ImmOrOwnedObject': SuiObjectRef,
    'SharedObject': SharedObjectRef,
    'Receiving': SuiObjectRef,
  });

  static final Owner = Bcs.enumeration('Owner', {
    'AddressOwner': Address,
    'ObjectOwner': Address,
    'Shared': Bcs.struct('Shared', {'initialSharedVersion': Bcs.u64()}),
    'Immutable': null,
    'ConsensusAddressOwner': Bcs.struct('ConsensusAddressOwner', {
      // Field order is wire-significant (BCS serializes positionally).
      'startVersion': Bcs.u64(),
      'owner': Address,
    }),
  });

  static final Reservation = Bcs.enumeration('Reservation', {
    'MaxAmountU64': Bcs.u64(),
  });

  static final WithdrawalType = Bcs.enumeration('WithdrawalType', {
    'Balance': Bcs.lazy(() => TypeTag),
  });

  static final WithdrawFrom = Bcs.enumeration('WithdrawFrom', {
    'Sender': null,
    'Sponsor': null,
    'SenderAllowance': Bcs.struct('SenderAllowance', {
      'funder': Address,
      'allowance': Address,
    }),
  });

  static final FundsWithdrawal = Bcs.struct('FundsWithdrawal', {
    'reservation': Reservation,
    'typeArg': WithdrawalType,
    'withdrawFrom': WithdrawFrom,
  });

  static final CallArg = Bcs.enumeration('CallArg', {
    'Pure': Bcs.struct('Pure', {
      'bytes': Bcs.vector(Bcs.u8()).transform(
        input: (dynamic val) => val is String ? fromB64(val) : val,
        output: (List<int> val) => toB64(Uint8List.fromList(val)),
      ),
    }),
    'Object': ObjectArg,
    'FundsWithdrawal': FundsWithdrawal,
  });

  static final BcsType<dynamic, dynamic> InnerTypeTag =
      Bcs.enumeration('TypeTag', {
            'bool': null,
            'u8': null,
            'u64': null,
            'u128': null,
            'address': null,
            'signer': null,
            'vector': Bcs.lazy(() => InnerTypeTag),
            'struct': Bcs.lazy(() => StructTag),
            'u16': null,
            'u32': null,
            'u256': null,
          })
          as BcsType<dynamic, dynamic>;

  static final TypeTag = InnerTypeTag.transform(
    input: (dynamic typeTag) => typeTag is String
        ? TypeTagSerializer.parseFromStr(typeTag, true)
        : typeTag,
    output: (dynamic typeTag) => TypeTagSerializer.tagToString(typeTag),
  );

  static final Argument = Bcs.enumeration('Argument', {
    'GasCoin': null,
    'Input': Bcs.u16(),
    'Result': Bcs.u16(),
    'NestedResult': Bcs.tuple([Bcs.u16(), Bcs.u16()]),
  });

  static final ProgrammableMoveCall = Bcs.struct('ProgrammableMoveCall', {
    'package': Address,
    'module': Bcs.string(),
    'function': Bcs.string(),
    'typeArguments': Bcs.vector(TypeTag),
    'arguments': Bcs.vector(Argument),
  });

  static final Command = Bcs.enumeration('Command', {
    'MoveCall': ProgrammableMoveCall,
    'TransferObjects': Bcs.struct('TransferObjects', {
      'objects': Bcs.vector(Argument),
      'address': Argument,
    }),
    'SplitCoins': Bcs.struct('SplitCoins', {
      'coin': Argument,
      'amounts': Bcs.vector(Argument),
    }),
    'MergeCoins': Bcs.struct('MergeCoins', {
      'destination': Argument,
      'sources': Bcs.vector(Argument),
    }),
    'Publish': Bcs.struct('Publish', {
      'modules': Bcs.vector(
        Bcs.vector(Bcs.u8()).transform(
          input: (dynamic val) => val is String ? fromB64(val) : val,
          output: (List<int> val) => toB64(Uint8List.fromList(val)),
        ),
      ),
      'dependencies': Bcs.vector(Address),
    }),
    'MakeMoveVec': Bcs.struct('MakeMoveVec', {
      'type': OptionEnum(TypeTag).transform(
        input: (dynamic val) => val == null ? {'None': true} : {'Some': val},
        output: (Map<String, dynamic> val) => val['Some'],
      ),
      'elements': Bcs.vector(Argument),
    }),
    'Upgrade': Bcs.struct('Upgrade', {
      'modules': Bcs.vector(
        Bcs.vector(Bcs.u8()).transform(
          input: (dynamic val) => val is String ? fromB64(val) : val,
          output: (List<int> val) => toB64(Uint8List.fromList(val)),
        ),
      ),
      'dependencies': Bcs.vector(Address),
      'package': Address,
      'ticket': Argument,
    }),
  });

  static final ProgrammableTransaction = Bcs.struct('ProgrammableTransaction', {
    'inputs': Bcs.vector(CallArg),
    'commands': Bcs.vector(Command),
  });

  static final ChangeEpoch = Bcs.struct('ChangeEpoch', {
    'epoch': Bcs.u64(),
    'protocolVersion': Bcs.u64(),
    'storageCharge': Bcs.u64(),
    'computationCharge': Bcs.u64(),
    'storageRebate': Bcs.u64(),
    'nonRefundableStorageFee': Bcs.u64(),
    'epochStartTimestampMs': Bcs.u64(),
    'systemPackages': Bcs.vector(
      Bcs.tuple([Bcs.u64(), Bcs.vector(Bcs.byteVector()), Bcs.vector(Address)]),
    ),
  });

  static final GenesisObject = Bcs.enumeration('GenesisObject', {
    'RawObject': Bcs.struct('RawObject', {
      'data': Bcs.lazy(() => Data),
      'owner': Owner,
    }),
  });

  static final GenesisTransaction = Bcs.struct('GenesisTransaction', {
    'objects': Bcs.vector(GenesisObject),
  });

  static final ConsensusCommitPrologue = Bcs.struct('ConsensusCommitPrologue', {
    'epoch': Bcs.u64(),
    'round': Bcs.u64(),
    'commitTimestampMs': Bcs.u64(),
  });

  static final ConsensusCommitPrologueV2 =
      Bcs.struct('ConsensusCommitPrologueV2', {
        'epoch': Bcs.u64(),
        'round': Bcs.u64(),
        'commitTimestampMs': Bcs.u64(),
        'consensusCommitDigest': ObjectDigest,
      });

  static final ConsensusDeterminedVersionAssignments = Bcs.enumeration(
    'ConsensusDeterminedVersionAssignments',
    {
      'CancelledTransactions': Bcs.vector(
        Bcs.tuple([
          ObjectDigest,
          Bcs.vector(Bcs.tuple([Address, Bcs.u64()])),
        ]),
      ),
      'CancelledTransactionsV2': Bcs.vector(
        Bcs.tuple([
          ObjectDigest,
          Bcs.vector(
            Bcs.tuple([
              Bcs.tuple([Address, Bcs.u64()]),
              Bcs.u64(),
            ]),
          ),
        ]),
      ),
    },
  );

  static final ConsensusCommitPrologueV3 =
      Bcs.struct('ConsensusCommitPrologueV3', {
        'epoch': Bcs.u64(),
        'round': Bcs.u64(),
        'subDagIndex': Bcs.option(Bcs.u64()),
        'commitTimestampMs': Bcs.u64(),
        'consensusCommitDigest': ObjectDigest,
        'consensusDeterminedVersionAssignments':
            ConsensusDeterminedVersionAssignments,
      });

  static final ConsensusCommitPrologueV4 =
      Bcs.struct('ConsensusCommitPrologueV4', {
        'epoch': Bcs.u64(),
        'round': Bcs.u64(),
        'subDagIndex': Bcs.option(Bcs.u64()),
        'commitTimestampMs': Bcs.u64(),
        'consensusCommitDigest': ObjectDigest,
        'consensusDeterminedVersionAssignments':
            ConsensusDeterminedVersionAssignments,
        'additionalStateDigest': ObjectDigest,
      });

  static final ActiveJwk = Bcs.struct('ActiveJwk', {
    'jwkId': Bcs.struct('JwkId', {'iss': Bcs.string(), 'kid': Bcs.string()}),
    'jwk': Bcs.struct('JWK', {
      'kty': Bcs.string(),
      'e': Bcs.string(),
      'n': Bcs.string(),
      'alg': Bcs.string(),
    }),
    'epoch': Bcs.u64(),
  });

  static final AuthenticatorStateUpdate =
      Bcs.struct('AuthenticatorStateUpdate', {
        'epoch': Bcs.u64(),
        'round': Bcs.u64(),
        'newActiveJwks': Bcs.vector(ActiveJwk),
        'authenticatorObjInitialSharedVersion': Bcs.u64(),
      });

  static final RandomnessStateUpdate = Bcs.struct('RandomnessStateUpdate', {
    'epoch': Bcs.u64(),
    'randomnessRound': Bcs.u64(),
    'randomBytes': Bcs.byteVector(),
    'randomnessObjInitialSharedVersion': Bcs.u64(),
  });

  static final AuthenticatorStateExpire = Bcs.struct(
    'AuthenticatorStateExpire',
    {'minEpoch': Bcs.u64(), 'authenticatorObjInitialSharedVersion': Bcs.u64()},
  );

  static final ExecutionTimeObservationKey = Bcs.enumeration(
    'ExecutionTimeObservationKey',
    {
      'MoveEntryPoint': Bcs.struct('MoveEntryPoint', {
        'package': Address,
        'module': Bcs.string(),
        'function': Bcs.string(),
        'typeArguments': Bcs.vector(TypeTag),
      }),
      'TransferObjects': null,
      'SplitCoins': null,
      'MergeCoins': null,
      'Publish': null,
      'MakeMoveVec': null,
      'Upgrade': null,
    },
  );

  static final StoredExecutionTimeObservations = Bcs.enumeration(
    'StoredExecutionTimeObservations',
    {
      'V1': Bcs.vector(
        Bcs.tuple([
          ExecutionTimeObservationKey,
          Bcs.vector(
            Bcs.tuple([
              // AuthorityName: BLS public key bytes.
              Bcs.byteVector(),
              Bcs.struct('Duration', {'secs': Bcs.u64(), 'nanos': Bcs.u32()}),
            ]),
          ),
        ]),
      ),
    },
  );

  static final WriteAccumulatorStorageCost = Bcs.struct(
    'WriteAccumulatorStorageCost',
    {'storageCost': Bcs.u64()},
  );

  static final EndOfEpochTransactionKind = Bcs.enumeration(
    'EndOfEpochTransactionKind',
    {
      'ChangeEpoch': ChangeEpoch,
      'AuthenticatorStateCreate': null,
      'AuthenticatorStateExpire': AuthenticatorStateExpire,
      'RandomnessStateCreate': null,
      'DenyListStateCreate': null,
      // The chain identifier (the genesis checkpoint digest).
      'BridgeStateCreate': ObjectDigest,
      'BridgeCommitteeInit': Bcs.u64(),
      'StoreExecutionTimeObservations': StoredExecutionTimeObservations,
      'AccumulatorRootCreate': null,
      'CoinRegistryCreate': null,
      'DisplayRegistryCreate': null,
      'AddressAliasStateCreate': null,
      'WriteAccumulatorStorageCost': WriteAccumulatorStorageCost,
      'ForwardingAddressRegistryCreate': null,
    },
  );

  static final TransactionKind = Bcs.enumeration('TransactionKind', {
    'ProgrammableTransaction': ProgrammableTransaction,
    'ChangeEpoch': ChangeEpoch,
    'Genesis': GenesisTransaction,
    'ConsensusCommitPrologue': ConsensusCommitPrologue,
    'AuthenticatorStateUpdate': AuthenticatorStateUpdate,
    'EndOfEpochTransaction': Bcs.vector(EndOfEpochTransactionKind),
    'RandomnessStateUpdate': RandomnessStateUpdate,
    'ConsensusCommitPrologueV2': ConsensusCommitPrologueV2,
    'ConsensusCommitPrologueV3': ConsensusCommitPrologueV3,
    'ConsensusCommitPrologueV4': ConsensusCommitPrologueV4,
    'ProgrammableSystemTransaction': ProgrammableTransaction,
  });

  static final ValidDuring = Bcs.struct('ValidDuring', {
    'minEpoch': Bcs.option(Bcs.u64()),
    'maxEpoch': Bcs.option(Bcs.u64()),
    'minTimestamp': Bcs.option(Bcs.u64()),
    'maxTimestamp': Bcs.option(Bcs.u64()),
    'chain': ObjectDigest,
    'nonce': Bcs.u32(),
  });

  static List<dynamic> assertAllowedProposersNotEmpty(List<dynamic> proposers) {
    if (proposers.isEmpty) {
      throw ArgumentError('Allowed proposers must not be empty');
    }
    return proposers;
  }

  static List<dynamic> assertAllowedProposersStrictlyIncreasing(
    List<dynamic> proposers,
  ) {
    assertAllowedProposersNotEmpty(proposers);
    for (var i = 1; i < proposers.length; i++) {
      if ((proposers[i] as num) <= (proposers[i - 1] as num)) {
        throw ArgumentError('Allowed proposers must be strictly increasing');
      }
    }
    return proposers;
  }

  static final AllowedProposers = Bcs.struct('AllowedProposers', {
    'epoch': Bcs.u64(),
    // decode allows unsorted (chain checks order at submit), never empty
    'proposers': Bcs.vector(Bcs.u32()).transform(
      input: (dynamic proposers) =>
          assertAllowedProposersStrictlyIncreasing(proposers as List),
      output: (List<int> proposers) {
        assertAllowedProposersNotEmpty(proposers);
        return proposers;
      },
    ),
  });

  static final Validity = Bcs.struct('Validity', {
    'minEpoch': Bcs.option(Bcs.u64()),
    'maxEpoch': Bcs.option(Bcs.u64()),
    'minTimestamp': Bcs.option(Bcs.u64()),
    'maxTimestamp': Bcs.option(Bcs.u64()),
    'chain': ObjectDigest,
    'nonce': Bcs.u32(),
    'allowedProposers': Bcs.option(AllowedProposers),
  });

  static final TransactionExpiration =
      Bcs.enumeration('TransactionExpiration', {
        'None': null,
        'Epoch': unsafe_u64(),
        'ValidDuring': ValidDuring,
        'Validity': Validity,
      });

  static final StructTag = Bcs.struct('StructTag', {
    'address': Address,
    'module': Bcs.string(),
    'name': Bcs.string(),
    'typeParams': Bcs.vector(InnerTypeTag),
  });

  static final GasData = Bcs.struct('GasData', {
    'payment': Bcs.vector(SuiObjectRef),
    'owner': Address,
    'price': Bcs.u64(),
    'budget': Bcs.u64(),
  });

  static final TransactionDataV1 = Bcs.struct('TransactionDataV1', {
    'kind': TransactionKind,
    'sender': Address,
    'gasData': GasData,
    'expiration': TransactionExpiration,
  });

  static final TransactionData = Bcs.enumeration('TransactionData', {
    'V1': TransactionDataV1,
  });

  static final IntentScope = Bcs.enumeration('IntentScope', {
    'TransactionData': null,
    'TransactionEffects': null,
    'CheckpointSummary': null,
    'PersonalMessage': null,
  });

  static final IntentVersion = Bcs.enumeration('IntentVersion', {'V0': null});

  static final AppId = Bcs.enumeration('AppId', {'Sui': null});

  static final Intent = Bcs.struct('Intent', {
    'scope': IntentScope,
    'version': IntentVersion,
    'appId': AppId,
  });

  static BcsType<Map<String, dynamic>, dynamic> IntentMessage<T>(
    BcsType<T, dynamic> T,
  ) {
    return Bcs.struct('IntentMessage<${T.name}>', {
      'intent': Intent,
      'value': T,
    });
  }

  static final CompressedSignature = Bcs.enumeration('CompressedSignature', {
    'Ed25519': Bcs.fixedArray(64, Bcs.u8()),
    'Secp256k1': Bcs.fixedArray(64, Bcs.u8()),
    'Secp256r1': Bcs.fixedArray(64, Bcs.u8()),
    'ZkLogin': Bcs.vector(Bcs.u8()),
    'Passkey': Bcs.vector(Bcs.u8()),
  });

  static final PublicKey = Bcs.enumeration('PublicKey', {
    'Ed25519': Bcs.fixedArray(32, Bcs.u8()),
    'Secp256k1': Bcs.fixedArray(33, Bcs.u8()),
    'Secp256r1': Bcs.fixedArray(33, Bcs.u8()),
    'ZkLogin': Bcs.vector(Bcs.u8()),
    'Passkey': Bcs.fixedArray(33, Bcs.u8()),
  });

  static final MultiSigPkMap = Bcs.struct('MultiSigPkMap', {
    'pubKey': PublicKey,
    'weight': Bcs.u8(),
  });

  static final MultiSigPublicKey = Bcs.struct('MultiSigPublicKey', {
    'pk_map': Bcs.vector(MultiSigPkMap),
    'threshold': Bcs.u16(),
  });

  static final MultiSig = Bcs.struct('MultiSig', {
    'sigs': Bcs.vector(CompressedSignature),
    'bitmap': Bcs.u16(),
    'multisig_pk': MultiSigPublicKey,
  });

  static final base64String = Bcs.vector(Bcs.u8()).transform(
    input: (dynamic val) => val is String ? fromB64(val) : val,
    output: (List<int> val) => toB64(Uint8List.fromList(val)),
  );

  static final SenderSignedTransaction = Bcs.struct('SenderSignedTransaction', {
    'intentMessage': IntentMessage(TransactionData),
    'txSignatures': Bcs.vector(base64String),
  });

  static final SenderSignedData = Bcs.vector(
    SenderSignedTransaction,
    BcsTypeOptions(name: 'SenderSignedData'),
  );

  static final PasskeyAuthenticator = Bcs.struct('PasskeyAuthenticator', {
    'authenticatorData': Bcs.vector(Bcs.u8()),
    'clientDataJson': Bcs.string(),
    'userSignature': Bcs.vector(Bcs.u8()),
  });

  // Object BCS schema.
  static final MoveObjectType = Bcs.enumeration('MoveObjectType', {
    'Other': StructTag,
    'GasCoin': null,
    'StakedSui': null,
    'Coin': TypeTag,
    'AccumulatorBalanceWrapper': null,
  });

  static final TypeOrigin = Bcs.struct('TypeOrigin', {
    'moduleName': Bcs.string(),
    'datatypeName': Bcs.string(),
    'package': Address,
  });

  static final UpgradeInfo = Bcs.struct('UpgradeInfo', {
    'upgradedId': Address,
    'upgradedVersion': Bcs.u64(),
  });

  static final MovePackage = Bcs.struct('MovePackage', {
    'id': Address,
    'version': Bcs.u64(),
    'moduleMap': Bcs.map(Bcs.string(), Bcs.vector(Bcs.u8())),
    'typeOriginTable': Bcs.vector(TypeOrigin),
    'linkageTable': Bcs.map(Address, UpgradeInfo),
  });

  static final MoveObject = Bcs.struct('MoveObject', {
    'type': MoveObjectType,
    'hasPublicTransfer': Bcs.boolean(),
    'version': Bcs.u64(),
    'contents': Bcs.vector(Bcs.u8()),
  });

  static final Data = Bcs.enumeration('Data', {
    'Move': MoveObject,
    'Package': MovePackage,
  });

  static final ObjectInner = Bcs.struct('ObjectInner', {
    'data': Data,
    'owner': Owner,
    'previousTransaction': ObjectDigest,
    'storageRebate': Bcs.u64(),
  });
}
