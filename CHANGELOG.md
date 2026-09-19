## 0.11.4

### Added

* Move call packages on transaction history. `TransactionHistoryFields` selects
  `MoveCallCommand.function.fullyQualifiedName`, and
  `SenderTransaction.moveCallPackages` carries the package each call targeted,
  in the same order as `moveCallNames`.

## 0.11.3

### Added

* Move call names on transaction history. `TransactionHistoryFields` selects
  `MoveCallCommand.function.name`, and `SenderTransaction.moveCallNames` carries
  them in call order.

## 0.11.2

### Added

* Events on transaction history. `TransactionHistoryFields` now selects
  `effects.events`, and `SenderTransaction.eventTypes` carries the fully
  qualified struct types a transaction emitted. Filled by both
  `queryTransactionsByAddress` and `queryTransactionsBySender`.

## 0.11.1

Synced to `1056b78`.

### Fixed

* GraphQL `getObjects` sends ids 40 at a time. One request carrying every id can
  exceed the node's request size limit.
* gRPC transaction timestamps keep their sub-second part.
* gRPC transaction effects carry the version the node reported.
* gRPC `getTransaction` reports a failed transaction as failed. `effects.status`
  was only requested when `include.effects` was set, so a default call reported
  every transaction as successful.
* GraphQL `getTransaction` and `listTransactions` return the checkpoint sequence
  number, which was always null on that transport.

### Changed

* Vendored protos refreshed from `sui-apis` `201981c`, adding the
  `TransactionExpiration` `VALIDITY` kind and its `AllowedProposers` message.
  The copies under `lib/grpc/proto/` had drifted behind the generated code, and
  `filter.proto` and `query_options.proto` were missing entirely.

### Removed

* Unreachable JSON-RPC response models: `Checkpoint`, `DevInspectResults`,
  `SuiExecutionResult`, `DynamicFieldPage`, `DynamicFieldInfo`, `Paged`,
  `NextCursor`, `ValidatorsApys`, `ValidatorApy`, and the `lib/types/`
  validator, version, and event models. None was exported from `package:sui_dart`.
* `RPCError`, `RPCValidationError`, and `RPCErrorRequest`, left from the removed
  JSON-RPC transport and never exported.

## 0.11.0

Synced to `ad407b5`.

### Added

* `Inputs.fundsWithdrawal` builds a `FUNDS_WITHDRAWAL` input against the sender's
  or sponsor's address balance.
* `coinWithBalance` and `createBalance` source from the address balance when the
  owned coins fall short, returning the leftover there via `coin::send_funds`.
  Funds held as `Balance<T>` were unspendable through this intent.

### Changed

* Gas payment falls back to the address balance when the sender owns no spare SUI
  coin object, instead of throwing `No valid gas coins found for the transaction.`.

### Fixed

* `simulateTransaction` resolves pending intents before converting to gRPC, which
  is synchronous. A `coinWithBalance` intent failed with `Unknown Command kind`.
* Command clones and `addInput` results keep `String` map keys, which the cast to
  `Map<String, dynamic>` on the way to gRPC requires.
* A `FUNDS_WITHDRAWAL` input converts to gRPC after a BCS round trip. Its
  reservation reads back as a `BigInt`, failing every dry run of a parsed
  transaction with `type '_BigIntImpl' is not a subtype of type 'String'`.
* A `ValidDuring` expiration reaches gRPC as `VALID_DURING` rather than `NONE`,
  keeping the replay protection address-balance gas depends on.

## 0.10.1

### Fixed

* `simulateTransaction` no longer disables transaction checks as a side effect of
  `doGasSelection: false`. Checks follow `checksEnabled` alone, and are disabled
  only when it is explicitly `false`. A caller that relied on the old coupling
  for a gasless simulate should pass `checksEnabled: false`, or build the
  transaction first so it carries an expiration.
* The gas budget dry-run simulates against a mocked gas coin instead of asking
  the node to select one, and carries a `ValidDuring` expiration for replay
  protection. Gas paid from the sender's address balance can now be estimated
  without owning a gas coin.
* gRPC conversion reads a tagged-union variant from its sole key when `$kind` is
  absent, which a JSON round-trip omits.

## 0.10.0

Synced to `f033be4`.

### Breaking

* `SuiCoreClient` gained `resolveNameServiceAddress`, `getProtocolConfig`,
  `listTransactions`, and `listEvents`; implementations of the interface must add
  all four.
