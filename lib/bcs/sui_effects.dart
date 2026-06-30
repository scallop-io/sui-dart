// ignore_for_file: non_constant_identifier_names
import 'package:bcs_dart/bcs.dart';
import 'package:sui_dart/bcs/sui_bcs.dart';

class SuiEffects {
  static final PackageUpgradeError = Bcs.enumeration('PackageUpgradeError', {
    'UnableToFetchPackage': Bcs.struct('UnableToFetchPackage', {
      'packageId': SuiBcs.Address,
    }),
    'NotAPackage': Bcs.struct('NotAPackage', {'objectId': SuiBcs.Address}),
    'IncompatibleUpgrade': null,
    'DigestDoesNotMatch': Bcs.struct('DigestDoesNotMatch', {
      'digest': Bcs.vector(Bcs.u8()),
    }),
    'UnknownUpgradePolicy': Bcs.struct('UnknownUpgradePolicy', {
      'policy': Bcs.u8(),
    }),
    'PackageIDDoesNotMatch': Bcs.struct('PackageIDDoesNotMatch', {
      'packageId': SuiBcs.Address,
      'ticketId': SuiBcs.Address,
    }),
  });

  static final ModuleId = Bcs.struct('ModuleId', {
    'address': SuiBcs.Address,
    'name': Bcs.string(),
  });

  static final MoveLocation = Bcs.struct('MoveLocation', {
    'module': ModuleId,
    'function': Bcs.u16(),
    'instruction': Bcs.u16(),
    'functionName': Bcs.option(Bcs.string()),
  });

  static final CommandArgumentError = Bcs.enumeration('CommandArgumentError', {
    'TypeMismatch': null,
    'InvalidBCSBytes': null,
    'InvalidUsageOfPureArg': null,
    'InvalidArgumentToPrivateEntryFunction': null,
    'IndexOutOfBounds': Bcs.struct('IndexOutOfBounds', {'idx': Bcs.u16()}),
    'SecondaryIndexOutOfBounds': Bcs.struct('SecondaryIndexOutOfBounds', {
      'resultIdx': Bcs.u16(),
      'secondaryIdx': Bcs.u16(),
    }),
    'InvalidResultArity': Bcs.struct('InvalidResultArity', {
      'resultIdx': Bcs.u16(),
    }),
    'InvalidGasCoinUsage': null,
    'InvalidValueUsage': null,
    'InvalidObjectByValue': null,
    'InvalidObjectByMutRef': null,
    'SharedObjectOperationNotAllowed': null,
    'InvalidArgumentArity': null,
    'InvalidTransferObject': null,
    'InvalidMakeMoveVecNonObjectArgument': null,
    'ArgumentWithoutValue': null,
    'CannotMoveBorrowedValue': null,
    'CannotWriteToExtendedReference': null,
    'InvalidReferenceArgument': null,
  });

  static final TypeArgumentError = Bcs.enumeration('TypeArgumentError', {
    'TypeNotFound': null,
    'ConstraintNotSatisfied': null,
  });

