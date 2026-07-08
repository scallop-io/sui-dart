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
