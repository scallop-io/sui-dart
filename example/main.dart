import 'package:sui_dart/grpc/sui_grpc_client.dart';
import 'package:sui_dart/sui.dart';

/// A minimal end-to-end example for sui_dart: create an account, request test
/// SUI from the faucet, and read the balance through both transports.
Future<void> main() async {
  // 1. Create an Ed25519 account from a freshly generated mnemonic.
  final mnemonic = SuiAccount.generateMnemonic();
  final account = SuiAccount.fromMnemonics(mnemonic, SignatureScheme.Ed25519);
  final address = account.getAddress();
  print('Address: $address');

  // 2. Request test SUI from the devnet faucet.
  final faucet = FaucetClient(SuiUrls.faucetDev);
  await faucet.requestSuiFromFaucetV2(address);

  // 3a. Read the balance via gRPC, the default choice and the only
  // transport that can also sign/execute transactions.
  final devnetUri = Uri.parse(SuiUrls.devnet);
  final grpcClient = SuiGrpcClient(
    SuiGrpcClientOptions(baseUrl: devnetUri.host, port: devnetUri.port),
  );
  final grpcBalance = await grpcClient.core.getBalance(address);
  print(
    'Balance (gRPC): ${grpcBalance.balance} MIST (${grpcBalance.coinType})',
  );

  // 3b. The same read via GraphQL, reads-only; use gRPC for writes.
  final graphqlClient = SuiGraphQLClient.forNetwork(SuiNetwork.devnet);
  final graphqlBalance = await graphqlClient.core.getBalance(address);
  print(
    'Balance (GraphQL): ${graphqlBalance.balance} MIST (${graphqlBalance.coinType})',
  );
}