  static final ExecutionFailureStatus = Bcs.enumeration(
    'ExecutionFailureStatus',
    {
      'InsufficientGas': null,
      'InvalidGasObject': null,
      'InvariantViolation': null,
      'FeatureNotYetSupported': null,
      'MoveObjectTooBig': Bcs.struct('MoveObjectTooBig', {
        'objectSize': Bcs.u64(),
        'maxObjectSize': Bcs.u64(),
      }),
      'MovePackageTooBig': Bcs.struct('MovePackageTooBig', {
        'objectSize': Bcs.u64(),
        'maxObjectSize': Bcs.u64(),
      }),
      'CircularObjectOwnership': Bcs.struct('CircularObjectOwnership', {
        'object': SuiBcs.Address,
      }),
      'InsufficientCoinBalance': null,
      'CoinBalanceOverflow': null,
      'PublishErrorNonZeroAddress': null,
      'SuiMoveVerificationError': null,
      'MovePrimitiveRuntimeError': Bcs.option(MoveLocation),
      'MoveAbort': Bcs.tuple([MoveLocation, Bcs.u64()]),
      'VMVerificationOrDeserializationError': null,
      'VMInvariantViolation': null,
      'FunctionNotFound': null,
      'ArityMismatch': null,
      'TypeArityMismatch': null,
      'NonEntryFunctionInvoked': null,
      'CommandArgumentError': Bcs.struct('CommandArgumentError', {
        'argIdx': Bcs.u16(),
        'kind': CommandArgumentError,
      }),
      'TypeArgumentError': Bcs.struct('TypeArgumentError', {
        'argumentIdx': Bcs.u16(),
        'kind': TypeArgumentError,
      }),
      'UnusedValueWithoutDrop': Bcs.struct('UnusedValueWithoutDrop', {
        'resultIdx': Bcs.u16(),
        'secondaryIdx': Bcs.u16(),
      }),
      'InvalidPublicFunctionReturnType': Bcs.struct(
        'InvalidPublicFunctionReturnType',
        {'idx': Bcs.u16()},
      ),
      'InvalidTransferObject': null,
      'EffectsTooLarge': Bcs.struct('EffectsTooLarge', {
        'currentSize': Bcs.u64(),
        'maxSize': Bcs.u64(),
      }),
      'PublishUpgradeMissingDependency': null,
      'PublishUpgradeDependencyDowngrade': null,
      'PackageUpgradeError': Bcs.struct('PackageUpgradeError', {
        'upgradeError': PackageUpgradeError,
      }),
      'WrittenObjectsTooLarge': Bcs.struct('WrittenObjectsTooLarge', {
        'currentSize': Bcs.u64(),
        'maxSize': Bcs.u64(),
      }),
      'CertificateDenied': null,
      'SuiMoveVerificationTimedout': null,
      'SharedObjectOperationNotAllowed': null,
      'InputObjectDeleted': null,
      'ExecutionCancelledDueToSharedObjectCongestion': Bcs.struct(
        'ExecutionCancelledDueToSharedObjectCongestion',
      {'congested_objects': Bcs.vector(SuiBcs.Address)},
      ),
      'AddressDeniedForCoin': Bcs.struct('AddressDeniedForCoin', {
        'address': SuiBcs.Address,
        'coinType': Bcs.string(),
      }),
      'CoinTypeGlobalPause': Bcs.struct('CoinTypeGlobalPause', {
        'coinType': Bcs.string(),
      }),
      'ExecutionCancelledDueToRandomnessUnavailable': null,
    'MoveVectorElemTooBig': Bcs.struct('MoveVectorElemTooBig', {
      'valueSize': Bcs.u64(),
      'maxScaledSize': Bcs.u64(),
    }),
    'MoveRawValueTooBig': Bcs.struct('MoveRawValueTooBig', {
      'valueSize': Bcs.u64(),
      'maxScaledSize': Bcs.u64(),
    }),
    'InvalidLinkage': null,
    'InsufficientBalanceForWithdraw': null,
    'NonExclusiveWriteInputObjectModified': Bcs.struct('NonExclusiveWriteInputObjectModified', {
      'id': SuiBcs.Address,
    }),
    },
  );

  static final ExecutionStatus = Bcs.enumeration('ExecutionStatus', {
    'Success': null,
    'Failure': Bcs.struct('Failure', {
      'error': ExecutionFailureStatus,
      'command': Bcs.option(Bcs.u64()),
    }),
  });

  static final GasCostSummary = Bcs.struct('GasCostSummary', {
    'computationCost': Bcs.u64(),
    'storageCost': Bcs.u64(),
    'storageRebate': Bcs.u64(),
    'nonRefundableStorageFee': Bcs.u64(),
  });

