import 'package:meta/meta.dart';

enum SuiNetwork { mainnet, testnet, devnet, localnet }

@immutable
final class SuiUrls {
  const SuiUrls._();

  static const String mainnet = "https://fullnode.mainnet.sui.io:443";
  static const String testnet = "https://fullnode.testnet.sui.io:443";
  static const String devnet = "https://fullnode.devnet.sui.io:443";

  static const String faucetDev = "https://faucet.devnet.sui.io:443";
  static const String faucetTest = "https://faucet.testnet.sui.io:443";

  static const String webSocketMainnet = 'wss://fullnode.mainnet.sui.io';

  static const String graphqlMainnet = 'https://graphql.mainnet.sui.io/graphql';
  static const String graphqlTestnet = 'https://graphql.testnet.sui.io/graphql';
  static const String graphqlDevnet = 'https://graphql.devnet.sui.io/graphql';
  static const String graphqlLocalnet = 'http://127.0.0.1:9125/graphql';

  static String graphql(SuiNetwork network) => switch (network) {
    SuiNetwork.mainnet => graphqlMainnet,
    SuiNetwork.testnet => graphqlTestnet,
    SuiNetwork.devnet => graphqlDevnet,
    SuiNetwork.localnet => graphqlLocalnet,
  };
}
