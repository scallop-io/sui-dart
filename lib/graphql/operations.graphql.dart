// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
import 'package:gql/ast.dart';
import 'schema.graphql.dart';

class Fragment$TransactionHistoryFields {
  Fragment$TransactionHistoryFields({
    required this.digest,
    this.sender,
    this.kind,
    this.effects,
  });

  factory Fragment$TransactionHistoryFields.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$digest = json['digest'];
    final l$sender = json['sender'];
    final l$kind = json['kind'];
    final l$effects = json['effects'];
    return Fragment$TransactionHistoryFields(
      digest: (l$digest as String),
      sender: l$sender == null
          ? null
          : Fragment$TransactionHistoryFields$sender.fromJson(
              (l$sender as Map<String, dynamic>),
            ),
      kind: l$kind == null
          ? null
          : Fragment$TransactionHistoryFields$kind.fromJson(
              (l$kind as Map<String, dynamic>),
            ),
      effects: l$effects == null
          ? null
          : Fragment$TransactionHistoryFields$effects.fromJson(
              (l$effects as Map<String, dynamic>),
            ),
    );
  }

  final String digest;

  final Fragment$TransactionHistoryFields$sender? sender;

  final Fragment$TransactionHistoryFields$kind? kind;

  final Fragment$TransactionHistoryFields$effects? effects;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$digest = digest;
    _resultData['digest'] = l$digest;
    final l$sender = sender;
    _resultData['sender'] = l$sender?.toJson();
    final l$kind = kind;
    _resultData['kind'] = l$kind?.toJson();
    final l$effects = effects;
    _resultData['effects'] = l$effects?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$digest = digest;
    final l$sender = sender;
    final l$kind = kind;
    final l$effects = effects;
    return Object.hashAll([l$digest, l$sender, l$kind, l$effects]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$TransactionHistoryFields ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$digest = digest;
    final lOther$digest = other.digest;
    if (l$digest != lOther$digest) {
      return false;
    }
    final l$sender = sender;
    final lOther$sender = other.sender;
    if (l$sender != lOther$sender) {
      return false;
    }
    final l$kind = kind;
    final lOther$kind = other.kind;
    if (l$kind != lOther$kind) {
      return false;
    }
    final l$effects = effects;
    final lOther$effects = other.effects;
    if (l$effects != lOther$effects) {
      return false;
    }
    return true;
  }
}