* `simulateTransaction` no longer requests gas selection by default. It is
  requested only when the transaction's gas payment is an explicitly empty list,
  which means gas is paid from the sender's address balance; a transaction with
  no gas payment is simulated against a mocked gas coin. Pass
  `doGasSelection: true` for the previous behavior.
* `getTransaction` throws `TransactionError` when the digest is unknown. GraphQL
  threw a bare `Exception`; gRPC returned an empty response.

### Fixed

* `coinWithBalance` / `createBalance`: the `coin::destroy_zero` cleanup for an
  exact-balance match is spliced in with the intent's own commands instead of
  appended to the block. Appended cleanup can land after a Move call that
  consumes `Random`, which the chain rejects.
* BCS `TransactionKind` decodes system transactions. `ChangeEpoch`, `Genesis`,
  and `ConsensusCommitPrologue` were unparseable placeholders and now have typed
  payloads; `AuthenticatorStateUpdate`, `EndOfEpochTransaction`,
  `RandomnessStateUpdate`, `ConsensusCommitPrologueV2`–`V4`, and
  `ProgrammableSystemTransaction` were missing entirely.
* A transaction that pays gas from the sender's address balance is built with a
  `ValidDuring` expiration covering the current and next epoch. With no gas coin
  version to bound it and no expiration set, such a transaction could be
  replayed.

### Added

* `listTransactions` and `listEvents` read the indexed ledger on both transports,
  with sender/function and sender/module/type filters, cursor paging in either
  direction, and optional checkpoint bounds. `Page` gained `startCursor` for
  reading back, and `Event` gained `checkpoint`, `transactionDigest`, and
  `eventIndex`.
* `resolveNameServiceAddress` resolves a SuiNS name to an address (`null` when
  the name is unregistered or expired), on both transports.
* `getProtocolConfig` returns `protocolVersion`, `featureFlags`, and
  `attributes`, on both transports.
* `SuiGraphQLClient` forwards the whole Core API as top-level methods, matching
  `SuiGrpcClient`. `executeTransaction` and `verifyZkLoginSignature` still throw
  `UnsupportedError` there.
* `FaucetRateLimitError` is exported from `package:sui_dart/sui.dart`, so the
  throw `requestSuiFromFaucetV2` documents can be caught by type.
* README sections for the ledger queries, name-service resolution, and protocol
  config, and the transport table covers them.
* `ObjectError` carries a transport-neutral `reason`, the requested `objectId`,
  the transport's `code`, and the underlying `cause`. Missing objects report
  `reason: ObjectErrorReason.notFound` and `code: 'notExists'` on both
  transports.

### Changed

* The faucet tests run offline against a stubbed HTTP adapter. They used to call
  the live devnet faucet's retired `/gas` and `/v1/gas` endpoints, so they failed
  on every run.

### gRPC

* Regenerated `lib/grpc/generated/` from the current protobuf definitions.
  `LedgerService` gained the streaming `ListTransactions`/`ListEvents`/
  `ListCheckpoints` RPCs with the `filter` and `query_options` messages;
  `SubscriptionService` gained `SubscribeTransactions`/`SubscribeEvents`; `Event`
  carries its checkpoint, transaction digest, and index; `CommandArgumentError`
  gained `INVALID_TX_CONTEXT`. `listCheckpoints` has no core-client wrapper yet.

## 0.9.1

### Fixed

* `Transaction.toJson()` encoded the raw block snapshot and threw
  "Converting object to an encodable object failed: Instance of
  'TransactionData'".
* Blocks whose commands reference an earlier command's result now serialize to
  JSON. `TransactionResult` was not encodable, so both `toJson` and
  `toJsonAsync` failed on nearly every real transaction.
* `Transaction.object()` no longer resolves an argument onto an existing pure
  input. A value with no object id matched the first pure input, handing back a
  pure argument where an object was wanted and failing on chain with
  `CommandArgumentError { kind: InvalidUsageOfPureArg }`.

## 0.9.0

This release is breaking throughout: the JSON-RPC surface is gone and the
transport layer is unified behind `SuiCoreClient`.

### Added

* `SuiCoreClient`, a transport-agnostic contract for reads, simulate, and
  execute, with `GrpcCoreClient` and `GraphQLCoreClient` implementations
  reachable via `client.core` on `SuiGrpcClient` and `SuiGraphQLClient`.
