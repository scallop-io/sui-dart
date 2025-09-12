import 'package:test/test.dart';
import 'package:sui_dart/types/common.dart';
import 'package:sui_dart/types/framework.dart';
import 'package:sui_dart/types/sui_bcs.dart';

import 'utils/setup.dart';

void main() {
  late TestToolbox toolbox;

  setUpAll(() async {
    toolbox = await setup();
    await Future.delayed(const Duration(seconds: 2));
  });

  group('Coin related API', () {
    test('test Coin utility functions', () async {
      final coins = await toolbox.getGasObjectsOwnedByAddress();
      coins.forEach((c) {
        expect(Coin.isCoin(c), true);
        expect(Coin.isSUI(c), true);
      });
    });

    test('test getCoinStructTag', () async {
      final exampleStructTag = StructTag(normalizeSuiObjectId('0x2'), 'sui', 'SUI', []);
      final coins = await toolbox.getGasObjectsOwnedByAddress();
      final coinTypeArg = Coin.getCoinTypeArg(coins[0])!;
      final coinStructTag = Coin.getCoinStructTag(coinTypeArg);
      expect(coinStructTag.address, exampleStructTag.address);
      expect(coinStructTag.module, exampleStructTag.module);
      expect(coinStructTag.name, exampleStructTag.name);
      expect(coinStructTag.typeParams, exampleStructTag.typeParams);
    });
  });
}
