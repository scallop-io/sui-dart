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
* Refactor: Align gRPC types with TypeScript SDK canonical types
* Refactor: Replace untyped `Map<String, dynamic>` / `Map<String, bool>` with typed classes in gRPC core
* Refactor: Improved type safety in transaction handling across `GrpcCoreClient` and `SuiGrpcClient`
* Fix: Use `transaction.bcs` instead of `effects.bcs` in `GrpcCoreClient`
* Fix: Cast `typeArguments` to `String` for move calls in `commandToGrpcCommand`
* Fix: Handle non-string version types in `callArgToGrpcInput`
* Chore: Update Sui URLs to include port 443; upgrade SDK to 3.11.0
* Chore: Upgrade `pointycastle` to 4.0.0