* README "Choosing a Transport" comparison table.

### Changed

* `SuiGrpcClient` read methods renamed to match `SuiCoreClient`:
  `listCoins`/`listOwnedObjects`/`listBalances`/`listDynamicFields` are now
  `getCoins`/`getOwnedObjects`/`getAllBalances`/`getDynamicFields`.
* `BuildOptions`/`SerializeTransactionOptions`/`SignOptions` take
  `client: SuiCoreClient` (pass `client.core`) instead of `resolutionClient`.
  GraphQL building is read-only: move-call arguments aren't resolved.
* Renamed `grpc/client.dart` to `grpc/sui_grpc_client.dart` and
  `grpc/core.dart` to `grpc/grpc_core_client.dart`.

### Removed

* JSON-RPC surface: `SuiClient`, `JsonRpcProvider`, `JsonRpcClient`,
  `WebsocketClient`, `RawSigner`, `SignerWithProvider`,
  `SerialTransactionExecutor`, `TxnDataSerializer`. Use `SuiGrpcClient` or
  `SuiGraphQLClient`.
* `TxResolutionClient` / `GrpcResolutionClient` and the deprecated `list*`
  aliases on `GrpcCoreClient`.
* Unused `MultiSig` / `PubkeyWeightPair` (`cryptography/multisig.dart`) and
  `SuiPure` (`bcs/sui_pure.dart`). Use `MultiSigPublicKey` and `schemaFromName`
  (`builder/pure.dart`).

## 0.0.1

* Initial version, created by Mofa Labs.

## 0.0.3

* SuiNS
* Websocket
* Secp256r1

* Programmable Transactions Block

## 0.0.4

* Add requestSuiFromFaucetV1
* Fix TransactionBlock decode json data

## 0.1.0

* Refactor JsonRpcProvider
* Add more rpc methods
* Update readme

## 0.1.1

* Add Events API

## 0.1.2

* Add Web Support

## 0.1.3

* Fix query gas object
* Fix setSigner
* Add Web Demo

## 0.1.4

* Fix TransactionBlock
* Rename ED25519 to Ed25519

## 0.1.5

* Fix TransactionBlock Input Type, Estimate Gas

## 0.1.6

* Add zkLogin

## 0.1.7

* Fix hex pad

## 0.2.0

* Add MultiSig
* Add zkLogin Test

## 0.2.1

* export bech32 private key

## 0.3.0

* Refactor Transaction & BCS

## 0.3.1

* Fix dio use default transformer

## 0.3.2

* Fix bugs

## 0.3.3

* Fix example
* Clean code

## 0.3.4

* Perf: resolve move modules
* Bump BCS

## 0.3.5

* Fix map equality in transaction arguments

## 0.3.6

* Fix parse subIndex failed

## 0.3.7

* Config request options

## 0.3.8

* Refactor: major
* Fix: Update GetDynamicFieldObjects param
* Fix: Remove Flutter dependency

## 0.3.9

* Feat: Handle devInspect both Transaction and build result

## 0.3.10

* Fix: Only set sender if transaction input is valid

## 0.4.0

* Feat: gRPC client integration (`SuiGrpcClient` + `GrpcCoreClient`, transaction resolver, type converters, generated proto bindings)
* Feat: Add `deriveDynamicFieldId` helper for one-shot dynamic-field UID lookup
* Feat: Add `toSuiObject()` converter on `GrpcObjectData`
* Feat: Support `FundsWithdrawal` case in `callArgToGrpcInput`
* Feat: Protobuf value conversion functions for dynamic mapping in gRPC core
* Refactor: Align gRPC types with the canonical on-chain types
* Refactor: Replace untyped `Map<String, dynamic>` / `Map<String, bool>` with typed classes in gRPC core
* Refactor: Improved type safety in transaction handling across `GrpcCoreClient` and `SuiGrpcClient`
* Fix: Use `transaction.bcs` instead of `effects.bcs` in `GrpcCoreClient`
* Fix: Cast `typeArguments` to `String` for move calls in `commandToGrpcCommand`
* Fix: Handle non-string version types in `callArgToGrpcInput`
* Chore: Update Sui URLs to include port 443; upgrade SDK to 3.11.0
* Chore: Upgrade `pointycastle` to 4.0.0