  static final TransactionEffectsV1 = Bcs.struct('TransactionEffectsV1', {
    'status': ExecutionStatus,
    'executedEpoch': Bcs.u64(),
    'gasUsed': GasCostSummary,
    'modifiedAtVersions': Bcs.vector(Bcs.tuple([SuiBcs.Address, Bcs.u64()])),
    'sharedObjects': Bcs.vector(SuiBcs.SuiObjectRef),
    'transactionDigest': SuiBcs.ObjectDigest,
    'created': Bcs.vector(Bcs.tuple([SuiBcs.SuiObjectRef, SuiBcs.Owner])),
    'mutated': Bcs.vector(Bcs.tuple([SuiBcs.SuiObjectRef, SuiBcs.Owner])),
    'unwrapped': Bcs.vector(Bcs.tuple([SuiBcs.SuiObjectRef, SuiBcs.Owner])),
    'deleted': Bcs.vector(SuiBcs.SuiObjectRef),
    'unwrappedThenDeleted': Bcs.vector(SuiBcs.SuiObjectRef),
    'wrapped': Bcs.vector(SuiBcs.SuiObjectRef),
    'gasObject': Bcs.tuple([SuiBcs.SuiObjectRef, SuiBcs.Owner]),
    'eventsDigest': Bcs.option(SuiBcs.ObjectDigest),
    'dependencies': Bcs.vector(SuiBcs.ObjectDigest),
  });

  static final VersionDigest = Bcs.tuple([Bcs.u64(), SuiBcs.ObjectDigest]);

  static final ObjectIn = Bcs.enumeration('ObjectIn', {
    'NotExist': null,
    'Exist': Bcs.tuple([VersionDigest, SuiBcs.Owner]),
  });

  static final AccumulatorAddress = Bcs.struct('AccumulatorAddress', {
    'address': SuiBcs.Address,
    'ty': SuiBcs.TypeTag,
  });

  static final AccumulatorOperation = Bcs.enumeration('AccumulatorOperation', {
    'Merge': null,
    'Split': null,
  });

  static final AccumulatorValue = Bcs.enumeration('AccumulatorValue', {
    'Integer': Bcs.u64(),
    'IntegerTuple': Bcs.tuple([Bcs.u64(), Bcs.u64()]),
    // Non-empty: must have >=1 element.
    'EventDigest': Bcs.vector(Bcs.tuple([Bcs.u64(), SuiBcs.ObjectDigest])),
  });

  static final AccumulatorWriteV1 = Bcs.struct('AccumulatorWriteV1', {
    'address': AccumulatorAddress,
    'operation': AccumulatorOperation,
    'value': AccumulatorValue,
  });

  static final ObjectOut = Bcs.enumeration('ObjectOut', {
    'NotExist': null,
    'ObjectWrite': Bcs.tuple([SuiBcs.ObjectDigest, SuiBcs.Owner]),
    'PackageWrite': VersionDigest,
    'AccumulatorWriteV1': AccumulatorWriteV1,
  });

  static final IDOperation = Bcs.enumeration('IDOperation', {
    'None': null,
    'Created': null,
    'Deleted': null,
  });

  static final EffectsObjectChange = Bcs.struct('EffectsObjectChange', {
    'inputState': ObjectIn,
    'outputState': ObjectOut,
    'idOperation': IDOperation,
  });

  static final UnchangedConsensusKind = Bcs.enumeration('UnchangedConsensusKind', {
    'ReadOnlyRoot': VersionDigest,
    'MutateConsensusStreamEnded': Bcs.u64(),
    'ReadConsensusStreamEnded': Bcs.u64(),
    'Cancelled': Bcs.u64(),
    'PerEpochConfig': null,
  });

  static final TransactionEffectsV2 = Bcs.struct('TransactionEffectsV2', {
    'status': ExecutionStatus,
    'executedEpoch': Bcs.u64(),
    'gasUsed': GasCostSummary,
    'transactionDigest': SuiBcs.ObjectDigest,
    'gasObjectIndex': Bcs.option(Bcs.u32()),
    'eventsDigest': Bcs.option(SuiBcs.ObjectDigest),
    'dependencies': Bcs.vector(SuiBcs.ObjectDigest),
    'lamportVersion': Bcs.u64(),
    'changedObjects': Bcs.vector(
      Bcs.tuple([SuiBcs.Address, EffectsObjectChange]),
    ),
    'unchangedConsensusObjects': Bcs.vector(Bcs.tuple([SuiBcs.Address, UnchangedConsensusKind]),
    ),
    'auxDataDigest': Bcs.option(SuiBcs.ObjectDigest),
  });

  // Version-tagged enum (V1|V2), not a struct: a struct would emit both back-to-back.
  static final TransactionEffects = Bcs.enumeration('TransactionEffects', {
    'V1': TransactionEffectsV1,
    'V2': TransactionEffectsV2,
  });
}
