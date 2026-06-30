import 'package:sui_dart/sui.dart';
import 'package:test/test.dart';

void main() {
  group('SerialQueue', () {
    test('runs tasks serially in submission order', () async {
      final queue = SerialQueue();
      final events = <String>[];

      Future<int> task(String id, int delayMs) => queue.run(() async {
        events.add('start:$id');
        await Future.delayed(Duration(milliseconds: delayMs));
        events.add('end:$id');
        return delayMs;
      });

      // First task is slowest: if they overlapped, ordering would interleave.
      final futures = [task('a', 30), task('b', 10), task('c', 0)];
      final results = await Future.wait(futures);

      expect(results, [30, 10, 0]);
      expect(events, [
        'start:a', 'end:a', //
        'start:b', 'end:b',
        'start:c', 'end:c',
      ]);
    });

    test('a failing task does not break the chain', () async {
      final queue = SerialQueue();

      final failing = queue.run<int>(() async => throw StateError('boom'));
      final ok = queue.run<int>(() async => 42);

      await expectLater(failing, throwsA(isA<StateError>()));
      expect(await ok, 42);
    });
  });

  group('gasCoinFromEffects', () {
    SuiTransactionBlockResponse responseWith(dynamic effects) {
      return SuiTransactionBlockResponse.fromJson({
        'digest': 'Bfm2Z4dXysM9Vu1X5p8oR4z7mFs2pT8w9X1y2Z3a4B5c',
        'effects': effects,
      });
    }

    test('extracts the mutated gas coin reference', () {
      final response = responseWith({
        'status': {'status': 'success'},
        'gasUsed': {
          'computationCost': '1000',
          'storageCost': '0',
          'storageRebate': '0',
          'nonRefundableStorageFee': '0',
        },
        'transactionDigest': 'Bfm2Z4dXysM9Vu1X5p8oR4z7mFs2pT8w9X1y2Z3a4B5c',
        'gasObject': {
          'owner': {
            'AddressOwner':
                '0x00000000000000000000000000000000000000000000000000000000000000ab',
          },
          'reference': {
            'objectId':
                '0x00000000000000000000000000000000000000000000000000000000000000aa',
            'version': '7',
            'digest': 'GasDigest1111111111111111111111111111111111',
          },
        },
      });

      final ref = gasCoinFromEffects(response);
      expect(ref, isNotNull);
      expect(ref!.version, 7);
      expect(ref.digest, 'GasDigest1111111111111111111111111111111111');
    });

    test('returns null when effects are absent', () {
      expect(gasCoinFromEffects(responseWith(null)), isNull);
    });
  });
}