## 0.4.1

* Chore: Swap `bip32` / `bip39` for `bip32_plus` / `bip39_plus` (pointycastle ^4 compatible). Removes the need for a `pointycastle` dependency override in consumers.

## 0.5.0

* Chore: Update package metadata (`homepage`, `repository`, `issue_tracker`).
* Feat: Add an `example/` demonstrating account creation, faucet funding, and balance lookup.
* Chore: Tighten dependency lower bounds and widen `web_socket_channel` to `^3.0.3`.
* Refactor: Move platform-specific HTTP adapters under `lib/src/` so the package reports correct platform support (Android, iOS, Windows, macOS, Linux).
* Style: Resolve all `dart analyze` warnings — add public-API type annotations, remove dead code, and escape doc comments.

## 0.5.1

* Fix: Relax `meta` constraint to `^1.18.0` (was `^1.18.3`). `^1.18.3` cannot resolve on current Flutter stable, which pins `meta 1.18.0`; the package only uses `@immutable`.

## 0.6.0

Synced to `f898c13`.

### Breaking

* `computeZkLoginAddressFromSeed` and `toZkLoginPublicIdentifier` take a `legacyAddress` named argument (defaults to `false`). Previously the two functions disagreed on seed encoding (unpadded vs padded), so the address derived from a seed did not match the address derived from the public identifier. Pass `legacyAddress: true` for the deprecated legacy derivation.
* `Ed25519Keypair.fromSecretKey` now validates the secret key by default (`skipValidation` defaults to `false`).
* BCS `ExecutionStatus` variant `Failed` renamed to `Failure`; effects field `congestedObjects` renamed to `congested_objects`; `UnchangedSharedKind` (variants `MutateDeleted`/`ReadDeleted`) renamed to `UnchangedConsensusKind` (`MutateConsensusStreamEnded`/`ReadConsensusStreamEnded`); effects field `unchangedSharedObjects` renamed to `unchangedConsensusObjects`.

### Fixes

* BCS: `Owner.ConsensusAddressOwner` field order corrected to `{startVersion, owner}` (the previous order produced wrong bytes).
* BCS: `TransactionEffects` is now an enum (`{V1, V2}`) instead of a struct; decoding effects as a struct read both versions back-to-back.
* BCS: added the newer `ExecutionFailureStatus` and `CommandArgumentError` variants, plus `ObjectOut.AccumulatorWriteV1` and the accumulator types, so current chain effects decode without out-of-range-tag errors.
* Transaction builder: `isUsedAsMutable` no longer marks nearly every shared-object input mutable (inverted `MergeCoins`/`SplitCoins` conditions); shared-object mutability now also honors an explicit `mutable` flag.
* Transaction builder: `splitCoins`, `mergeCoins`, `transferObjects`, and `makeMoveVec` now accept string object IDs and route object-position arguments through `object()`.
* Transaction builder: `Transaction.from` accepts base64 BCS bytes in addition to JSON; `getIdFromCallArg` normalizes unresolved object IDs.
* Type parsing: `parseStructTag` rejects malformed tags (empty components, trailing content); `parseTypeTag` handles `vector<...>` (including `vector<struct>`); `normalizeStructTag` rejects top-level vector strings.
* `isValidTransactionDigest` now validates Base58 (digests are Base58, not Base64).
* zkLogin: the Google issuer is normalized consistently across address and public-identifier derivation; `ZkLoginPublicIdentifier` gains legacy/non-legacy handling (`legacyAddress`, `fromBytes({address, legacyAddress})`, `fromProof`, `verifyAddress`).
* Crypto: secp256k1/secp256r1 verification rejects non-canonical (high-S) signatures; point recovery uses the correct per-curve field prime (was hardcoded to secp256k1).
* `ed25519_hd_key.getPublicKey(withZeroByte: true)` no longer crashes on the fixed-length buffer.

### Added

