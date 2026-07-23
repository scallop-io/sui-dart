# Sui Dart SDK

[![Pub](https://img.shields.io/pub/v/sui_dart.svg)](https://pub.dev/packages/sui_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A cross-platform Dart SDK for the [Sui](https://sui.io) blockchain. Pure
Dart with no Flutter dependency, so it runs on mobile, web, desktop, and
server alike.

**Features**

- Native gRPC and GraphQL transports behind a single `SuiCoreClient` contract
- Transaction building (programmable transaction blocks), signing, and execution
- Ed25519, Secp256k1, Secp256r1, and Passkey (SIP-9) accounts
- Multisig and zkLogin support
- Faucet and Sui Name Service helpers

## Installation

```shell
dart pub add sui_dart
```

Or add it to `pubspec.yaml` directly:

```yaml
dependencies:
  sui_dart: ^0.8.8
```

## Demo

https://sui-dart.pages.dev/

## Usage

### Choosing a Transport

Two transports, both implementing the same `SuiCoreClient` contract:

| Capability | `SuiGrpcClient` | `SuiGraphQLClient` |
|---|---|---|
| Reads (objects, coins, balances, dynamic fields, move functions) | ✅ | ✅ |
| Pagination | ✅ | ✅ |
| Simulate / dry-run | ✅ | ✅ |
| Execute (sign & submit) | ✅ | ❌ (not implemented) |
| zkLogin signature verification | ✅ | ❌ (not implemented) |
| Name service lookup | ✅ | ✅ |

Use gRPC by default, and for anything that signs or executes. Use GraphQL when
the deployment target is a GraphQL indexer, or the workload is read-only.

```dart
import 'package:sui_dart/grpc/sui_grpc_client.dart';

final client = SuiGrpcClient(SuiGrpcClientOptions(
    baseUrl: 'fullnode.mainnet.sui.io',
    port: 443,
));
final balance = await client.getBalance('0xa2d8bb82df40770ac5bc8628d8070b041a13386fef17db27b32f3b0f316ae5a2');
```

```dart
import 'package:sui_dart/sui.dart';

final client = SuiGraphQLClient.forNetwork(SuiNetwork.mainnet);
final balance = await client.core.getBalance('0xa2d8bb82df40770ac5bc8628d8070b041a13386fef17db27b32f3b0f316ae5a2');
```

### Getting coins from the faucet

```dart
final faucet = FaucetClient(SuiUrls.faucetDev);
await faucet.requestSuiFromFaucetV2('0xa2d8bb82df40770ac5bc8628d8070b041a13386fef17db27b32f3b0f316ae5a2');
```

`requestSuiFromFaucetV0`/`V1` and `getFaucetRequestStatus` still exist but are
deprecated; use V2.

### Sui Account

#### Create account with private key

```dart
/// Ed25519 account
final ed25519 = SuiAccount.ed25519Account();
final ed25519Import = SuiAccount.fromPrivateKey(ed25519.privateKey());

/// Secp256k1 account
final secp256k1 = SuiAccount.secp256k1Account();
final sepc256k1Import = SuiAccount.fromPrivateKey(secp256k1.privateKey());

/// Secp256r1 account
final secp256r1 = SuiAccount.secp256r1Account();
final sepc256r1Import = SuiAccount.fromPrivateKey(secp256r1.privateKey());
```

#### Create account with mnemonic

```dart
/// create mnemonics
final mnemonics = SuiAccount.generateMnemonic();

/// Ed25519 account
final ed25519 = SuiAccount.fromMnemonics(mnemonics, SignatureScheme.Ed25519);

/// Secp256k1 account
final secp256k1 = SuiAccount.fromMnemonics(mnemonics, SignatureScheme.Secp256k1);

/// Secp256r1 account
final secp256r1 = SuiAccount.fromMnemonics(mnemonics, SignatureScheme.Secp256r1);
```

### Building Transactions

Transactions are programmable transaction blocks (PTBs): a sequence of commands
that run atomically. Build one with the `Transaction` class.

```dart
final tx = Transaction();
```

#### Inputs

Add objects and pure (BCS-encoded) values as inputs:

```dart
// Object inputs, by id
tx.object('0x2619f581cb1864d07c89453a69611202669fdc4784fb59b9cb4278ec60756011');

// Pure values (u64/u128/u256 take a BigInt)
tx.pure.u64(BigInt.from(1000));
tx.pure.address('0xa2d8bb82df40770ac5bc8628d8070b041a13386fef17db27b32f3b0f316ae5a2');
tx.pure.string('hello');
tx.pure.boolean(true);
tx.pure.vector('u64', [1, 2, 3]);
tx.pure.option('u64', BigInt.from(5));
```

#### Commands

Split coins off the gas coin and transfer them:

```dart
final tx = Transaction();
final coin = tx.splitCoins(tx.gas, [1000]);
tx.transferObjects([coin], recipient);
```

Transfer objects:

```dart
tx.transferObjects(
    [tx.object('0x2619f581cb1864d07c89453a69611202669fdc4784fb59b9cb4278ec60756011')],
    recipient,
);
```

Merge coins:

```dart
tx.mergeCoins('0x922ec73939b3288f6da39ebefb0cb88c6c54817441254d448bd2491ac4dd0cbd', [
    '0x8dafc96dec7f8d635e052a6da9a4153e37bc4d59ed44c45006e4e9d17d07f80d',
]);
```

Call a Move function. The `target` is `packageId::module::function`; pass generic
type parameters with `typeArguments`:

```dart
tx.moveCall(
    '0x...::nft::mint',
    arguments: [tx.pure.string('Example NFT')],
);

final newCoin = tx.moveCall(
    '0x2::coin::split',
    typeArguments: ['0x2::sui::SUI'],
    arguments: [tx.object('0xCoinId'), tx.pure.u64(BigInt.from(1000))],
);
```

Build a `vector` of objects, publish, or upgrade a package:

```dart
tx.makeMoveVec(objects: [tx.object('0x1'), tx.object('0x2')]);

final upgradeCap = tx.publish(modules, dependencies);
tx.transferObjects([upgradeCap], recipient);

tx.upgrade(
    modules: modules,
    dependencies: dependencies,
    packageId: '0x...',
    ticket: upgradeTicket,
);
```

#### Using results

Every command returns a `TransactionResult` you can chain into later commands.
Index into it for a specific output:

```dart
final coins = tx.splitCoins(tx.gas, [1000, 2000]);
tx.transferObjects([coins[0]], alice);
tx.transferObjects([coins[1]], bob);
```

A single return value can be passed straight through:

```dart
final nft = tx.moveCall('0x...::nft::mint', arguments: [tx.pure.string('My NFT')]);
tx.transferObjects([nft], recipient);
```

#### coinWithBalance

`coinWithBalance` selects and merges the sender's coins at build time to produce
a coin of an exact amount (using the gas coin for SUI). Add it with `tx.add`:

```dart
final tx = Transaction();

// 1 SUI
final coin = tx.add(coinWithBalance(balance: 1000000000));
tx.transferObjects([coin], recipient);

// A custom coin type
final usdc = tx.add(coinWithBalance(
    type: '0x...::usdc::USDC',
    balance: 1000000,
));
```

Use `createBalance(...)` for a `Balance<T>` instead of a `Coin<T>`. Both require a
sender and a client at build time.

#### Gas and sender

The client sets the sender, gas price, budget, and payment automatically. Override
any of them when needed:

```dart
tx.setSender(account.getAddress());
tx.setGasBudget(BigInt.from(50000000));
tx.setGasPrice(BigInt.from(1000));
```

### Signing and Executing

Execute transactions over gRPC with `SuiGrpcClient`. The gRPC client and its
transaction helpers are separate imports:

```dart
import 'package:sui_dart/sui.dart';
import 'package:sui_dart/grpc/sui_grpc_client.dart';
import 'package:sui_dart/grpc/grpc_resolution_client.dart';

final client = SuiGrpcClient(SuiGrpcClientOptions(
    baseUrl: 'fullnode.mainnet.sui.io',
    port: 443,
));
```

Build, sign, and execute in one call. Inputs (coins, objects, gas) resolve over
gRPC, and the sender defaults to the account's address:

```dart
final account = SuiAccount.fromMnemonics(mnemonics, SignatureScheme.Ed25519);

final tx = Transaction();
final coin = tx.splitCoins(tx.gas, [1000]);
tx.transferObjects([coin], account.getAddress());

final result = await client.signAndExecuteTransaction(
    account,
    tx,
    include: const TransactionIncludeOptions(effects: true),
);
print(result.digest);
```

Simulate (dry-run) a transaction without executing it:

```dart
tx.setSender(account.getAddress());
final sim = await client.simulateTransaction(
    tx,
    include: const TransactionIncludeOptions(effects: true, events: true),
);
```

### GraphQL Queries

Use `SuiGraphQLClient` for indexer-backed queries such as transaction history,
events, validators, and stakes:

```dart
import 'package:sui_dart/sui.dart';

final graphql = SuiGraphQLClient.forNetwork(SuiNetwork.mainnet);

final history = await graphql.queryTransactionsByAddress(address, first: 20);
final gas = history.transactions.isEmpty
    ? null
    : await graphql.getTransactionGasSummary(history.transactions.first.digest);
final eventPage = await graphql.queryEventsByModule('0x2', 'coin');
final validators = await graphql.getActiveValidators();
final stakePage = await graphql.getStakes(address);

// Continue connections without losing the cursor.
if (eventPage.hasNextPage) {
  await graphql.queryEventsByModule(
    '0x2',
    'coin',
    after: eventPage.endCursor,
  );
}
```

Use `SuiGraphQLClient(endpoint: ..., headers: ...)` for a hosted or self-hosted
GraphQL endpoint.

Custom queries preserve partial data, structured errors, and extensions:

```dart
final response = await graphql.query('{ chainIdentifier }');
if (response.hasErrors) {
  print(response.errors.first.message);
}
```

The built-in helpers use generated variables and response models. When adding
another SDK operation, declare it in `lib/graphql/operations.graphql` and run:

```shell
dart run build_runner build
```

Application-specific operations can use the same pattern after configuring
`graphql_codegen` against the checked-in schema. Wrap the generated document
and serializers once, then execute it through the same transport:

```dart
final getObject = GraphQLOperation<Query$GetObject, Variables$Query$GetObject>(
  document: documentNodeQueryGetObject,
  operationName: 'GetObject',
  decodeData: Query$GetObject.fromJson,
  encodeVariables: (variables) => variables.toJson(),
);

final result = await graphql.execute(
  getObject,
  Variables$Query$GetObject(address: objectId),
);
final object = result.data?.object;
```

The checked-in schema matches Mysten's TypeScript SDK snapshot. Refresh and
regenerate it after a Sui GraphQL schema release:

```shell
dart run tool/update_graphql_schema.dart
dart run build_runner build
```

The live schema test is opt-in:

```shell
SUI_DART_LIVE_TESTS=true dart test test/graphql/graphql_live_test.dart
```

Sign and execute manually (for multisig, sponsored, or delayed execution):

```dart
tx.setSender(account.getAddress());
final bytes = await client.buildTransaction(tx);
final signed = account.keyPair.signTransactionBlock(bytes);

final result = await client.executeTransaction(
    bytes,
    [signed.signature],
    include: const TransactionIncludeOptions(effects: true),
);
```

#### Serializing

Pass an in-progress transaction between processes as JSON, then rebuild it:

```dart
// Async: resolves intents like coinWithBalance first
final json = await tx.toJsonAsync(
    SerializeTransactionOptions(client: client.core),
);

// Sync: for a transaction with no unresolved intents
final json = tx.toJson();

final restored = Transaction.from(json);
```

### Reading APIs

These use the `SuiGrpcClient` from [Choosing a Transport](#choosing-a-transport);
`GraphQLCoreClient` covers most of the same reads through `client.core`.

#### Get Owned Objects

```dart
final objects = await client.getOwnedObjects('0xa2d8bb82df40770ac5bc8628d8070b041a13386fef17db27b32f3b0f316ae5a2');
```

#### Get Objects

```dart
final objs = await client.getObjects([
    '0x0d49dbda185cd0941b71315edb594276731f21b2232d8713f319b02c462a2da7',
    '0x922ec73939b3288f6da39ebefb0cb88c6c54817441254d448bd2491ac4dd0cbd',
], include: const ObjectIncludeOptions(json: true));
```

#### Get Transaction

```dart
final txn = await client.getTransaction('6oH779AUs2WpwW77xCVGbYqK1FYVamRqHjV6A5wCV8Qj',
    include: const TransactionIncludeOptions(effects: true)
);
```

#### Get Coins

```dart
final coins = await client.getCoins(
    '0xa2d8bb82df40770ac5bc8628d8070b041a13386fef17db27b32f3b0f316ae5a2',
    coinType: '0x2::sui::SUI');

final allBalances = await client.getAllBalances('0xa2d8bb82df40770ac5bc8628d8070b041a13386fef17db27b32f3b0f316ae5a2');

final suiBalance = await client.getBalance('0xa2d8bb82df40770ac5bc8628d8070b041a13386fef17db27b32f3b0f316ae5a2');
```

### Events

Standalone event queries (`queryEventsByModule`) are a GraphQL capability; see
[GraphQL Queries](#graphql-queries). Neither transport's client wrapper exposes
checkpoint reads or live event subscriptions today (the raw gRPC subscription
service exists in `lib/grpc/generated/`, but isn't wrapped by `SuiGrpcClient`).

## License

[MIT](LICENSE)
