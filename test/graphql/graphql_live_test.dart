import 'dart:io';

import 'package:sui_dart/sui.dart';
import 'package:test/test.dart';

final _runLive = Platform.environment['SUI_DART_LIVE_TESTS'] == 'true';

void main() {
  test(
    'public mainnet schema matches every GraphQL helper',
    () async {
      final client = SuiGraphQLClient.forNetwork(SuiNetwork.mainnet);

      expect(await client.getChainIdentifier(), isNotEmpty);
      expect((await client.getEpochSummary()).epochId, greaterThan(0));
      expect(
        (await client.getActiveValidatorsPage(first: 1)).validators,
        isNotEmpty,
      );
      final objectTransactions = await client.queryTransactionsByObject(
        '0x2',
        first: 1,
      );
      expect(objectTransactions.digests, isNotEmpty);

      await client.queryTransactionsByAddress(
        '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        first: 1,
        options: const TransactionHistoryOptions(showObjectChanges: true),
      );
      await client.queryTransactionsBySender('0x2', first: 1);
      await client.getTransactionGasSummary(objectTransactions.digests.first);
      await client.getStakes('0x2', first: 1);
      await client.queryEventsByModule('0x2', 'coin', first: 1);
    },
    skip: _runLive
        ? false
        : 'Set SUI_DART_LIVE_TESTS=true to query public mainnet.',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