* `lib/cryptography/verify.dart`: `verifySignature`/`verifyPersonalMessageSignature`/`verifyTransactionSignature`, their non-throwing `isValid*` variants, and `publicKeyFromSuiBytes`.
* `lib/utils/format.dart`: `parseToUnits`, `parseToMist`, `formatAddress`, `formatDigest`.
* `lib/utils/move_registry.dart`: `isValidNamedPackage`, `isValidNamedType`.
* `common.dart`: `isValidStructTag`, `isValidTypeTag`, `isValidMoveIdentifier`.
* BCS: `CallArg.FundsWithdrawal` (with `Reservation`/`WithdrawalType`/`WithdrawFrom`), `TransactionExpiration.ValidDuring`, and the `Object`/`ObjectInner`/`MovePackage` schema.
* `FaucetClient.requestSuiFromFaucetV2` (`/v2/gas`) with `FaucetResponseV2`; `V0`/`V1`/status methods are deprecated.
* `PublicKey.verifyAddress`; `MultiSigPublicKey.getThreshold`/`getPublicKeys`; `Ed25519Keypair.deriveKeypairFromSeed`; `deriveObjectId`; constants `SUI_RANDOM_OBJECT_ID`, `SUI_COIN_REGISTRY_OBJECT_ID`, `SUI_DENY_LIST_OBJECT_ID`.

## 0.7.0

Synced to `f898c13`.

### Fixed

* `Transaction.serialize()` no longer throws `Converting object to an encodable object failed`. `serializeV1TransactionData` left the per-command argument/module lists as lazy `Iterable`s (`.map(...)` without `.toList()`), which `jsonEncode` cannot encode; they are now materialized.

### Added

* `Signer` base class (`lib/cryptography/signer.dart`) — a transport-agnostic signing interface with `signTransaction`/`signPersonalMessage` built on `signWithIntent`.
* `ZkLoginSigner` (`lib/zklogin/signer.dart`) — wraps an ephemeral `Keypair` and converts its signatures into zkLogin signatures using the proof `inputs` + `maxEpoch`. Optional `address` validates the derived address against the `legacyAddress` flag. Uses no Poseidon.
* `MultiSigSigner` (`lib/multisig/multisig_signer.dart`) — wraps a `MultiSigPublicKey` and its member keypairs; `signTransaction`/`signPersonalMessage` collect and combine the members' partial signatures. Validates membership, deduplication, and that the combined weight meets the threshold.
* `jwtDecode` (`lib/zklogin/jwt_decode.dart`) — decode a JWT's payload or header without signature verification (`InvalidTokenError` on malformed input).
* `getExtendedEphemeralPublicKey` (`lib/zklogin/utils.dart`) — the flag-prefixed base64 ephemeral public key the zkLogin proving service expects.

### gRPC

* Regenerated `lib/grpc/generated/` from the latest protobuf definitions. `AccumulatorWrite` now carries the authenticated-events shape (`value_kind` + `integer_value` / `integer_tuple` / `event_digest_value`, the `EventDigestEntry` message, and the `AccumulatorValue` enum); `object` and `transaction_execution_service` messages picked up their new fields.
* Added the `ForkingService` (`sui/forking/v1alpha`) client and exposed it as `SuiGrpcClient.forkingService` (admin-only; for `sui-fork` instances).

## 0.8.0

Synced to `f898c13`.

### Added

* Passkey (WebAuthn) signature verification: `PasskeyPublicKey` and `parseSerializedPasskeySignature` (`lib/cryptography/passkey_publickey.dart`), with `SignatureScheme.Passkey` (flag `0x06`) wired into `parseSerializedSignature`, `publicKeyFromRawBytes`, and `publicKeyFromSuiBytes`. Verification reconstructs the WebAuthn signing payload and checks the inner secp256r1 signature against the embedded key.
* Passkey signing (`lib/cryptography/passkey_keypair.dart`): `PasskeyKeypair` plus a `PasskeyProvider` interface the host app backs with a platform WebAuthn/credentials binding. Handles DER signature parsing, low-S normalization, deriving the secp256r1 key from the DER `SubjectPublicKeyInfo`, and assembling the serialized passkey signature; `signAndRecover`/`findCommonPublicKey` identify an existing passkey's key. Signing is async.
* `coinWithBalance` / `createBalance` intents (`lib/builder/intents/coin_with_balance.dart`): `tx.add(coinWithBalance({type, balance}))` yields a coin (or balance) of an exact amount, with the sender's coins selected, merged, and split at build time. Backed by a new async intent-resolution pipeline (`Transaction.addIntentResolver`) and `TransactionBlockDataBuilder.replaceCommand` (which remaps argument indices after splicing). SUI uses the gas coin unless `useGasCoin: false`. Requires a client and sender. The address-balance withdrawal path is not used; surplus remains an owned coin.
* `Transaction.toJsonAsync` / `prepareForSerialization` / `isPreparedForSerialization`: async JSON serialization that resolves intents first (without requiring gas/sender), with a `supportedIntents` option to leave intents for the recipient to resolve. The synchronous `toJson()` is unchanged.
* `SerialTransactionExecutor` (`lib/builder/executor/serial_transaction_executor.dart`): signs and executes transactions one at a time for a single account, reusing the gas coin from each transaction's effects so back-to-back transactions don't wait for indexing. Includes a `SerialQueue` utility. (Caches only the gas coin, not arbitrary owned-object versions; there is no parallel executor.)