const fragmentDefinitionTransactionHistoryFields = FragmentDefinitionNode(
  name: NameNode(value: 'TransactionHistoryFields'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Transaction'), isNonNull: false),
  ),
  directives: [],
  selectionSet: SelectionSetNode(
    selections: [
      FieldNode(
        name: NameNode(value: 'digest'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'sender'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(
          selections: [
            FieldNode(
              name: NameNode(value: 'address'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
          ],
        ),
      ),
      FieldNode(
        name: NameNode(value: 'kind'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(
          selections: [
            FieldNode(
              name: NameNode(value: '__typename'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            InlineFragmentNode(
              typeCondition: TypeConditionNode(
                on: NamedTypeNode(
                  name: NameNode(value: 'ProgrammableTransaction'),
                  isNonNull: false,
                ),
              ),
              directives: [],
              selectionSet: SelectionSetNode(
                selections: [
                  FieldNode(
                    name: NameNode(value: 'commands'),
                    alias: null,
                    arguments: [
                      ArgumentNode(
                        name: NameNode(value: 'first'),
                        value: IntValueNode(value: '50'),
                      ),
                    ],
                    directives: [],
                    selectionSet: SelectionSetNode(
                      selections: [
                        FieldNode(
                          name: NameNode(value: 'pageInfo'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: SelectionSetNode(
                            selections: [
                              FieldNode(
                                name: NameNode(value: 'hasNextPage'),
                                alias: null,
                                arguments: [],
                                directives: [],
                                selectionSet: null,
                              ),
                            ],
                          ),
                        ),
                        FieldNode(
                          name: NameNode(value: 'nodes'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: SelectionSetNode(
                            selections: [
                              FieldNode(
                                name: NameNode(value: '__typename'),
                                alias: null,
                                arguments: [],
                                directives: [],
                                selectionSet: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      FieldNode(
        name: NameNode(value: 'effects'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(
          selections: [
            FieldNode(
              name: NameNode(value: 'timestamp'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'status'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'gasEffects'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: SelectionSetNode(
                selections: [
                  FieldNode(
                    name: NameNode(value: 'gasSummary'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(
                      selections: [
                        FieldNode(
                          name: NameNode(value: 'computationCost'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                        FieldNode(
                          name: NameNode(value: 'storageCost'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                        FieldNode(
                          name: NameNode(value: 'storageRebate'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FieldNode(
              name: NameNode(value: 'balanceChanges'),
              alias: null,
              arguments: [
                ArgumentNode(
                  name: NameNode(value: 'first'),
                  value: IntValueNode(value: '50'),
                ),
              ],
              directives: [
                DirectiveNode(
                  name: NameNode(value: 'include'),
                  arguments: [
                    ArgumentNode(
                      name: NameNode(value: 'if'),
                      value: VariableNode(
                        name: NameNode(value: 'showBalanceChanges'),
                      ),
                    ),
                  ],
                ),
              ],
              selectionSet: SelectionSetNode(
                selections: [
                  FieldNode(
                    name: NameNode(value: 'pageInfo'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(
                      selections: [
                        FieldNode(
                          name: NameNode(value: 'hasNextPage'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                      ],
                    ),
                  ),
                  FieldNode(
                    name: NameNode(value: 'nodes'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(
                      selections: [
                        FieldNode(
                          name: NameNode(value: 'amount'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                        FieldNode(
                          name: NameNode(value: 'coinType'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: SelectionSetNode(
                            selections: [
                              FieldNode(
                                name: NameNode(value: 'repr'),
                                alias: null,
                                arguments: [],
                                directives: [],
                                selectionSet: null,
                              ),
                            ],
                          ),
                        ),
                        FieldNode(
                          name: NameNode(value: 'owner'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: SelectionSetNode(
                            selections: [
                              FieldNode(
                                name: NameNode(value: 'address'),
                                alias: null,
                                arguments: [],
                                directives: [],
                                selectionSet: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FieldNode(
              name: NameNode(value: 'objectChanges'),
              alias: null,
              arguments: [
                ArgumentNode(
                  name: NameNode(value: 'first'),
                  value: IntValueNode(value: '50'),
                ),
              ],
              directives: [
                DirectiveNode(
                  name: NameNode(value: 'include'),
                  arguments: [
                    ArgumentNode(
                      name: NameNode(value: 'if'),
                      value: VariableNode(
                        name: NameNode(value: 'showObjectChanges'),
                      ),
                    ),
                  ],
                ),
              ],
              selectionSet: SelectionSetNode(
                selections: [
                  FieldNode(
                    name: NameNode(value: 'pageInfo'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(
                      selections: [
                        FieldNode(
                          name: NameNode(value: 'hasNextPage'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                      ],
                    ),
                  ),
                  FieldNode(
                    name: NameNode(value: 'nodes'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(
                      selections: [
                        FieldNode(
                          name: NameNode(value: 'address'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                        FieldNode(
                          name: NameNode(value: 'idCreated'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                        FieldNode(
                          name: NameNode(value: 'idDeleted'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                        FieldNode(
                          name: NameNode(value: 'inputState'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: SelectionSetNode(
                            selections: [
                              FieldNode(
                                name: NameNode(value: 'owner'),
                                alias: null,
                                arguments: [],
                                directives: [],
                                selectionSet: SelectionSetNode(
                                  selections: [
                                    FieldNode(
                                      name: NameNode(value: '__typename'),
                                      alias: null,
                                      arguments: [],
                                      directives: [],
                                      selectionSet: null,
                                    ),
                                    InlineFragmentNode(
                                      typeCondition: TypeConditionNode(
                                        on: NamedTypeNode(
                                          name: NameNode(value: 'AddressOwner'),
                                          isNonNull: false,
                                        ),
                                      ),
                                      directives: [],
                                      selectionSet: SelectionSetNode(
                                        selections: [
                                          FieldNode(
                                            name: NameNode(value: 'address'),
                                            alias: null,
                                            arguments: [],
                                            directives: [],
                                            selectionSet: SelectionSetNode(
                                              selections: [
                                                FieldNode(
                                                  name: NameNode(
                                                    value: 'address',
                                                  ),
                                                  alias: null,
                                                  arguments: [],
                                                  directives: [],
                                                  selectionSet: null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        FieldNode(
                          name: NameNode(value: 'outputState'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: SelectionSetNode(
                            selections: [
                              FieldNode(
                                name: NameNode(value: 'owner'),
                                alias: null,
                                arguments: [],
                                directives: [],
                                selectionSet: SelectionSetNode(
                                  selections: [
                                    FieldNode(
                                      name: NameNode(value: '__typename'),
                                      alias: null,
                                      arguments: [],
                                      directives: [],
                                      selectionSet: null,
                                    ),
                                    InlineFragmentNode(
                                      typeCondition: TypeConditionNode(
                                        on: NamedTypeNode(
                                          name: NameNode(value: 'AddressOwner'),
                                          isNonNull: false,
                                        ),
                                      ),
                                      directives: [],
                                      selectionSet: SelectionSetNode(
                                        selections: [
                                          FieldNode(
                                            name: NameNode(value: 'address'),
                                            alias: null,
                                            arguments: [],
                                            directives: [],
                                            selectionSet: SelectionSetNode(
                                              selections: [
                                                FieldNode(
                                                  name: NameNode(
                                                    value: 'address',
                                                  ),
                                                  alias: null,
                                                  arguments: [],
                                                  directives: [],
                                                  selectionSet: null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FieldNode(
                                name: NameNode(value: 'asMoveObject'),
                                alias: null,
                                arguments: [],
                                directives: [],
                                selectionSet: SelectionSetNode(
                                  selections: [
                                    FieldNode(
                                      name: NameNode(value: 'contents'),
                                      alias: null,
                                      arguments: [],
                                      directives: [],
                                      selectionSet: SelectionSetNode(
                                        selections: [
                                          FieldNode(
                                            name: NameNode(value: 'type'),
                                            alias: null,
                                            arguments: [],
                                            directives: [],
                                            selectionSet: SelectionSetNode(
                                              selections: [
                                                FieldNode(
                                                  name: NameNode(value: 'repr'),
                                                  alias: null,
                                                  arguments: [],
                                                  directives: [],
                                                  selectionSet: null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
const documentNodeFragmentTransactionHistoryFields = DocumentNode(
  definitions: [fragmentDefinitionTransactionHistoryFields],
);

class Fragment$TransactionHistoryFields$sender {
  Fragment$TransactionHistoryFields$sender({required this.address});

  factory Fragment$TransactionHistoryFields$sender.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$address = json['address'];
    return Fragment$TransactionHistoryFields$sender(
      address: (l$address as String),
    );
  }

  final String address;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    return Object.hashAll([l$address]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$TransactionHistoryFields$sender ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind {
  Fragment$TransactionHistoryFields$kind({required this.$__typename});

  factory Fragment$TransactionHistoryFields$kind.fromJson(
    Map<String, dynamic> json,
  ) {
    switch (json["__typename"] as String) {
      case "ProgrammableTransaction":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction.fromJson(
          json,
        );

      case "GenesisTransaction":
        return Fragment$TransactionHistoryFields$kind$$GenesisTransaction.fromJson(
          json,
        );

      case "ConsensusCommitPrologueTransaction":
        return Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction.fromJson(
          json,
        );

      case "ChangeEpochTransaction":
        return Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction.fromJson(
          json,
        );

      case "RandomnessStateUpdateTransaction":
        return Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction.fromJson(
          json,
        );

      case "AuthenticatorStateUpdateTransaction":
        return Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction.fromJson(
          json,
        );

      case "EndOfEpochTransaction":
        return Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction.fromJson(
          json,
        );

      case "ProgrammableSystemTransaction":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction.fromJson(
          json,
        );

      default:
        final l$$__typename = json['__typename'];
        return Fragment$TransactionHistoryFields$kind(
          $__typename: (l$$__typename as String),
        );
    }
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$TransactionHistoryFields$kind ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$TransactionHistoryFields$kind
    on Fragment$TransactionHistoryFields$kind {
  _T when<_T>({
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction,
    )
    programmableTransaction,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$GenesisTransaction,
    )
    genesisTransaction,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction,
    )
    consensusCommitPrologueTransaction,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction,
    )
    changeEpochTransaction,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction,
    )
    randomnessStateUpdateTransaction,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction,
    )
    authenticatorStateUpdateTransaction,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction,
    )
    endOfEpochTransaction,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction,
    )
    programmableSystemTransaction,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "ProgrammableTransaction":
        return programmableTransaction(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction,
        );

      case "GenesisTransaction":
        return genesisTransaction(
          this as Fragment$TransactionHistoryFields$kind$$GenesisTransaction,
        );

      case "ConsensusCommitPrologueTransaction":
        return consensusCommitPrologueTransaction(
          this
              as Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction,
        );

      case "ChangeEpochTransaction":
        return changeEpochTransaction(
          this
              as Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction,
        );

      case "RandomnessStateUpdateTransaction":
        return randomnessStateUpdateTransaction(
          this
              as Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction,
        );

      case "AuthenticatorStateUpdateTransaction":
        return authenticatorStateUpdateTransaction(
          this
              as Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction,
        );

      case "EndOfEpochTransaction":
        return endOfEpochTransaction(
          this as Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction,
        );

      case "ProgrammableSystemTransaction":
        return programmableSystemTransaction(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction,
        );

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction,
    )?
    programmableTransaction,
    _T Function(Fragment$TransactionHistoryFields$kind$$GenesisTransaction)?
    genesisTransaction,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction,
    )?
    consensusCommitPrologueTransaction,
    _T Function(Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction)?
    changeEpochTransaction,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction,
    )?
    randomnessStateUpdateTransaction,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction,
    )?
    authenticatorStateUpdateTransaction,
    _T Function(Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction)?
    endOfEpochTransaction,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction,
    )?
    programmableSystemTransaction,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "ProgrammableTransaction":
        if (programmableTransaction != null) {
          return programmableTransaction(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction,
          );
        } else {
          return orElse();
        }

      case "GenesisTransaction":
        if (genesisTransaction != null) {
          return genesisTransaction(
            this as Fragment$TransactionHistoryFields$kind$$GenesisTransaction,
          );
        } else {
          return orElse();
        }

      case "ConsensusCommitPrologueTransaction":
        if (consensusCommitPrologueTransaction != null) {
          return consensusCommitPrologueTransaction(
            this
                as Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction,
          );
        } else {
          return orElse();
        }

      case "ChangeEpochTransaction":
        if (changeEpochTransaction != null) {
          return changeEpochTransaction(
            this
                as Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction,
          );
        } else {
          return orElse();
        }

      case "RandomnessStateUpdateTransaction":
        if (randomnessStateUpdateTransaction != null) {
          return randomnessStateUpdateTransaction(
            this
                as Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction,
          );
        } else {
          return orElse();
        }

      case "AuthenticatorStateUpdateTransaction":
        if (authenticatorStateUpdateTransaction != null) {
          return authenticatorStateUpdateTransaction(
            this
                as Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction,
          );
        } else {
          return orElse();
        }

      case "EndOfEpochTransaction":
        if (endOfEpochTransaction != null) {
          return endOfEpochTransaction(
            this
                as Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction,
          );
        } else {
          return orElse();
        }

      case "ProgrammableSystemTransaction":
        if (programmableSystemTransaction != null) {
          return programmableSystemTransaction(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction,
          );
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction
    implements Fragment$TransactionHistoryFields$kind {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction({
    this.commands,
    this.$__typename = 'ProgrammableTransaction',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$commands = json['commands'];
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction(
      commands: l$commands == null
          ? null
          : Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands.fromJson(
              (l$commands as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands?
  commands;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$commands = commands;
    _resultData['commands'] = l$commands?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$commands = commands;
    final l$$__typename = $__typename;
    return Object.hashAll([l$commands, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$commands = commands;
    final lOther$commands = other.commands;
    if (l$commands != lOther$commands) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands({
    required this.pageInfo,
    required this.nodes,
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands(
      pageInfo:
          Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$pageInfo.fromJson(
            (l$pageInfo as Map<String, dynamic>),
          ),
      nodes: (l$nodes as List<dynamic>)
          .map(
            (e) =>
                Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes.fromJson(
                  (e as Map<String, dynamic>),
                ),
          )
          .toList(),
    );
  }

  final Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$pageInfo
  pageInfo;

  final List<
    Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes
  >
  nodes;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    return Object.hashAll([l$pageInfo, Object.hashAll(l$nodes.map((v) => v))]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$pageInfo {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$pageInfo({
    required this.hasNextPage,
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$pageInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$hasNextPage = json['hasNextPage'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$pageInfo(
      hasNextPage: (l$hasNextPage as bool),
    );
  }

  final bool hasNextPage;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasNextPage = hasNextPage;
    return Object.hashAll([l$hasNextPage]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes({
    required this.$__typename,
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes.fromJson(
    Map<String, dynamic> json,
  ) {
    switch (json["__typename"] as String) {
      case "MakeMoveVecCommand":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand.fromJson(
          json,
        );

      case "MergeCoinsCommand":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand.fromJson(
          json,
        );

      case "MoveCallCommand":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand.fromJson(
          json,
        );

      case "PublishCommand":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand.fromJson(
          json,
        );

      case "SplitCoinsCommand":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand.fromJson(
          json,
        );

      case "TransferObjectsCommand":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand.fromJson(
          json,
        );

      case "UpgradeCommand":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand.fromJson(
          json,
        );

      case "OtherCommand":
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand.fromJson(
          json,
        );

      default:
        final l$$__typename = json['__typename'];
        return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes(
          $__typename: (l$$__typename as String),
        );
    }
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes
    on Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  _T when<_T>({
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand,
    )
    makeMoveVecCommand,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand,
    )
    mergeCoinsCommand,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand,
    )
    moveCallCommand,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand,
    )
    publishCommand,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand,
    )
    splitCoinsCommand,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand,
    )
    transferObjectsCommand,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand,
    )
    upgradeCommand,
    required _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand,
    )
    otherCommand,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "MakeMoveVecCommand":
        return makeMoveVecCommand(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand,
        );

      case "MergeCoinsCommand":
        return mergeCoinsCommand(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand,
        );

      case "MoveCallCommand":
        return moveCallCommand(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand,
        );

      case "PublishCommand":
        return publishCommand(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand,
        );

      case "SplitCoinsCommand":
        return splitCoinsCommand(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand,
        );

      case "TransferObjectsCommand":
        return transferObjectsCommand(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand,
        );

      case "UpgradeCommand":
        return upgradeCommand(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand,
        );

      case "OtherCommand":
        return otherCommand(
          this
              as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand,
        );

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand,
    )?
    makeMoveVecCommand,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand,
    )?
    mergeCoinsCommand,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand,
    )?
    moveCallCommand,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand,
    )?
    publishCommand,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand,
    )?
    splitCoinsCommand,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand,
    )?
    transferObjectsCommand,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand,
    )?
    upgradeCommand,
    _T Function(
      Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand,
    )?
    otherCommand,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "MakeMoveVecCommand":
        if (makeMoveVecCommand != null) {
          return makeMoveVecCommand(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand,
          );
        } else {
          return orElse();
        }

      case "MergeCoinsCommand":
        if (mergeCoinsCommand != null) {
          return mergeCoinsCommand(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand,
          );
        } else {
          return orElse();
        }

      case "MoveCallCommand":
        if (moveCallCommand != null) {
          return moveCallCommand(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand,
          );
        } else {
          return orElse();
        }

      case "PublishCommand":
        if (publishCommand != null) {
          return publishCommand(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand,
          );
        } else {
          return orElse();
        }

      case "SplitCoinsCommand":
        if (splitCoinsCommand != null) {
          return splitCoinsCommand(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand,
          );
        } else {
          return orElse();
        }

      case "TransferObjectsCommand":
        if (transferObjectsCommand != null) {
          return transferObjectsCommand(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand,
          );
        } else {
          return orElse();
        }

      case "UpgradeCommand":
        if (upgradeCommand != null) {
          return upgradeCommand(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand,
          );
        } else {
          return orElse();
        }

      case "OtherCommand":
        if (otherCommand != null) {
          return otherCommand(
            this
                as Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand,
          );
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand
    implements
        Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand({
    this.$__typename = 'MakeMoveVecCommand',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MakeMoveVecCommand ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand
    implements
        Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand({
    this.$__typename = 'MergeCoinsCommand',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MergeCoinsCommand ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand
    implements
        Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand({
    this.$__typename = 'MoveCallCommand',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$MoveCallCommand ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand
    implements
        Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand({
    this.$__typename = 'PublishCommand',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$PublishCommand ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand
    implements
        Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand({
    this.$__typename = 'SplitCoinsCommand',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$SplitCoinsCommand ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand
    implements
        Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand({
    this.$__typename = 'TransferObjectsCommand',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$TransferObjectsCommand ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand
    implements
        Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand({
    this.$__typename = 'UpgradeCommand',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$UpgradeCommand ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand
    implements
        Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes {
  Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand({
    this.$__typename = 'OtherCommand',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableTransaction$commands$nodes$$OtherCommand ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$GenesisTransaction
    implements Fragment$TransactionHistoryFields$kind {
  Fragment$TransactionHistoryFields$kind$$GenesisTransaction({
    this.$__typename = 'GenesisTransaction',
  });

  factory Fragment$TransactionHistoryFields$kind$$GenesisTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$GenesisTransaction(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$TransactionHistoryFields$kind$$GenesisTransaction ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction
    implements Fragment$TransactionHistoryFields$kind {
  Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction({
    this.$__typename = 'ConsensusCommitPrologueTransaction',
  });

  factory Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ConsensusCommitPrologueTransaction ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction
    implements Fragment$TransactionHistoryFields$kind {
  Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction({
    this.$__typename = 'ChangeEpochTransaction',
  });

  factory Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ChangeEpochTransaction ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction
    implements Fragment$TransactionHistoryFields$kind {
  Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction({
    this.$__typename = 'RandomnessStateUpdateTransaction',
  });

  factory Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$RandomnessStateUpdateTransaction ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction
    implements Fragment$TransactionHistoryFields$kind {
  Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction({
    this.$__typename = 'AuthenticatorStateUpdateTransaction',
  });

  factory Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$AuthenticatorStateUpdateTransaction ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction
    implements Fragment$TransactionHistoryFields$kind {
  Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction({
    this.$__typename = 'EndOfEpochTransaction',
  });

  factory Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$EndOfEpochTransaction ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction
    implements Fragment$TransactionHistoryFields$kind {
  Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction({
    this.$__typename = 'ProgrammableSystemTransaction',
  });

  factory Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$kind$$ProgrammableSystemTransaction ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects {
  Fragment$TransactionHistoryFields$effects({
    this.timestamp,
    this.status,
    this.gasEffects,
    this.balanceChanges,
    this.objectChanges,
  });

  factory Fragment$TransactionHistoryFields$effects.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$timestamp = json['timestamp'];
    final l$status = json['status'];
    final l$gasEffects = json['gasEffects'];
    final l$balanceChanges = json['balanceChanges'];
    final l$objectChanges = json['objectChanges'];
    return Fragment$TransactionHistoryFields$effects(
      timestamp: (l$timestamp as String?),
      status: l$status == null
          ? null
          : fromJson$Enum$ExecutionStatus((l$status as String)),
      gasEffects: l$gasEffects == null
          ? null
          : Fragment$TransactionHistoryFields$effects$gasEffects.fromJson(
              (l$gasEffects as Map<String, dynamic>),
            ),
      balanceChanges: l$balanceChanges == null
          ? null
          : Fragment$TransactionHistoryFields$effects$balanceChanges.fromJson(
              (l$balanceChanges as Map<String, dynamic>),
            ),
      objectChanges: l$objectChanges == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges.fromJson(
              (l$objectChanges as Map<String, dynamic>),
            ),
    );
  }

  final String? timestamp;

  final Enum$ExecutionStatus? status;

  final Fragment$TransactionHistoryFields$effects$gasEffects? gasEffects;

  final Fragment$TransactionHistoryFields$effects$balanceChanges?
  balanceChanges;

  final Fragment$TransactionHistoryFields$effects$objectChanges? objectChanges;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$timestamp = timestamp;
    _resultData['timestamp'] = l$timestamp;
    final l$status = status;
    _resultData['status'] = l$status == null
        ? null
        : toJson$Enum$ExecutionStatus(l$status);
    final l$gasEffects = gasEffects;
    _resultData['gasEffects'] = l$gasEffects?.toJson();
    final l$balanceChanges = balanceChanges;
    _resultData['balanceChanges'] = l$balanceChanges?.toJson();
    final l$objectChanges = objectChanges;
    _resultData['objectChanges'] = l$objectChanges?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$timestamp = timestamp;
    final l$status = status;
    final l$gasEffects = gasEffects;
    final l$balanceChanges = balanceChanges;
    final l$objectChanges = objectChanges;
    return Object.hashAll([
      l$timestamp,
      l$status,
      l$gasEffects,
      l$balanceChanges,
      l$objectChanges,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$TransactionHistoryFields$effects ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$timestamp = timestamp;
    final lOther$timestamp = other.timestamp;
    if (l$timestamp != lOther$timestamp) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$gasEffects = gasEffects;
    final lOther$gasEffects = other.gasEffects;
    if (l$gasEffects != lOther$gasEffects) {
      return false;
    }
    final l$balanceChanges = balanceChanges;
    final lOther$balanceChanges = other.balanceChanges;
    if (l$balanceChanges != lOther$balanceChanges) {
      return false;
    }
    final l$objectChanges = objectChanges;
    final lOther$objectChanges = other.objectChanges;
    if (l$objectChanges != lOther$objectChanges) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$gasEffects {
  Fragment$TransactionHistoryFields$effects$gasEffects({this.gasSummary});

  factory Fragment$TransactionHistoryFields$effects$gasEffects.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$gasSummary = json['gasSummary'];
    return Fragment$TransactionHistoryFields$effects$gasEffects(
      gasSummary: l$gasSummary == null
          ? null
          : Fragment$TransactionHistoryFields$effects$gasEffects$gasSummary.fromJson(
              (l$gasSummary as Map<String, dynamic>),
            ),
    );
  }

  final Fragment$TransactionHistoryFields$effects$gasEffects$gasSummary?
  gasSummary;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$gasSummary = gasSummary;
    _resultData['gasSummary'] = l$gasSummary?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$gasSummary = gasSummary;
    return Object.hashAll([l$gasSummary]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$TransactionHistoryFields$effects$gasEffects ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$gasSummary = gasSummary;
    final lOther$gasSummary = other.gasSummary;
    if (l$gasSummary != lOther$gasSummary) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$gasEffects$gasSummary {
  Fragment$TransactionHistoryFields$effects$gasEffects$gasSummary({
    this.computationCost,
    this.storageCost,
    this.storageRebate,
  });

  factory Fragment$TransactionHistoryFields$effects$gasEffects$gasSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$computationCost = json['computationCost'];
    final l$storageCost = json['storageCost'];
    final l$storageRebate = json['storageRebate'];
    return Fragment$TransactionHistoryFields$effects$gasEffects$gasSummary(
      computationCost: (l$computationCost as int?),
      storageCost: (l$storageCost as int?),
      storageRebate: (l$storageRebate as int?),
    );
  }

  final int? computationCost;

  final int? storageCost;

  final int? storageRebate;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$computationCost = computationCost;
    _resultData['computationCost'] = l$computationCost;
    final l$storageCost = storageCost;
    _resultData['storageCost'] = l$storageCost;
    final l$storageRebate = storageRebate;
    _resultData['storageRebate'] = l$storageRebate;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$computationCost = computationCost;
    final l$storageCost = storageCost;
    final l$storageRebate = storageRebate;
    return Object.hashAll([l$computationCost, l$storageCost, l$storageRebate]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$gasEffects$gasSummary ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$computationCost = computationCost;
    final lOther$computationCost = other.computationCost;
    if (l$computationCost != lOther$computationCost) {
      return false;
    }
    final l$storageCost = storageCost;
    final lOther$storageCost = other.storageCost;
    if (l$storageCost != lOther$storageCost) {
      return false;
    }
    final l$storageRebate = storageRebate;
    final lOther$storageRebate = other.storageRebate;
    if (l$storageRebate != lOther$storageRebate) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$balanceChanges {
  Fragment$TransactionHistoryFields$effects$balanceChanges({
    required this.pageInfo,
    required this.nodes,
  });

  factory Fragment$TransactionHistoryFields$effects$balanceChanges.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    return Fragment$TransactionHistoryFields$effects$balanceChanges(
      pageInfo:
          Fragment$TransactionHistoryFields$effects$balanceChanges$pageInfo.fromJson(
            (l$pageInfo as Map<String, dynamic>),
          ),
      nodes: (l$nodes as List<dynamic>)
          .map(
            (e) =>
                Fragment$TransactionHistoryFields$effects$balanceChanges$nodes.fromJson(
                  (e as Map<String, dynamic>),
                ),
          )
          .toList(),
    );
  }

  final Fragment$TransactionHistoryFields$effects$balanceChanges$pageInfo
  pageInfo;

  final List<Fragment$TransactionHistoryFields$effects$balanceChanges$nodes>
  nodes;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    return Object.hashAll([l$pageInfo, Object.hashAll(l$nodes.map((v) => v))]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$TransactionHistoryFields$effects$balanceChanges ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$balanceChanges$pageInfo {
  Fragment$TransactionHistoryFields$effects$balanceChanges$pageInfo({
    required this.hasNextPage,
  });

  factory Fragment$TransactionHistoryFields$effects$balanceChanges$pageInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$hasNextPage = json['hasNextPage'];
    return Fragment$TransactionHistoryFields$effects$balanceChanges$pageInfo(
      hasNextPage: (l$hasNextPage as bool),
    );
  }

  final bool hasNextPage;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasNextPage = hasNextPage;
    return Object.hashAll([l$hasNextPage]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$balanceChanges$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$balanceChanges$nodes {
  Fragment$TransactionHistoryFields$effects$balanceChanges$nodes({
    this.amount,
    this.coinType,
    this.owner,
  });

  factory Fragment$TransactionHistoryFields$effects$balanceChanges$nodes.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$amount = json['amount'];
    final l$coinType = json['coinType'];
    final l$owner = json['owner'];
    return Fragment$TransactionHistoryFields$effects$balanceChanges$nodes(
      amount: (l$amount as String?),
      coinType: l$coinType == null
          ? null
          : Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$coinType.fromJson(
              (l$coinType as Map<String, dynamic>),
            ),
      owner: l$owner == null
          ? null
          : Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$owner.fromJson(
              (l$owner as Map<String, dynamic>),
            ),
    );
  }

  final String? amount;

  final Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$coinType?
  coinType;

  final Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$owner?
  owner;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$amount = amount;
    _resultData['amount'] = l$amount;
    final l$coinType = coinType;
    _resultData['coinType'] = l$coinType?.toJson();
    final l$owner = owner;
    _resultData['owner'] = l$owner?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$amount = amount;
    final l$coinType = coinType;
    final l$owner = owner;
    return Object.hashAll([l$amount, l$coinType, l$owner]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$balanceChanges$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$amount = amount;
    final lOther$amount = other.amount;
    if (l$amount != lOther$amount) {
      return false;
    }
    final l$coinType = coinType;
    final lOther$coinType = other.coinType;
    if (l$coinType != lOther$coinType) {
      return false;
    }
    final l$owner = owner;
    final lOther$owner = other.owner;
    if (l$owner != lOther$owner) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$coinType {
  Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$coinType({
    required this.repr,
  });

  factory Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$coinType.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$repr = json['repr'];
    return Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$coinType(
      repr: (l$repr as String),
    );
  }

  final String repr;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$repr = repr;
    _resultData['repr'] = l$repr;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$repr = repr;
    return Object.hashAll([l$repr]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$coinType ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$repr = repr;
    final lOther$repr = other.repr;
    if (l$repr != lOther$repr) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$owner {
  Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$owner({
    required this.address,
  });

  factory Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$owner.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$address = json['address'];
    return Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$owner(
      address: (l$address as String),
    );
  }

  final String address;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    return Object.hashAll([l$address]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$balanceChanges$nodes$owner ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges {
  Fragment$TransactionHistoryFields$effects$objectChanges({
    required this.pageInfo,
    required this.nodes,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    return Fragment$TransactionHistoryFields$effects$objectChanges(
      pageInfo:
          Fragment$TransactionHistoryFields$effects$objectChanges$pageInfo.fromJson(
            (l$pageInfo as Map<String, dynamic>),
          ),
      nodes: (l$nodes as List<dynamic>)
          .map(
            (e) =>
                Fragment$TransactionHistoryFields$effects$objectChanges$nodes.fromJson(
                  (e as Map<String, dynamic>),
                ),
          )
          .toList(),
    );
  }

  final Fragment$TransactionHistoryFields$effects$objectChanges$pageInfo
  pageInfo;

  final List<Fragment$TransactionHistoryFields$effects$objectChanges$nodes>
  nodes;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    return Object.hashAll([l$pageInfo, Object.hashAll(l$nodes.map((v) => v))]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$TransactionHistoryFields$effects$objectChanges ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$pageInfo {
  Fragment$TransactionHistoryFields$effects$objectChanges$pageInfo({
    required this.hasNextPage,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$pageInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$hasNextPage = json['hasNextPage'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$pageInfo(
      hasNextPage: (l$hasNextPage as bool),
    );
  }

  final bool hasNextPage;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasNextPage = hasNextPage;
    return Object.hashAll([l$hasNextPage]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes({
    required this.address,
    this.idCreated,
    this.idDeleted,
    this.inputState,
    this.outputState,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$address = json['address'];
    final l$idCreated = json['idCreated'];
    final l$idDeleted = json['idDeleted'];
    final l$inputState = json['inputState'];
    final l$outputState = json['outputState'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes(
      address: (l$address as String),
      idCreated: (l$idCreated as bool?),
      idDeleted: (l$idDeleted as bool?),
      inputState: l$inputState == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState.fromJson(
              (l$inputState as Map<String, dynamic>),
            ),
      outputState: l$outputState == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState.fromJson(
              (l$outputState as Map<String, dynamic>),
            ),
    );
  }

  final String address;

  final bool? idCreated;

  final bool? idDeleted;

  final Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState?
  inputState;

  final Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState?
  outputState;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address;
    final l$idCreated = idCreated;
    _resultData['idCreated'] = l$idCreated;
    final l$idDeleted = idDeleted;
    _resultData['idDeleted'] = l$idDeleted;
    final l$inputState = inputState;
    _resultData['inputState'] = l$inputState?.toJson();
    final l$outputState = outputState;
    _resultData['outputState'] = l$outputState?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    final l$idCreated = idCreated;
    final l$idDeleted = idDeleted;
    final l$inputState = inputState;
    final l$outputState = outputState;
    return Object.hashAll([
      l$address,
      l$idCreated,
      l$idDeleted,
      l$inputState,
      l$outputState,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    final l$idCreated = idCreated;
    final lOther$idCreated = other.idCreated;
    if (l$idCreated != lOther$idCreated) {
      return false;
    }
    final l$idDeleted = idDeleted;
    final lOther$idDeleted = other.idDeleted;
    if (l$idDeleted != lOther$idDeleted) {
      return false;
    }
    final l$inputState = inputState;
    final lOther$inputState = other.inputState;
    if (l$inputState != lOther$inputState) {
      return false;
    }
    final l$outputState = outputState;
    final lOther$outputState = other.outputState;
    if (l$outputState != lOther$outputState) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState({
    this.owner,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$owner = json['owner'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState(
      owner: l$owner == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner.fromJson(
              (l$owner as Map<String, dynamic>),
            ),
    );
  }

  final Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner?
  owner;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$owner = owner;
    _resultData['owner'] = l$owner?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$owner = owner;
    return Object.hashAll([l$owner]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$owner = owner;
    final lOther$owner = other.owner;
    if (l$owner != lOther$owner) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner({
    required this.$__typename,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner.fromJson(
    Map<String, dynamic> json,
  ) {
    switch (json["__typename"] as String) {
      case "AddressOwner":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner.fromJson(
          json,
        );

      case "ObjectOwner":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner.fromJson(
          json,
        );

      case "Shared":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared.fromJson(
          json,
        );

      case "Immutable":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable.fromJson(
          json,
        );

      case "ConsensusAddressOwner":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner.fromJson(
          json,
        );

      default:
        final l$$__typename = json['__typename'];
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner(
          $__typename: (l$$__typename as String),
        );
    }
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner
    on Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner {
  _T when<_T>({
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner,
    )
    addressOwner,
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner,
    )
    objectOwner,
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared,
    )
    shared,
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable,
    )
    immutable,
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner,
    )
    consensusAddressOwner,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "AddressOwner":
        return addressOwner(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner,
        );

      case "ObjectOwner":
        return objectOwner(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner,
        );

      case "Shared":
        return shared(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared,
        );

      case "Immutable":
        return immutable(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable,
        );

      case "ConsensusAddressOwner":
        return consensusAddressOwner(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner,
        );

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner,
    )?
    addressOwner,
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner,
    )?
    objectOwner,
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared,
    )?
    shared,
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable,
    )?
    immutable,
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner,
    )?
    consensusAddressOwner,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "AddressOwner":
        if (addressOwner != null) {
          return addressOwner(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner,
          );
        } else {
          return orElse();
        }

      case "ObjectOwner":
        if (objectOwner != null) {
          return objectOwner(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner,
          );
        } else {
          return orElse();
        }

      case "Shared":
        if (shared != null) {
          return shared(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared,
          );
        } else {
          return orElse();
        }

      case "Immutable":
        if (immutable != null) {
          return immutable(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable,
          );
        } else {
          return orElse();
        }

      case "ConsensusAddressOwner":
        if (consensusAddressOwner != null) {
          return consensusAddressOwner(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner,
          );
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner({
    this.address,
    this.$__typename = 'AddressOwner',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$address = json['address'];
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner(
      address: l$address == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner$address.fromJson(
              (l$address as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner$address?
  address;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    final l$$__typename = $__typename;
    return Object.hashAll([l$address, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner$address {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner$address({
    required this.address,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner$address.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$address = json['address'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner$address(
      address: (l$address as String),
    );
  }

  final String address;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    return Object.hashAll([l$address]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$AddressOwner$address ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner({
    this.$__typename = 'ObjectOwner',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ObjectOwner ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared({
    this.$__typename = 'Shared',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Shared ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable({
    this.$__typename = 'Immutable',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$Immutable ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner({
    this.$__typename = 'ConsensusAddressOwner',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$inputState$owner$$ConsensusAddressOwner ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState({
    this.owner,
    this.asMoveObject,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$owner = json['owner'];
    final l$asMoveObject = json['asMoveObject'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState(
      owner: l$owner == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner.fromJson(
              (l$owner as Map<String, dynamic>),
            ),
      asMoveObject: l$asMoveObject == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject.fromJson(
              (l$asMoveObject as Map<String, dynamic>),
            ),
    );
  }

  final Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner?
  owner;

  final Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject?
  asMoveObject;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$owner = owner;
    _resultData['owner'] = l$owner?.toJson();
    final l$asMoveObject = asMoveObject;
    _resultData['asMoveObject'] = l$asMoveObject?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$owner = owner;
    final l$asMoveObject = asMoveObject;
    return Object.hashAll([l$owner, l$asMoveObject]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$owner = owner;
    final lOther$owner = other.owner;
    if (l$owner != lOther$owner) {
      return false;
    }
    final l$asMoveObject = asMoveObject;
    final lOther$asMoveObject = other.asMoveObject;
    if (l$asMoveObject != lOther$asMoveObject) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner({
    required this.$__typename,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner.fromJson(
    Map<String, dynamic> json,
  ) {
    switch (json["__typename"] as String) {
      case "AddressOwner":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner.fromJson(
          json,
        );

      case "ObjectOwner":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner.fromJson(
          json,
        );

      case "Shared":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared.fromJson(
          json,
        );

      case "Immutable":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable.fromJson(
          json,
        );

      case "ConsensusAddressOwner":
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner.fromJson(
          json,
        );

      default:
        final l$$__typename = json['__typename'];
        return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner(
          $__typename: (l$$__typename as String),
        );
    }
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner
    on
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner {
  _T when<_T>({
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner,
    )
    addressOwner,
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner,
    )
    objectOwner,
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared,
    )
    shared,
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable,
    )
    immutable,
    required _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner,
    )
    consensusAddressOwner,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "AddressOwner":
        return addressOwner(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner,
        );

      case "ObjectOwner":
        return objectOwner(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner,
        );

      case "Shared":
        return shared(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared,
        );

      case "Immutable":
        return immutable(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable,
        );

      case "ConsensusAddressOwner":
        return consensusAddressOwner(
          this
              as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner,
        );

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner,
    )?
    addressOwner,
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner,
    )?
    objectOwner,
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared,
    )?
    shared,
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable,
    )?
    immutable,
    _T Function(
      Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner,
    )?
    consensusAddressOwner,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "AddressOwner":
        if (addressOwner != null) {
          return addressOwner(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner,
          );
        } else {
          return orElse();
        }

      case "ObjectOwner":
        if (objectOwner != null) {
          return objectOwner(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner,
          );
        } else {
          return orElse();
        }

      case "Shared":
        if (shared != null) {
          return shared(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared,
          );
        } else {
          return orElse();
        }

      case "Immutable":
        if (immutable != null) {
          return immutable(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable,
          );
        } else {
          return orElse();
        }

      case "ConsensusAddressOwner":
        if (consensusAddressOwner != null) {
          return consensusAddressOwner(
            this
                as Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner,
          );
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner({
    this.address,
    this.$__typename = 'AddressOwner',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$address = json['address'];
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner(
      address: l$address == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner$address.fromJson(
              (l$address as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner$address?
  address;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    final l$$__typename = $__typename;
    return Object.hashAll([l$address, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner$address {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner$address({
    required this.address,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner$address.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$address = json['address'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner$address(
      address: (l$address as String),
    );
  }

  final String address;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    return Object.hashAll([l$address]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$AddressOwner$address ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner({
    this.$__typename = 'ObjectOwner',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ObjectOwner ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared({
    this.$__typename = 'Shared',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Shared ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable({
    this.$__typename = 'Immutable',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$Immutable ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner
    implements
        Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner({
    this.$__typename = 'ConsensusAddressOwner',
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$$__typename = json['__typename'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner(
      $__typename: (l$$__typename as String),
    );
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$owner$$ConsensusAddressOwner ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject({
    this.contents,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$contents = json['contents'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject(
      contents: l$contents == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents.fromJson(
              (l$contents as Map<String, dynamic>),
            ),
    );
  }

  final Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents?
  contents;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$contents = contents;
    _resultData['contents'] = l$contents?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$contents = contents;
    return Object.hashAll([l$contents]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$contents = contents;
    final lOther$contents = other.contents;
    if (l$contents != lOther$contents) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents({
    this.type,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$type = json['type'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents(
      type: l$type == null
          ? null
          : Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents$type.fromJson(
              (l$type as Map<String, dynamic>),
            ),
    );
  }

  final Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents$type?
  type;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$type = type;
    _resultData['type'] = l$type?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$type = type;
    return Object.hashAll([l$type]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    return true;
  }
}

class Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents$type {
  Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents$type({
    required this.repr,
  });

  factory Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents$type.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$repr = json['repr'];
    return Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents$type(
      repr: (l$repr as String),
    );
  }

  final String repr;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$repr = repr;
    _resultData['repr'] = l$repr;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$repr = repr;
    return Object.hashAll([l$repr]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Fragment$TransactionHistoryFields$effects$objectChanges$nodes$outputState$asMoveObject$contents$type ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$repr = repr;
    final lOther$repr = other.repr;
    if (l$repr != lOther$repr) {
      return false;
    }
    return true;
  }
}

class Query$ChainIdentifier {
  Query$ChainIdentifier({required this.chainIdentifier});

  factory Query$ChainIdentifier.fromJson(Map<String, dynamic> json) {
    final l$chainIdentifier = json['chainIdentifier'];
    return Query$ChainIdentifier(
      chainIdentifier: (l$chainIdentifier as String),
    );
  }

  final String chainIdentifier;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chainIdentifier = chainIdentifier;
    _resultData['chainIdentifier'] = l$chainIdentifier;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chainIdentifier = chainIdentifier;
    return Object.hashAll([l$chainIdentifier]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ChainIdentifier || runtimeType != other.runtimeType) {
      return false;
    }
    final l$chainIdentifier = chainIdentifier;
    final lOther$chainIdentifier = other.chainIdentifier;
    if (l$chainIdentifier != lOther$chainIdentifier) {
      return false;
    }
    return true;
  }
}

const documentNodeQueryChainIdentifier = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'ChainIdentifier'),
      variableDefinitions: [],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'chainIdentifier'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ],
      ),
    ),
  ],
);

class Variables$Query$TransactionGasSummary {
  factory Variables$Query$TransactionGasSummary({required String digest}) =>
      Variables$Query$TransactionGasSummary._({r'digest': digest});

  Variables$Query$TransactionGasSummary._(this._$data);

  factory Variables$Query$TransactionGasSummary.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$digest = data['digest'];
    result$data['digest'] = (l$digest as String);
    return Variables$Query$TransactionGasSummary._(result$data);
  }

  Map<String, dynamic> _$data;

  String get digest => (_$data['digest'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$digest = digest;
    result$data['digest'] = l$digest;
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$TransactionGasSummary ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$digest = digest;
    final lOther$digest = other.digest;
    if (l$digest != lOther$digest) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$digest = digest;
    return Object.hashAll([l$digest]);
  }
}

class Query$TransactionGasSummary {
  Query$TransactionGasSummary({this.transaction});

  factory Query$TransactionGasSummary.fromJson(Map<String, dynamic> json) {
    final l$transaction = json['transaction'];
    return Query$TransactionGasSummary(
      transaction: l$transaction == null
          ? null
          : Query$TransactionGasSummary$transaction.fromJson(
              (l$transaction as Map<String, dynamic>),
            ),
    );
  }

  final Query$TransactionGasSummary$transaction? transaction;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$transaction = transaction;
    _resultData['transaction'] = l$transaction?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$transaction = transaction;
    return Object.hashAll([l$transaction]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionGasSummary ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$transaction = transaction;
    final lOther$transaction = other.transaction;
    if (l$transaction != lOther$transaction) {
      return false;
    }
    return true;
  }
}

const documentNodeQueryTransactionGasSummary = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'TransactionGasSummary'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'digest')),
          type: NamedTypeNode(name: NameNode(value: 'String'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'transaction'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'digest'),
                value: VariableNode(name: NameNode(value: 'digest')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'effects'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'gasEffects'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(
                          selections: [
                            FieldNode(
                              name: NameNode(value: 'gasSummary'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: SelectionSetNode(
                                selections: [
                                  FieldNode(
                                    name: NameNode(value: 'computationCost'),
                                    alias: null,
                                    arguments: [],
                                    directives: [],
                                    selectionSet: null,
                                  ),
                                  FieldNode(
                                    name: NameNode(value: 'storageCost'),
                                    alias: null,
                                    arguments: [],
                                    directives: [],
                                    selectionSet: null,
                                  ),
                                  FieldNode(
                                    name: NameNode(value: 'storageRebate'),
                                    alias: null,
                                    arguments: [],
                                    directives: [],
                                    selectionSet: null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
);

class Query$TransactionGasSummary$transaction {
  Query$TransactionGasSummary$transaction({this.effects});

  factory Query$TransactionGasSummary$transaction.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$effects = json['effects'];
    return Query$TransactionGasSummary$transaction(
      effects: l$effects == null
          ? null
          : Query$TransactionGasSummary$transaction$effects.fromJson(
              (l$effects as Map<String, dynamic>),
            ),
    );
  }

  final Query$TransactionGasSummary$transaction$effects? effects;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$effects = effects;
    _resultData['effects'] = l$effects?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$effects = effects;
    return Object.hashAll([l$effects]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionGasSummary$transaction ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$effects = effects;
    final lOther$effects = other.effects;
    if (l$effects != lOther$effects) {
      return false;
    }
    return true;
  }
}

class Query$TransactionGasSummary$transaction$effects {
  Query$TransactionGasSummary$transaction$effects({this.gasEffects});

  factory Query$TransactionGasSummary$transaction$effects.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$gasEffects = json['gasEffects'];
    return Query$TransactionGasSummary$transaction$effects(
      gasEffects: l$gasEffects == null
          ? null
          : Query$TransactionGasSummary$transaction$effects$gasEffects.fromJson(
              (l$gasEffects as Map<String, dynamic>),
            ),
    );
  }

  final Query$TransactionGasSummary$transaction$effects$gasEffects? gasEffects;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$gasEffects = gasEffects;
    _resultData['gasEffects'] = l$gasEffects?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$gasEffects = gasEffects;
    return Object.hashAll([l$gasEffects]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionGasSummary$transaction$effects ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$gasEffects = gasEffects;
    final lOther$gasEffects = other.gasEffects;
    if (l$gasEffects != lOther$gasEffects) {
      return false;
    }
    return true;
  }
}

class Query$TransactionGasSummary$transaction$effects$gasEffects {
  Query$TransactionGasSummary$transaction$effects$gasEffects({this.gasSummary});

  factory Query$TransactionGasSummary$transaction$effects$gasEffects.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$gasSummary = json['gasSummary'];
    return Query$TransactionGasSummary$transaction$effects$gasEffects(
      gasSummary: l$gasSummary == null
          ? null
          : Query$TransactionGasSummary$transaction$effects$gasEffects$gasSummary.fromJson(
              (l$gasSummary as Map<String, dynamic>),
            ),
    );
  }

  final Query$TransactionGasSummary$transaction$effects$gasEffects$gasSummary?
  gasSummary;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$gasSummary = gasSummary;
    _resultData['gasSummary'] = l$gasSummary?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$gasSummary = gasSummary;
    return Object.hashAll([l$gasSummary]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionGasSummary$transaction$effects$gasEffects ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$gasSummary = gasSummary;
    final lOther$gasSummary = other.gasSummary;
    if (l$gasSummary != lOther$gasSummary) {
      return false;
    }
    return true;
  }
}

class Query$TransactionGasSummary$transaction$effects$gasEffects$gasSummary {
  Query$TransactionGasSummary$transaction$effects$gasEffects$gasSummary({
    this.computationCost,
    this.storageCost,
    this.storageRebate,
  });

  factory Query$TransactionGasSummary$transaction$effects$gasEffects$gasSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$computationCost = json['computationCost'];
    final l$storageCost = json['storageCost'];
    final l$storageRebate = json['storageRebate'];
    return Query$TransactionGasSummary$transaction$effects$gasEffects$gasSummary(
      computationCost: (l$computationCost as int?),
      storageCost: (l$storageCost as int?),
      storageRebate: (l$storageRebate as int?),
    );
  }

  final int? computationCost;

  final int? storageCost;

  final int? storageRebate;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$computationCost = computationCost;
    _resultData['computationCost'] = l$computationCost;
    final l$storageCost = storageCost;
    _resultData['storageCost'] = l$storageCost;
    final l$storageRebate = storageRebate;
    _resultData['storageRebate'] = l$storageRebate;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$computationCost = computationCost;
    final l$storageCost = storageCost;
    final l$storageRebate = storageRebate;
    return Object.hashAll([l$computationCost, l$storageCost, l$storageRebate]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$TransactionGasSummary$transaction$effects$gasEffects$gasSummary ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$computationCost = computationCost;
    final lOther$computationCost = other.computationCost;
    if (l$computationCost != lOther$computationCost) {
      return false;
    }
    final l$storageCost = storageCost;
    final lOther$storageCost = other.storageCost;
    if (l$storageCost != lOther$storageCost) {
      return false;
    }
    final l$storageRebate = storageRebate;
    final lOther$storageRebate = other.storageRebate;
    if (l$storageRebate != lOther$storageRebate) {
      return false;
    }
    return true;
  }
}

class Variables$Query$TransactionHistoryByAddress {
  factory Variables$Query$TransactionHistoryByAddress({
    required String address,
    required int first,
    String? before,
    required bool showBalanceChanges,
    required bool showObjectChanges,
  }) => Variables$Query$TransactionHistoryByAddress._({
    r'address': address,
    r'first': first,
    if (before != null) r'before': before,
    r'showBalanceChanges': showBalanceChanges,
    r'showObjectChanges': showObjectChanges,
  });

  Variables$Query$TransactionHistoryByAddress._(this._$data);

  factory Variables$Query$TransactionHistoryByAddress.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$address = data['address'];
    result$data['address'] = (l$address as String);
    final l$first = data['first'];
    result$data['first'] = (l$first as int);
    if (data.containsKey('before')) {
      final l$before = data['before'];
      result$data['before'] = (l$before as String?);
    }
    final l$showBalanceChanges = data['showBalanceChanges'];
    result$data['showBalanceChanges'] = (l$showBalanceChanges as bool);
    final l$showObjectChanges = data['showObjectChanges'];
    result$data['showObjectChanges'] = (l$showObjectChanges as bool);
    return Variables$Query$TransactionHistoryByAddress._(result$data);
  }

  Map<String, dynamic> _$data;

  String get address => (_$data['address'] as String);

  int get first => (_$data['first'] as int);

  String? get before => (_$data['before'] as String?);

  bool get showBalanceChanges => (_$data['showBalanceChanges'] as bool);

  bool get showObjectChanges => (_$data['showObjectChanges'] as bool);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$address = address;
    result$data['address'] = l$address;
    final l$first = first;
    result$data['first'] = l$first;
    if (_$data.containsKey('before')) {
      final l$before = before;
      result$data['before'] = l$before;
    }
    final l$showBalanceChanges = showBalanceChanges;
    result$data['showBalanceChanges'] = l$showBalanceChanges;
    final l$showObjectChanges = showObjectChanges;
    result$data['showObjectChanges'] = l$showObjectChanges;
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$TransactionHistoryByAddress ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    final l$first = first;
    final lOther$first = other.first;
    if (l$first != lOther$first) {
      return false;
    }
    final l$before = before;
    final lOther$before = other.before;
    if (_$data.containsKey('before') != other._$data.containsKey('before')) {
      return false;
    }
    if (l$before != lOther$before) {
      return false;
    }
    final l$showBalanceChanges = showBalanceChanges;
    final lOther$showBalanceChanges = other.showBalanceChanges;
    if (l$showBalanceChanges != lOther$showBalanceChanges) {
      return false;
    }
    final l$showObjectChanges = showObjectChanges;
    final lOther$showObjectChanges = other.showObjectChanges;
    if (l$showObjectChanges != lOther$showObjectChanges) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$address = address;
    final l$first = first;
    final l$before = before;
    final l$showBalanceChanges = showBalanceChanges;
    final l$showObjectChanges = showObjectChanges;
    return Object.hashAll([
      l$address,
      l$first,
      _$data.containsKey('before') ? l$before : const {},
      l$showBalanceChanges,
      l$showObjectChanges,
    ]);
  }
}

class Query$TransactionHistoryByAddress {
  Query$TransactionHistoryByAddress({this.transactions});

  factory Query$TransactionHistoryByAddress.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$transactions = json['transactions'];
    return Query$TransactionHistoryByAddress(
      transactions: l$transactions == null
          ? null
          : Query$TransactionHistoryByAddress$transactions.fromJson(
              (l$transactions as Map<String, dynamic>),
            ),
    );
  }

  final Query$TransactionHistoryByAddress$transactions? transactions;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$transactions = transactions;
    _resultData['transactions'] = l$transactions?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$transactions = transactions;
    return Object.hashAll([l$transactions]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionHistoryByAddress ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$transactions = transactions;
    final lOther$transactions = other.transactions;
    if (l$transactions != lOther$transactions) {
      return false;
    }
    return true;
  }
}

const documentNodeQueryTransactionHistoryByAddress = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'TransactionHistoryByAddress'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'address')),
          type: NamedTypeNode(
            name: NameNode(value: 'SuiAddress'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'first')),
          type: NamedTypeNode(name: NameNode(value: 'Int'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'before')),
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'showBalanceChanges')),
          type: NamedTypeNode(
            name: NameNode(value: 'Boolean'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'showObjectChanges')),
          type: NamedTypeNode(
            name: NameNode(value: 'Boolean'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'transactions'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'last'),
                value: VariableNode(name: NameNode(value: 'first')),
              ),
              ArgumentNode(
                name: NameNode(value: 'before'),
                value: VariableNode(name: NameNode(value: 'before')),
              ),
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: ObjectValueNode(
                  fields: [
                    ObjectFieldNode(
                      name: NameNode(value: 'affectedAddress'),
                      value: VariableNode(name: NameNode(value: 'address')),
                    ),
                  ],
                ),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'pageInfo'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'hasPreviousPage'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'startCursor'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                    ],
                  ),
                ),
                FieldNode(
                  name: NameNode(value: 'nodes'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'TransactionHistoryFields'),
                        directives: [],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    fragmentDefinitionTransactionHistoryFields,
  ],
);

class Query$TransactionHistoryByAddress$transactions {
  Query$TransactionHistoryByAddress$transactions({
    required this.pageInfo,
    required this.nodes,
  });

  factory Query$TransactionHistoryByAddress$transactions.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    return Query$TransactionHistoryByAddress$transactions(
      pageInfo:
          Query$TransactionHistoryByAddress$transactions$pageInfo.fromJson(
            (l$pageInfo as Map<String, dynamic>),
          ),
      nodes: (l$nodes as List<dynamic>)
          .map(
            (e) => Fragment$TransactionHistoryFields.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
    );
  }

  final Query$TransactionHistoryByAddress$transactions$pageInfo pageInfo;

  final List<Fragment$TransactionHistoryFields> nodes;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    return Object.hashAll([l$pageInfo, Object.hashAll(l$nodes.map((v) => v))]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionHistoryByAddress$transactions ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    return true;
  }
}

class Query$TransactionHistoryByAddress$transactions$pageInfo {
  Query$TransactionHistoryByAddress$transactions$pageInfo({
    required this.hasPreviousPage,
    this.startCursor,
  });

  factory Query$TransactionHistoryByAddress$transactions$pageInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$hasPreviousPage = json['hasPreviousPage'];
    final l$startCursor = json['startCursor'];
    return Query$TransactionHistoryByAddress$transactions$pageInfo(
      hasPreviousPage: (l$hasPreviousPage as bool),
      startCursor: (l$startCursor as String?),
    );
  }

  final bool hasPreviousPage;

  final String? startCursor;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasPreviousPage = hasPreviousPage;
    _resultData['hasPreviousPage'] = l$hasPreviousPage;
    final l$startCursor = startCursor;
    _resultData['startCursor'] = l$startCursor;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasPreviousPage = hasPreviousPage;
    final l$startCursor = startCursor;
    return Object.hashAll([l$hasPreviousPage, l$startCursor]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionHistoryByAddress$transactions$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasPreviousPage = hasPreviousPage;
    final lOther$hasPreviousPage = other.hasPreviousPage;
    if (l$hasPreviousPage != lOther$hasPreviousPage) {
      return false;
    }
    final l$startCursor = startCursor;
    final lOther$startCursor = other.startCursor;
    if (l$startCursor != lOther$startCursor) {
      return false;
    }
    return true;
  }
}

class Variables$Query$TransactionHistoryBySender {
  factory Variables$Query$TransactionHistoryBySender({
    required String sender,
    required int first,
    String? before,
    required bool showBalanceChanges,
    required bool showObjectChanges,
  }) => Variables$Query$TransactionHistoryBySender._({
    r'sender': sender,
    r'first': first,
    if (before != null) r'before': before,
    r'showBalanceChanges': showBalanceChanges,
    r'showObjectChanges': showObjectChanges,
  });

  Variables$Query$TransactionHistoryBySender._(this._$data);

  factory Variables$Query$TransactionHistoryBySender.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$sender = data['sender'];
    result$data['sender'] = (l$sender as String);
    final l$first = data['first'];
    result$data['first'] = (l$first as int);
    if (data.containsKey('before')) {
      final l$before = data['before'];
      result$data['before'] = (l$before as String?);
    }
    final l$showBalanceChanges = data['showBalanceChanges'];
    result$data['showBalanceChanges'] = (l$showBalanceChanges as bool);
    final l$showObjectChanges = data['showObjectChanges'];
    result$data['showObjectChanges'] = (l$showObjectChanges as bool);
    return Variables$Query$TransactionHistoryBySender._(result$data);
  }

  Map<String, dynamic> _$data;

  String get sender => (_$data['sender'] as String);

  int get first => (_$data['first'] as int);

  String? get before => (_$data['before'] as String?);

  bool get showBalanceChanges => (_$data['showBalanceChanges'] as bool);

  bool get showObjectChanges => (_$data['showObjectChanges'] as bool);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$sender = sender;
    result$data['sender'] = l$sender;
    final l$first = first;
    result$data['first'] = l$first;
    if (_$data.containsKey('before')) {
      final l$before = before;
      result$data['before'] = l$before;
    }
    final l$showBalanceChanges = showBalanceChanges;
    result$data['showBalanceChanges'] = l$showBalanceChanges;
    final l$showObjectChanges = showObjectChanges;
    result$data['showObjectChanges'] = l$showObjectChanges;
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$TransactionHistoryBySender ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$sender = sender;
    final lOther$sender = other.sender;
    if (l$sender != lOther$sender) {
      return false;
    }
    final l$first = first;
    final lOther$first = other.first;
    if (l$first != lOther$first) {
      return false;
    }
    final l$before = before;
    final lOther$before = other.before;
    if (_$data.containsKey('before') != other._$data.containsKey('before')) {
      return false;
    }
    if (l$before != lOther$before) {
      return false;
    }
    final l$showBalanceChanges = showBalanceChanges;
    final lOther$showBalanceChanges = other.showBalanceChanges;
    if (l$showBalanceChanges != lOther$showBalanceChanges) {
      return false;
    }
    final l$showObjectChanges = showObjectChanges;
    final lOther$showObjectChanges = other.showObjectChanges;
    if (l$showObjectChanges != lOther$showObjectChanges) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$sender = sender;
    final l$first = first;
    final l$before = before;
    final l$showBalanceChanges = showBalanceChanges;
    final l$showObjectChanges = showObjectChanges;
    return Object.hashAll([
      l$sender,
      l$first,
      _$data.containsKey('before') ? l$before : const {},
      l$showBalanceChanges,
      l$showObjectChanges,
    ]);
  }
}

class Query$TransactionHistoryBySender {
  Query$TransactionHistoryBySender({this.transactions});

  factory Query$TransactionHistoryBySender.fromJson(Map<String, dynamic> json) {
    final l$transactions = json['transactions'];
    return Query$TransactionHistoryBySender(
      transactions: l$transactions == null
          ? null
          : Query$TransactionHistoryBySender$transactions.fromJson(
              (l$transactions as Map<String, dynamic>),
            ),
    );
  }

  final Query$TransactionHistoryBySender$transactions? transactions;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$transactions = transactions;
    _resultData['transactions'] = l$transactions?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$transactions = transactions;
    return Object.hashAll([l$transactions]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionHistoryBySender ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$transactions = transactions;
    final lOther$transactions = other.transactions;
    if (l$transactions != lOther$transactions) {
      return false;
    }
    return true;
  }
}

const documentNodeQueryTransactionHistoryBySender = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'TransactionHistoryBySender'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'sender')),
          type: NamedTypeNode(
            name: NameNode(value: 'SuiAddress'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'first')),
          type: NamedTypeNode(name: NameNode(value: 'Int'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'before')),
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'showBalanceChanges')),
          type: NamedTypeNode(
            name: NameNode(value: 'Boolean'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'showObjectChanges')),
          type: NamedTypeNode(
            name: NameNode(value: 'Boolean'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'transactions'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'last'),
                value: VariableNode(name: NameNode(value: 'first')),
              ),
              ArgumentNode(
                name: NameNode(value: 'before'),
                value: VariableNode(name: NameNode(value: 'before')),
              ),
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: ObjectValueNode(
                  fields: [
                    ObjectFieldNode(
                      name: NameNode(value: 'sentAddress'),
                      value: VariableNode(name: NameNode(value: 'sender')),
                    ),
                  ],
                ),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'pageInfo'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'hasPreviousPage'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'startCursor'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                    ],
                  ),
                ),
                FieldNode(
                  name: NameNode(value: 'nodes'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'TransactionHistoryFields'),
                        directives: [],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    fragmentDefinitionTransactionHistoryFields,
  ],
);

class Query$TransactionHistoryBySender$transactions {
  Query$TransactionHistoryBySender$transactions({
    required this.pageInfo,
    required this.nodes,
  });

  factory Query$TransactionHistoryBySender$transactions.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    return Query$TransactionHistoryBySender$transactions(
      pageInfo: Query$TransactionHistoryBySender$transactions$pageInfo.fromJson(
        (l$pageInfo as Map<String, dynamic>),
      ),
      nodes: (l$nodes as List<dynamic>)
          .map(
            (e) => Fragment$TransactionHistoryFields.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
    );
  }

  final Query$TransactionHistoryBySender$transactions$pageInfo pageInfo;

  final List<Fragment$TransactionHistoryFields> nodes;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    return Object.hashAll([l$pageInfo, Object.hashAll(l$nodes.map((v) => v))]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionHistoryBySender$transactions ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    return true;
  }
}

class Query$TransactionHistoryBySender$transactions$pageInfo {
  Query$TransactionHistoryBySender$transactions$pageInfo({
    required this.hasPreviousPage,
    this.startCursor,
  });

  factory Query$TransactionHistoryBySender$transactions$pageInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$hasPreviousPage = json['hasPreviousPage'];
    final l$startCursor = json['startCursor'];
    return Query$TransactionHistoryBySender$transactions$pageInfo(
      hasPreviousPage: (l$hasPreviousPage as bool),
      startCursor: (l$startCursor as String?),
    );
  }

  final bool hasPreviousPage;

  final String? startCursor;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasPreviousPage = hasPreviousPage;
    _resultData['hasPreviousPage'] = l$hasPreviousPage;
    final l$startCursor = startCursor;
    _resultData['startCursor'] = l$startCursor;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasPreviousPage = hasPreviousPage;
    final l$startCursor = startCursor;
    return Object.hashAll([l$hasPreviousPage, l$startCursor]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionHistoryBySender$transactions$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasPreviousPage = hasPreviousPage;
    final lOther$hasPreviousPage = other.hasPreviousPage;
    if (l$hasPreviousPage != lOther$hasPreviousPage) {
      return false;
    }
    final l$startCursor = startCursor;
    final lOther$startCursor = other.startCursor;
    if (l$startCursor != lOther$startCursor) {
      return false;
    }
    return true;
  }
}

class Variables$Query$TransactionsByObject {
  factory Variables$Query$TransactionsByObject({
    required String object,
    required int first,
    String? after,
  }) => Variables$Query$TransactionsByObject._({
    r'object': object,
    r'first': first,
    if (after != null) r'after': after,
  });

  Variables$Query$TransactionsByObject._(this._$data);

  factory Variables$Query$TransactionsByObject.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$object = data['object'];
    result$data['object'] = (l$object as String);
    final l$first = data['first'];
    result$data['first'] = (l$first as int);
    if (data.containsKey('after')) {
      final l$after = data['after'];
      result$data['after'] = (l$after as String?);
    }
    return Variables$Query$TransactionsByObject._(result$data);
  }

  Map<String, dynamic> _$data;

  String get object => (_$data['object'] as String);

  int get first => (_$data['first'] as int);

  String? get after => (_$data['after'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$object = object;
    result$data['object'] = l$object;
    final l$first = first;
    result$data['first'] = l$first;
    if (_$data.containsKey('after')) {
      final l$after = after;
      result$data['after'] = l$after;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$TransactionsByObject ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$object = object;
    final lOther$object = other.object;
    if (l$object != lOther$object) {
      return false;
    }
    final l$first = first;
    final lOther$first = other.first;
    if (l$first != lOther$first) {
      return false;
    }
    final l$after = after;
    final lOther$after = other.after;
    if (_$data.containsKey('after') != other._$data.containsKey('after')) {
      return false;
    }
    if (l$after != lOther$after) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$object = object;
    final l$first = first;
    final l$after = after;
    return Object.hashAll([
      l$object,
      l$first,
      _$data.containsKey('after') ? l$after : const {},
    ]);
  }
}

class Query$TransactionsByObject {
  Query$TransactionsByObject({this.transactions});

  factory Query$TransactionsByObject.fromJson(Map<String, dynamic> json) {
    final l$transactions = json['transactions'];
    return Query$TransactionsByObject(
      transactions: l$transactions == null
          ? null
          : Query$TransactionsByObject$transactions.fromJson(
              (l$transactions as Map<String, dynamic>),
            ),
    );
  }

  final Query$TransactionsByObject$transactions? transactions;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$transactions = transactions;
    _resultData['transactions'] = l$transactions?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$transactions = transactions;
    return Object.hashAll([l$transactions]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionsByObject ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$transactions = transactions;
    final lOther$transactions = other.transactions;
    if (l$transactions != lOther$transactions) {
      return false;
    }
    return true;
  }
}

const documentNodeQueryTransactionsByObject = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'TransactionsByObject'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'object')),
          type: NamedTypeNode(
            name: NameNode(value: 'SuiAddress'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'first')),
          type: NamedTypeNode(name: NameNode(value: 'Int'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'after')),
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'transactions'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'first'),
                value: VariableNode(name: NameNode(value: 'first')),
              ),
              ArgumentNode(
                name: NameNode(value: 'after'),
                value: VariableNode(name: NameNode(value: 'after')),
              ),
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: ObjectValueNode(
                  fields: [
                    ObjectFieldNode(
                      name: NameNode(value: 'affectedObject'),
                      value: VariableNode(name: NameNode(value: 'object')),
                    ),
                  ],
                ),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'pageInfo'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'hasNextPage'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'endCursor'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                    ],
                  ),
                ),
                FieldNode(
                  name: NameNode(value: 'nodes'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'digest'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
);

class Query$TransactionsByObject$transactions {
  Query$TransactionsByObject$transactions({
    required this.pageInfo,
    required this.nodes,
  });

  factory Query$TransactionsByObject$transactions.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    return Query$TransactionsByObject$transactions(
      pageInfo: Query$TransactionsByObject$transactions$pageInfo.fromJson(
        (l$pageInfo as Map<String, dynamic>),
      ),
      nodes: (l$nodes as List<dynamic>)
          .map(
            (e) => Query$TransactionsByObject$transactions$nodes.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
    );
  }

  final Query$TransactionsByObject$transactions$pageInfo pageInfo;

  final List<Query$TransactionsByObject$transactions$nodes> nodes;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    return Object.hashAll([l$pageInfo, Object.hashAll(l$nodes.map((v) => v))]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionsByObject$transactions ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    return true;
  }
}

class Query$TransactionsByObject$transactions$pageInfo {
  Query$TransactionsByObject$transactions$pageInfo({
    required this.hasNextPage,
    this.endCursor,
  });

  factory Query$TransactionsByObject$transactions$pageInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$hasNextPage = json['hasNextPage'];
    final l$endCursor = json['endCursor'];
    return Query$TransactionsByObject$transactions$pageInfo(
      hasNextPage: (l$hasNextPage as bool),
      endCursor: (l$endCursor as String?),
    );
  }

  final bool hasNextPage;

  final String? endCursor;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$endCursor = endCursor;
    _resultData['endCursor'] = l$endCursor;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasNextPage = hasNextPage;
    final l$endCursor = endCursor;
    return Object.hashAll([l$hasNextPage, l$endCursor]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionsByObject$transactions$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    final l$endCursor = endCursor;
    final lOther$endCursor = other.endCursor;
    if (l$endCursor != lOther$endCursor) {
      return false;
    }
    return true;
  }
}

class Query$TransactionsByObject$transactions$nodes {
  Query$TransactionsByObject$transactions$nodes({required this.digest});

  factory Query$TransactionsByObject$transactions$nodes.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$digest = json['digest'];
    return Query$TransactionsByObject$transactions$nodes(
      digest: (l$digest as String),
    );
  }

  final String digest;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$digest = digest;
    _resultData['digest'] = l$digest;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$digest = digest;
    return Object.hashAll([l$digest]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$TransactionsByObject$transactions$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$digest = digest;
    final lOther$digest = other.digest;
    if (l$digest != lOther$digest) {
      return false;
    }
    return true;
  }
}

class Variables$Query$EpochSummary {
  factory Variables$Query$EpochSummary({int? epochId}) =>
      Variables$Query$EpochSummary._({
        if (epochId != null) r'epochId': epochId,
      });

  Variables$Query$EpochSummary._(this._$data);

  factory Variables$Query$EpochSummary.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('epochId')) {
      final l$epochId = data['epochId'];
      result$data['epochId'] = (l$epochId as int?);
    }
    return Variables$Query$EpochSummary._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get epochId => (_$data['epochId'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('epochId')) {
      final l$epochId = epochId;
      result$data['epochId'] = l$epochId;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$EpochSummary ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$epochId = epochId;
    final lOther$epochId = other.epochId;
    if (_$data.containsKey('epochId') != other._$data.containsKey('epochId')) {
      return false;
    }
    if (l$epochId != lOther$epochId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$epochId = epochId;
    return Object.hashAll([
      _$data.containsKey('epochId') ? l$epochId : const {},
    ]);
  }
}

class Query$EpochSummary {
  Query$EpochSummary({this.epoch});

  factory Query$EpochSummary.fromJson(Map<String, dynamic> json) {
    final l$epoch = json['epoch'];
    return Query$EpochSummary(
      epoch: l$epoch == null
          ? null
          : Query$EpochSummary$epoch.fromJson(
              (l$epoch as Map<String, dynamic>),
            ),
    );
  }

  final Query$EpochSummary$epoch? epoch;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$epoch = epoch;
    _resultData['epoch'] = l$epoch?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$epoch = epoch;
    return Object.hashAll([l$epoch]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EpochSummary || runtimeType != other.runtimeType) {
      return false;
    }
    final l$epoch = epoch;
    final lOther$epoch = other.epoch;
    if (l$epoch != lOther$epoch) {
      return false;
    }
    return true;
  }
}

const documentNodeQueryEpochSummary = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'EpochSummary'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'epochId')),
          type: NamedTypeNode(
            name: NameNode(value: 'UInt53'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'epoch'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'epochId'),
                value: VariableNode(name: NameNode(value: 'epochId')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'epochId'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'referenceGasPrice'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'totalTransactions'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'startTimestamp'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'endTimestamp'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
);

class Query$EpochSummary$epoch {
  Query$EpochSummary$epoch({
    required this.epochId,
    this.referenceGasPrice,
    this.totalTransactions,
    this.startTimestamp,
    this.endTimestamp,
  });

  factory Query$EpochSummary$epoch.fromJson(Map<String, dynamic> json) {
    final l$epochId = json['epochId'];
    final l$referenceGasPrice = json['referenceGasPrice'];
    final l$totalTransactions = json['totalTransactions'];
    final l$startTimestamp = json['startTimestamp'];
    final l$endTimestamp = json['endTimestamp'];
    return Query$EpochSummary$epoch(
      epochId: (l$epochId as int),
      referenceGasPrice: (l$referenceGasPrice as String?),
      totalTransactions: (l$totalTransactions as int?),
      startTimestamp: (l$startTimestamp as String?),
      endTimestamp: (l$endTimestamp as String?),
    );
  }

  final int epochId;

  final String? referenceGasPrice;

  final int? totalTransactions;

  final String? startTimestamp;

  final String? endTimestamp;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$epochId = epochId;
    _resultData['epochId'] = l$epochId;
    final l$referenceGasPrice = referenceGasPrice;
    _resultData['referenceGasPrice'] = l$referenceGasPrice;
    final l$totalTransactions = totalTransactions;
    _resultData['totalTransactions'] = l$totalTransactions;
    final l$startTimestamp = startTimestamp;
    _resultData['startTimestamp'] = l$startTimestamp;
    final l$endTimestamp = endTimestamp;
    _resultData['endTimestamp'] = l$endTimestamp;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$epochId = epochId;
    final l$referenceGasPrice = referenceGasPrice;
    final l$totalTransactions = totalTransactions;
    final l$startTimestamp = startTimestamp;
    final l$endTimestamp = endTimestamp;
    return Object.hashAll([
      l$epochId,
      l$referenceGasPrice,
      l$totalTransactions,
      l$startTimestamp,
      l$endTimestamp,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EpochSummary$epoch ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$epochId = epochId;
    final lOther$epochId = other.epochId;
    if (l$epochId != lOther$epochId) {
      return false;
    }
    final l$referenceGasPrice = referenceGasPrice;
    final lOther$referenceGasPrice = other.referenceGasPrice;
    if (l$referenceGasPrice != lOther$referenceGasPrice) {
      return false;
    }
    final l$totalTransactions = totalTransactions;
    final lOther$totalTransactions = other.totalTransactions;
    if (l$totalTransactions != lOther$totalTransactions) {
      return false;
    }
    final l$startTimestamp = startTimestamp;
    final lOther$startTimestamp = other.startTimestamp;
    if (l$startTimestamp != lOther$startTimestamp) {
      return false;
    }
    final l$endTimestamp = endTimestamp;
    final lOther$endTimestamp = other.endTimestamp;
    if (l$endTimestamp != lOther$endTimestamp) {
      return false;
    }
    return true;
  }
}

class Variables$Query$ActiveValidators {
  factory Variables$Query$ActiveValidators({
    int? epochId,
    required int first,
    String? after,
  }) => Variables$Query$ActiveValidators._({
    if (epochId != null) r'epochId': epochId,
    r'first': first,
    if (after != null) r'after': after,
  });

  Variables$Query$ActiveValidators._(this._$data);

  factory Variables$Query$ActiveValidators.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('epochId')) {
      final l$epochId = data['epochId'];
      result$data['epochId'] = (l$epochId as int?);
    }
    final l$first = data['first'];
    result$data['first'] = (l$first as int);
    if (data.containsKey('after')) {
      final l$after = data['after'];
      result$data['after'] = (l$after as String?);
    }
    return Variables$Query$ActiveValidators._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get epochId => (_$data['epochId'] as int?);

  int get first => (_$data['first'] as int);

  String? get after => (_$data['after'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('epochId')) {
      final l$epochId = epochId;
      result$data['epochId'] = l$epochId;
    }
    final l$first = first;
    result$data['first'] = l$first;
    if (_$data.containsKey('after')) {
      final l$after = after;
      result$data['after'] = l$after;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$ActiveValidators ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$epochId = epochId;
    final lOther$epochId = other.epochId;
    if (_$data.containsKey('epochId') != other._$data.containsKey('epochId')) {
      return false;
    }
    if (l$epochId != lOther$epochId) {
      return false;
    }
    final l$first = first;
    final lOther$first = other.first;
    if (l$first != lOther$first) {
      return false;
    }
    final l$after = after;
    final lOther$after = other.after;
    if (_$data.containsKey('after') != other._$data.containsKey('after')) {
      return false;
    }
    if (l$after != lOther$after) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$epochId = epochId;
    final l$first = first;
    final l$after = after;
    return Object.hashAll([
      _$data.containsKey('epochId') ? l$epochId : const {},
      l$first,
      _$data.containsKey('after') ? l$after : const {},
    ]);
  }
}

class Query$ActiveValidators {
  Query$ActiveValidators({this.epoch});

  factory Query$ActiveValidators.fromJson(Map<String, dynamic> json) {
    final l$epoch = json['epoch'];
    return Query$ActiveValidators(
      epoch: l$epoch == null
          ? null
          : Query$ActiveValidators$epoch.fromJson(
              (l$epoch as Map<String, dynamic>),
            ),
    );
  }

  final Query$ActiveValidators$epoch? epoch;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$epoch = epoch;
    _resultData['epoch'] = l$epoch?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$epoch = epoch;
    return Object.hashAll([l$epoch]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ActiveValidators || runtimeType != other.runtimeType) {
      return false;
    }
    final l$epoch = epoch;
    final lOther$epoch = other.epoch;
    if (l$epoch != lOther$epoch) {
      return false;
    }
    return true;
  }
}

const documentNodeQueryActiveValidators = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'ActiveValidators'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'epochId')),
          type: NamedTypeNode(
            name: NameNode(value: 'UInt53'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'first')),
          type: NamedTypeNode(name: NameNode(value: 'Int'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'after')),
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'epoch'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'epochId'),
                value: VariableNode(name: NameNode(value: 'epochId')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'validatorSet'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'activeValidators'),
                        alias: null,
                        arguments: [
                          ArgumentNode(
                            name: NameNode(value: 'first'),
                            value: VariableNode(name: NameNode(value: 'first')),
                          ),
                          ArgumentNode(
                            name: NameNode(value: 'after'),
                            value: VariableNode(name: NameNode(value: 'after')),
                          ),
                        ],
                        directives: [],
                        selectionSet: SelectionSetNode(
                          selections: [
                            FieldNode(
                              name: NameNode(value: 'pageInfo'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: SelectionSetNode(
                                selections: [
                                  FieldNode(
                                    name: NameNode(value: 'hasNextPage'),
                                    alias: null,
                                    arguments: [],
                                    directives: [],
                                    selectionSet: null,
                                  ),
                                  FieldNode(
                                    name: NameNode(value: 'endCursor'),
                                    alias: null,
                                    arguments: [],
                                    directives: [],
                                    selectionSet: null,
                                  ),
                                ],
                              ),
                            ),
                            FieldNode(
                              name: NameNode(value: 'nodes'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: SelectionSetNode(
                                selections: [
                                  FieldNode(
                                    name: NameNode(value: 'contents'),
                                    alias: null,
                                    arguments: [],
                                    directives: [],
                                    selectionSet: SelectionSetNode(
                                      selections: [
                                        FieldNode(
                                          name: NameNode(value: 'json'),
                                          alias: null,
                                          arguments: [],
                                          directives: [],
                                          selectionSet: null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
);

class Query$ActiveValidators$epoch {
  Query$ActiveValidators$epoch({this.validatorSet});

  factory Query$ActiveValidators$epoch.fromJson(Map<String, dynamic> json) {
    final l$validatorSet = json['validatorSet'];
    return Query$ActiveValidators$epoch(
      validatorSet: l$validatorSet == null
          ? null
          : Query$ActiveValidators$epoch$validatorSet.fromJson(
              (l$validatorSet as Map<String, dynamic>),
            ),
    );
  }

  final Query$ActiveValidators$epoch$validatorSet? validatorSet;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$validatorSet = validatorSet;
    _resultData['validatorSet'] = l$validatorSet?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$validatorSet = validatorSet;
    return Object.hashAll([l$validatorSet]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ActiveValidators$epoch ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$validatorSet = validatorSet;
    final lOther$validatorSet = other.validatorSet;
    if (l$validatorSet != lOther$validatorSet) {
      return false;
    }
    return true;
  }
}

class Query$ActiveValidators$epoch$validatorSet {
  Query$ActiveValidators$epoch$validatorSet({this.activeValidators});

  factory Query$ActiveValidators$epoch$validatorSet.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$activeValidators = json['activeValidators'];
    return Query$ActiveValidators$epoch$validatorSet(
      activeValidators: l$activeValidators == null
          ? null
          : Query$ActiveValidators$epoch$validatorSet$activeValidators.fromJson(
              (l$activeValidators as Map<String, dynamic>),
            ),
    );
  }

  final Query$ActiveValidators$epoch$validatorSet$activeValidators?
  activeValidators;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$activeValidators = activeValidators;
    _resultData['activeValidators'] = l$activeValidators?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$activeValidators = activeValidators;
    return Object.hashAll([l$activeValidators]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ActiveValidators$epoch$validatorSet ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$activeValidators = activeValidators;
    final lOther$activeValidators = other.activeValidators;
    if (l$activeValidators != lOther$activeValidators) {
      return false;
    }
    return true;
  }
}

class Query$ActiveValidators$epoch$validatorSet$activeValidators {
  Query$ActiveValidators$epoch$validatorSet$activeValidators({
    required this.pageInfo,
    required this.nodes,
  });

  factory Query$ActiveValidators$epoch$validatorSet$activeValidators.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    return Query$ActiveValidators$epoch$validatorSet$activeValidators(
      pageInfo:
          Query$ActiveValidators$epoch$validatorSet$activeValidators$pageInfo.fromJson(
            (l$pageInfo as Map<String, dynamic>),
          ),
      nodes: (l$nodes as List<dynamic>)
          .map(
            (e) =>
                Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes.fromJson(
                  (e as Map<String, dynamic>),
                ),
          )
          .toList(),
    );
  }

  final Query$ActiveValidators$epoch$validatorSet$activeValidators$pageInfo
  pageInfo;

  final List<Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes>
  nodes;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    return Object.hashAll([l$pageInfo, Object.hashAll(l$nodes.map((v) => v))]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ActiveValidators$epoch$validatorSet$activeValidators ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    return true;
  }
}

class Query$ActiveValidators$epoch$validatorSet$activeValidators$pageInfo {
  Query$ActiveValidators$epoch$validatorSet$activeValidators$pageInfo({
    required this.hasNextPage,
    this.endCursor,
  });

  factory Query$ActiveValidators$epoch$validatorSet$activeValidators$pageInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$hasNextPage = json['hasNextPage'];
    final l$endCursor = json['endCursor'];
    return Query$ActiveValidators$epoch$validatorSet$activeValidators$pageInfo(
      hasNextPage: (l$hasNextPage as bool),
      endCursor: (l$endCursor as String?),
    );
  }

  final bool hasNextPage;

  final String? endCursor;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$endCursor = endCursor;
    _resultData['endCursor'] = l$endCursor;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasNextPage = hasNextPage;
    final l$endCursor = endCursor;
    return Object.hashAll([l$hasNextPage, l$endCursor]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$ActiveValidators$epoch$validatorSet$activeValidators$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    final l$endCursor = endCursor;
    final lOther$endCursor = other.endCursor;
    if (l$endCursor != lOther$endCursor) {
      return false;
    }
    return true;
  }
}

class Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes {
  Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes({
    this.contents,
  });

  factory Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$contents = json['contents'];
    return Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes(
      contents: l$contents == null
          ? null
          : Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes$contents.fromJson(
              (l$contents as Map<String, dynamic>),
            ),
    );
  }

  final Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes$contents?
  contents;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$contents = contents;
    _resultData['contents'] = l$contents?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$contents = contents;
    return Object.hashAll([l$contents]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$contents = contents;
    final lOther$contents = other.contents;
    if (l$contents != lOther$contents) {
      return false;
    }
    return true;
  }
}

class Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes$contents {
  Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes$contents({
    this.json,
  });

  factory Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes$contents.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$json = json['json'];
    return Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes$contents(
      json: (l$json as Map<String, dynamic>?),
    );
  }

  final Map<String, dynamic>? json;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$json = json;
    _resultData['json'] = l$json;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$json = json;
    return Object.hashAll([l$json]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$ActiveValidators$epoch$validatorSet$activeValidators$nodes$contents ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$json = json;
    final lOther$json = other.json;
    if (l$json != lOther$json) {
      return false;
    }
    return true;
  }
}

class Variables$Query$StakedSui {
  factory Variables$Query$StakedSui({
    required String owner,
    required int first,
    String? after,
  }) => Variables$Query$StakedSui._({
    r'owner': owner,
    r'first': first,
    if (after != null) r'after': after,
  });

  Variables$Query$StakedSui._(this._$data);

  factory Variables$Query$StakedSui.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$owner = data['owner'];
    result$data['owner'] = (l$owner as String);
    final l$first = data['first'];
    result$data['first'] = (l$first as int);
    if (data.containsKey('after')) {
      final l$after = data['after'];
      result$data['after'] = (l$after as String?);
    }
    return Variables$Query$StakedSui._(result$data);
  }

  Map<String, dynamic> _$data;

  String get owner => (_$data['owner'] as String);

  int get first => (_$data['first'] as int);

  String? get after => (_$data['after'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$owner = owner;
    result$data['owner'] = l$owner;
    final l$first = first;
    result$data['first'] = l$first;
    if (_$data.containsKey('after')) {
      final l$after = after;
      result$data['after'] = l$after;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$StakedSui ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$owner = owner;
    final lOther$owner = other.owner;
    if (l$owner != lOther$owner) {
      return false;
    }
    final l$first = first;
    final lOther$first = other.first;
    if (l$first != lOther$first) {
      return false;
    }
    final l$after = after;
    final lOther$after = other.after;
    if (_$data.containsKey('after') != other._$data.containsKey('after')) {
      return false;
    }
    if (l$after != lOther$after) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$owner = owner;
    final l$first = first;
    final l$after = after;
    return Object.hashAll([
      l$owner,
      l$first,
      _$data.containsKey('after') ? l$after : const {},
    ]);
  }
}

class Query$StakedSui {
  Query$StakedSui({this.address});

  factory Query$StakedSui.fromJson(Map<String, dynamic> json) {
    final l$address = json['address'];
    return Query$StakedSui(
      address: l$address == null
          ? null
          : Query$StakedSui$address.fromJson(
              (l$address as Map<String, dynamic>),
            ),
    );
  }

  final Query$StakedSui$address? address;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    return Object.hashAll([l$address]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$StakedSui || runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    return true;
  }
}

const documentNodeQueryStakedSui = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'StakedSui'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'owner')),
          type: NamedTypeNode(
            name: NameNode(value: 'SuiAddress'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'first')),
          type: NamedTypeNode(name: NameNode(value: 'Int'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'after')),
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'address'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'address'),
                value: VariableNode(name: NameNode(value: 'owner')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'objects'),
                  alias: null,
                  arguments: [
                    ArgumentNode(
                      name: NameNode(value: 'first'),
                      value: VariableNode(name: NameNode(value: 'first')),
                    ),
                    ArgumentNode(
                      name: NameNode(value: 'after'),
                      value: VariableNode(name: NameNode(value: 'after')),
                    ),
                    ArgumentNode(
                      name: NameNode(value: 'filter'),
                      value: ObjectValueNode(
                        fields: [
                          ObjectFieldNode(
                            name: NameNode(value: 'type'),
                            value: StringValueNode(
                              value: '0x3::staking_pool::StakedSui',
                              isBlock: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'pageInfo'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(
                          selections: [
                            FieldNode(
                              name: NameNode(value: 'hasNextPage'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: null,
                            ),
                            FieldNode(
                              name: NameNode(value: 'endCursor'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: null,
                            ),
                          ],
                        ),
                      ),
                      FieldNode(
                        name: NameNode(value: 'nodes'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(
                          selections: [
                            FieldNode(
                              name: NameNode(value: 'address'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: null,
                            ),
                            FieldNode(
                              name: NameNode(value: 'contents'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: SelectionSetNode(
                                selections: [
                                  FieldNode(
                                    name: NameNode(value: 'json'),
                                    alias: null,
                                    arguments: [],
                                    directives: [],
                                    selectionSet: null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
);

class Query$StakedSui$address {
  Query$StakedSui$address({this.objects});

  factory Query$StakedSui$address.fromJson(Map<String, dynamic> json) {
    final l$objects = json['objects'];
    return Query$StakedSui$address(
      objects: l$objects == null
          ? null
          : Query$StakedSui$address$objects.fromJson(
              (l$objects as Map<String, dynamic>),
            ),
    );
  }

  final Query$StakedSui$address$objects? objects;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$objects = objects;
    _resultData['objects'] = l$objects?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$objects = objects;
    return Object.hashAll([l$objects]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$StakedSui$address || runtimeType != other.runtimeType) {
      return false;
    }
    final l$objects = objects;
    final lOther$objects = other.objects;
    if (l$objects != lOther$objects) {
      return false;
    }
    return true;
  }
}

class Query$StakedSui$address$objects {
  Query$StakedSui$address$objects({
    required this.pageInfo,
    required this.nodes,
  });

  factory Query$StakedSui$address$objects.fromJson(Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    return Query$StakedSui$address$objects(
      pageInfo: Query$StakedSui$address$objects$pageInfo.fromJson(
        (l$pageInfo as Map<String, dynamic>),
      ),
      nodes: (l$nodes as List<dynamic>)
          .map(
            (e) => Query$StakedSui$address$objects$nodes.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
    );
  }

  final Query$StakedSui$address$objects$pageInfo pageInfo;

  final List<Query$StakedSui$address$objects$nodes> nodes;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    return Object.hashAll([l$pageInfo, Object.hashAll(l$nodes.map((v) => v))]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$StakedSui$address$objects ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    return true;
  }
}

class Query$StakedSui$address$objects$pageInfo {
  Query$StakedSui$address$objects$pageInfo({
    required this.hasNextPage,
    this.endCursor,
  });

  factory Query$StakedSui$address$objects$pageInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$hasNextPage = json['hasNextPage'];
    final l$endCursor = json['endCursor'];
    return Query$StakedSui$address$objects$pageInfo(
      hasNextPage: (l$hasNextPage as bool),
      endCursor: (l$endCursor as String?),
    );
  }

  final bool hasNextPage;

  final String? endCursor;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$endCursor = endCursor;
    _resultData['endCursor'] = l$endCursor;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasNextPage = hasNextPage;
    final l$endCursor = endCursor;
    return Object.hashAll([l$hasNextPage, l$endCursor]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$StakedSui$address$objects$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    final l$endCursor = endCursor;
    final lOther$endCursor = other.endCursor;
    if (l$endCursor != lOther$endCursor) {
      return false;
    }
    return true;
  }
}

class Query$StakedSui$address$objects$nodes {
  Query$StakedSui$address$objects$nodes({required this.address, this.contents});

  factory Query$StakedSui$address$objects$nodes.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$address = json['address'];
    final l$contents = json['contents'];
    return Query$StakedSui$address$objects$nodes(
      address: (l$address as String),
      contents: l$contents == null
          ? null
          : Query$StakedSui$address$objects$nodes$contents.fromJson(
              (l$contents as Map<String, dynamic>),
            ),
    );
  }

  final String address;

  final Query$StakedSui$address$objects$nodes$contents? contents;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address;
    final l$contents = contents;
    _resultData['contents'] = l$contents?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    final l$contents = contents;
    return Object.hashAll([l$address, l$contents]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$StakedSui$address$objects$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    final l$contents = contents;
    final lOther$contents = other.contents;
    if (l$contents != lOther$contents) {
      return false;
    }
    return true;
  }
}

class Query$StakedSui$address$objects$nodes$contents {
  Query$StakedSui$address$objects$nodes$contents({this.json});

  factory Query$StakedSui$address$objects$nodes$contents.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$json = json['json'];
    return Query$StakedSui$address$objects$nodes$contents(
      json: (l$json as Map<String, dynamic>?),
    );
  }

  final Map<String, dynamic>? json;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$json = json;
    _resultData['json'] = l$json;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$json = json;
    return Object.hashAll([l$json]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$StakedSui$address$objects$nodes$contents ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$json = json;
    final lOther$json = other.json;
    if (l$json != lOther$json) {
      return false;
    }
    return true;
  }
}

class Variables$Query$EventsByModule {
  factory Variables$Query$EventsByModule({
    required String module,
    required int first,
    String? after,
  }) => Variables$Query$EventsByModule._({
    r'module': module,
    r'first': first,
    if (after != null) r'after': after,
  });

  Variables$Query$EventsByModule._(this._$data);

  factory Variables$Query$EventsByModule.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$module = data['module'];
    result$data['module'] = (l$module as String);
    final l$first = data['first'];
    result$data['first'] = (l$first as int);
    if (data.containsKey('after')) {
      final l$after = data['after'];
      result$data['after'] = (l$after as String?);
    }
    return Variables$Query$EventsByModule._(result$data);
  }

  Map<String, dynamic> _$data;

  String get module => (_$data['module'] as String);

  int get first => (_$data['first'] as int);

  String? get after => (_$data['after'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$module = module;
    result$data['module'] = l$module;
    final l$first = first;
    result$data['first'] = l$first;
    if (_$data.containsKey('after')) {
      final l$after = after;
      result$data['after'] = l$after;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$EventsByModule ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$module = module;
    final lOther$module = other.module;
    if (l$module != lOther$module) {
      return false;
    }
    final l$first = first;
    final lOther$first = other.first;
    if (l$first != lOther$first) {
      return false;
    }
    final l$after = after;
    final lOther$after = other.after;
    if (_$data.containsKey('after') != other._$data.containsKey('after')) {
      return false;
    }
    if (l$after != lOther$after) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$module = module;
    final l$first = first;
    final l$after = after;
    return Object.hashAll([
      l$module,
      l$first,
      _$data.containsKey('after') ? l$after : const {},
    ]);
  }
}

class Query$EventsByModule {
  Query$EventsByModule({this.events});

  factory Query$EventsByModule.fromJson(Map<String, dynamic> json) {
    final l$events = json['events'];
    return Query$EventsByModule(
      events: l$events == null
          ? null
          : Query$EventsByModule$events.fromJson(
              (l$events as Map<String, dynamic>),
            ),
    );
  }

  final Query$EventsByModule$events? events;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$events = events;
    _resultData['events'] = l$events?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$events = events;
    return Object.hashAll([l$events]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EventsByModule || runtimeType != other.runtimeType) {
      return false;
    }
    final l$events = events;
    final lOther$events = other.events;
    if (l$events != lOther$events) {
      return false;
    }
    return true;
  }
}

const documentNodeQueryEventsByModule = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'EventsByModule'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'module')),
          type: NamedTypeNode(name: NameNode(value: 'String'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'first')),
          type: NamedTypeNode(name: NameNode(value: 'Int'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'after')),
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'events'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'first'),
                value: VariableNode(name: NameNode(value: 'first')),
              ),
              ArgumentNode(
                name: NameNode(value: 'after'),
                value: VariableNode(name: NameNode(value: 'after')),
              ),
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: ObjectValueNode(
                  fields: [
                    ObjectFieldNode(
                      name: NameNode(value: 'module'),
                      value: VariableNode(name: NameNode(value: 'module')),
                    ),
                  ],
                ),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'pageInfo'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'hasNextPage'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'endCursor'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                    ],
                  ),
                ),
                FieldNode(
                  name: NameNode(value: 'nodes'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'transactionModule'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(
                          selections: [
                            FieldNode(
                              name: NameNode(value: 'name'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: null,
                            ),
                          ],
                        ),
                      ),
                      FieldNode(
                        name: NameNode(value: 'sender'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(
                          selections: [
                            FieldNode(
                              name: NameNode(value: 'address'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: null,
                            ),
                          ],
                        ),
                      ),
                      FieldNode(
                        name: NameNode(value: 'contents'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(
                          selections: [
                            FieldNode(
                              name: NameNode(value: 'type'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: SelectionSetNode(
                                selections: [
                                  FieldNode(
                                    name: NameNode(value: 'repr'),
                                    alias: null,
                                    arguments: [],
                                    directives: [],
                                    selectionSet: null,
                                  ),
                                ],
                              ),
                            ),
                            FieldNode(
                              name: NameNode(value: 'json'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
);

class Query$EventsByModule$events {
  Query$EventsByModule$events({required this.pageInfo, required this.nodes});

  factory Query$EventsByModule$events.fromJson(Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    return Query$EventsByModule$events(
      pageInfo: Query$EventsByModule$events$pageInfo.fromJson(
        (l$pageInfo as Map<String, dynamic>),
      ),
      nodes: (l$nodes as List<dynamic>)
          .map(
            (e) => Query$EventsByModule$events$nodes.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
    );
  }

  final Query$EventsByModule$events$pageInfo pageInfo;

  final List<Query$EventsByModule$events$nodes> nodes;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    return Object.hashAll([l$pageInfo, Object.hashAll(l$nodes.map((v) => v))]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EventsByModule$events ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    return true;
  }
}

class Query$EventsByModule$events$pageInfo {
  Query$EventsByModule$events$pageInfo({
    required this.hasNextPage,
    this.endCursor,
  });

  factory Query$EventsByModule$events$pageInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$hasNextPage = json['hasNextPage'];
    final l$endCursor = json['endCursor'];
    return Query$EventsByModule$events$pageInfo(
      hasNextPage: (l$hasNextPage as bool),
      endCursor: (l$endCursor as String?),
    );
  }

  final bool hasNextPage;

  final String? endCursor;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$endCursor = endCursor;
    _resultData['endCursor'] = l$endCursor;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasNextPage = hasNextPage;
    final l$endCursor = endCursor;
    return Object.hashAll([l$hasNextPage, l$endCursor]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EventsByModule$events$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    final l$endCursor = endCursor;
    final lOther$endCursor = other.endCursor;
    if (l$endCursor != lOther$endCursor) {
      return false;
    }
    return true;
  }
}

class Query$EventsByModule$events$nodes {
  Query$EventsByModule$events$nodes({
    this.transactionModule,
    this.sender,
    this.contents,
  });

  factory Query$EventsByModule$events$nodes.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$transactionModule = json['transactionModule'];
    final l$sender = json['sender'];
    final l$contents = json['contents'];
    return Query$EventsByModule$events$nodes(
      transactionModule: l$transactionModule == null
          ? null
          : Query$EventsByModule$events$nodes$transactionModule.fromJson(
              (l$transactionModule as Map<String, dynamic>),
            ),
      sender: l$sender == null
          ? null
          : Query$EventsByModule$events$nodes$sender.fromJson(
              (l$sender as Map<String, dynamic>),
            ),
      contents: l$contents == null
          ? null
          : Query$EventsByModule$events$nodes$contents.fromJson(
              (l$contents as Map<String, dynamic>),
            ),
    );
  }

  final Query$EventsByModule$events$nodes$transactionModule? transactionModule;

  final Query$EventsByModule$events$nodes$sender? sender;

  final Query$EventsByModule$events$nodes$contents? contents;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$transactionModule = transactionModule;
    _resultData['transactionModule'] = l$transactionModule?.toJson();
    final l$sender = sender;
    _resultData['sender'] = l$sender?.toJson();
    final l$contents = contents;
    _resultData['contents'] = l$contents?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$transactionModule = transactionModule;
    final l$sender = sender;
    final l$contents = contents;
    return Object.hashAll([l$transactionModule, l$sender, l$contents]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EventsByModule$events$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$transactionModule = transactionModule;
    final lOther$transactionModule = other.transactionModule;
    if (l$transactionModule != lOther$transactionModule) {
      return false;
    }
    final l$sender = sender;
    final lOther$sender = other.sender;
    if (l$sender != lOther$sender) {
      return false;
    }
    final l$contents = contents;
    final lOther$contents = other.contents;
    if (l$contents != lOther$contents) {
      return false;
    }
    return true;
  }
}

class Query$EventsByModule$events$nodes$transactionModule {
  Query$EventsByModule$events$nodes$transactionModule({required this.name});

  factory Query$EventsByModule$events$nodes$transactionModule.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$name = json['name'];
    return Query$EventsByModule$events$nodes$transactionModule(
      name: (l$name as String),
    );
  }

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    return Object.hashAll([l$name]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EventsByModule$events$nodes$transactionModule ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

class Query$EventsByModule$events$nodes$sender {
  Query$EventsByModule$events$nodes$sender({required this.address});

  factory Query$EventsByModule$events$nodes$sender.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$address = json['address'];
    return Query$EventsByModule$events$nodes$sender(
      address: (l$address as String),
    );
  }

  final String address;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$address = address;
    _resultData['address'] = l$address;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$address = address;
    return Object.hashAll([l$address]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EventsByModule$events$nodes$sender ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    return true;
  }
}

class Query$EventsByModule$events$nodes$contents {
  Query$EventsByModule$events$nodes$contents({this.type, this.json});

  factory Query$EventsByModule$events$nodes$contents.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$type = json['type'];
    final l$json = json['json'];
    return Query$EventsByModule$events$nodes$contents(
      type: l$type == null
          ? null
          : Query$EventsByModule$events$nodes$contents$type.fromJson(
              (l$type as Map<String, dynamic>),
            ),
      json: (l$json as Map<String, dynamic>?),
    );
  }

  final Query$EventsByModule$events$nodes$contents$type? type;

  final Map<String, dynamic>? json;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$type = type;
    _resultData['type'] = l$type?.toJson();
    final l$json = json;
    _resultData['json'] = l$json;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$type = type;
    final l$json = json;
    return Object.hashAll([l$type, l$json]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EventsByModule$events$nodes$contents ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$json = json;
    final lOther$json = other.json;
    if (l$json != lOther$json) {
      return false;
    }
    return true;
  }
}

class Query$EventsByModule$events$nodes$contents$type {
  Query$EventsByModule$events$nodes$contents$type({required this.repr});

  factory Query$EventsByModule$events$nodes$contents$type.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$repr = json['repr'];
    return Query$EventsByModule$events$nodes$contents$type(
      repr: (l$repr as String),
    );
  }

  final String repr;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$repr = repr;
    _resultData['repr'] = l$repr;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$repr = repr;
    return Object.hashAll([l$repr]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$EventsByModule$events$nodes$contents$type ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$repr = repr;
    final lOther$repr = other.repr;
    if (l$repr != lOther$repr) {
      return false;
    }
    return true;
  }
}
