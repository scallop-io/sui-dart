import 'package:meta/meta.dart';

@immutable
final class SuiUrls {
  const SuiUrls._();

  static const String mainnet = "https://fullnode.mainnet.sui.io:443";
  static const String testnet = "https://fullnode.testnet.sui.io:443";
  static const String devnet = "https://fullnode.devnet.sui.io:443";

  static const String faucetDev = "https://faucet.devnet.sui.io:443";
  static const String faucetTest = "https://faucet.testnet.sui.io:443";

  static const String webSocketMainnet = 'wss://fullnode.mainnet.sui.io';
  static const String webSocketTestnet = 'wss://fullnode.testnet.sui.io';
  static const String webSocketDevnet = 'wss://fullnode.devnet.sui.io';
}