## 0.8.1

### Added

* gRPC transaction building: `GrpcResolutionClient` + `BuildOptions.resolutionClient` build transactions over gRPC (coin selection, object/gas/move resolution, dry-run via `simulateTransaction`); `TxResolutionClient` abstracts the transport. Validated on mainnet.
* `SuiGrpcClient`: `buildTransaction` / `signAndExecuteTransaction` (end-to-end over gRPC) and `getDynamicFieldObject` (the `suix_getDynamicFieldObject` equivalent).
* gRPC `Event` exposes `json` alongside `bcs` (u64 fields lose precision in `json`; decode `bcs`).

### Fixed

* gRPC `simulateTransaction(commandResults: true)` / devInspect now return Move call return values — the read mask omitted `command_outputs`, so the server returned none.

### Deprecated

* JSON-RPC layer (`SuiClient`, `JsonRpcClient`, `JsonRpcProvider`, `SignerWithProvider`, `RawSigner`) in favor of `SuiGrpcClient`; JSON-RPC sunsets ~July 2026. Still functional; removed in a future major.

## 0.8.2

### Fixed

* gRPC `simulateTransaction(events: true)` / devInspect now return emitted events — the read mask requested `events` instead of `transaction.events` (events are nested under `transaction`), so the server returned none.

## 0.8.3

### Added

* `ObjectIncludeOptions.display` + `ObjectData.display`: gRPC object reads can fetch the rendered Sui Display (`name`, `image_url`, …) as a `Map`. Null when the type has no Display template.

## 0.8.4

### Fixed

* gRPC event reads: the events read mask used `transaction.events`, which the node rejects as an invalid path (`INVALID_ARGUMENT`), so `getTransaction` / `executeTransaction` / `simulateTransaction(events: true)` returned no events. Corrected to the top-level `events` field, verified against mainnet. Reverts the incorrect 0.8.2 change.
* gRPC dry-run: `dryRunTransaction` simulated without requesting `effects`, so auto gas-budget estimation had no `gasUsed` and a failed simulation reported success. It now requests `effects`.

## 0.8.5

### Changed

* Bump `bcs_dart` to `^0.2.1`.
* Rewrite the README transaction-building guide.

## 0.8.6

### Added

* `simulateTransaction` accepts `checksEnabled`. Pass `false` to run the transaction checks as DISABLED (maps to the gRPC `SimulateTransactionRequest.checks` field). When disabled, the node ignores `doGasSelection`, so an unfunded sender can simulate without gas.

## 0.8.7

### Fixed

* gRPC `simulateTransaction(events: true)` returned no events, so event-driven read queries came back empty. `SimulateTransactionResponse` nests the executed transaction under `transaction`, so simulate now builds its own `transaction.`-prefixed read mask (`_simulateReadMask`), naming the derived per-event JSON explicitly, while `getTransaction` / `executeTransaction` keep the top-level `events` mask. This resolves the 0.8.2/0.8.4 flip-flop, where one shared mask could not satisfy both response shapes: 0.8.2 switched it to `transaction.events` and broke get/execute; 0.8.4 reverted to `events` and re-broke simulate.

### Changed

* `simulateTransaction` disables transaction checks by default when `doGasSelection` is `false` — a read-only simulate has no gas to satisfy gas checks. Gas-selecting simulations keep the node default so real gas/validity errors still surface; pass `checksEnabled` to override.

## 0.8.8

### Added

* Add `SuiGraphQLClient` and `GraphQLTransport` with custom queries, structured
  errors, partial data, cancellation, and cursor pagination.
* Add generated typed operations for transaction and object history, gas
  summaries, events, epochs, validators, and stakes.
* Add a checked-in Sui GraphQL schema and schema-refresh tooling.
