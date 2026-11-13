import 'dart:async';

import 'package:sui_dart/grpc/types.dart';
import 'package:sui_dart/sui.dart';
import 'package:test/test.dart';

/// Found on call [foundOn] (never if null).
class _Node implements SuiCoreClient {
  _Node({this.foundOn, this.hang = false});

  final int? foundOn;
  final bool hang;
  final calls = <Duration>[];
  final _clock = Stopwatch()..start();

  @override
  Future<TransactionResponse> getTransaction(
    String digest, {
    TransactionIncludeOptions? include,
  }) async {
    calls.add(_clock.elapsed);
    if (hang) return Completer<TransactionResponse>().future;
    if (calls.length == foundOn) return TransactionResponse(digest: digest);
    throw StateError('not found');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('retries on the schedule until the transaction appears', () async {
    final node = _Node(foundOn: 3);
    final res = await node.waitForTransaction(
      'abc',
      pollSchedule: const [
        Duration.zero,
        Duration(milliseconds: 50),
        Duration(milliseconds: 100),
      ],
    );
    expect(res.digest, 'abc');
    expect(node.calls.length, 3);
    expect(node.calls[1].inMilliseconds, greaterThanOrEqualTo(45));
    expect(node.calls[2].inMilliseconds, greaterThanOrEqualTo(95));
  });

  test('keeps polling at the last gap after the schedule ends', () async {
    final node = _Node(foundOn: 5);
    await node.waitForTransaction(
      'abc',
      pollSchedule: const [Duration.zero, Duration(milliseconds: 30)],
    );
    expect(node.calls.length, 5);
    expect(
      (node.calls[4] - node.calls[3]).inMilliseconds,
      greaterThanOrEqualTo(25),
    );
  });

  test('throws TimeoutException when it never shows up', () async {
    final node = _Node();
    await expectLater(
      node.waitForTransaction(
        'abc',
        timeout: const Duration(milliseconds: 200),
        pollSchedule: const [Duration.zero, Duration(milliseconds: 50)],
      ),
      throwsA(isA<TimeoutException>()),
    );
    expect(node.calls.length, greaterThan(2));
  });

  test(
    'waits out the full timeout when the next poll would be too late',
    () async {
      final clock = Stopwatch()..start();
      final node = _Node();
      await expectLater(
        node.waitForTransaction(
          'abc',
          timeout: const Duration(milliseconds: 300),
          pollSchedule: const [Duration.zero, Duration(seconds: 5)],
        ),
        throwsA(isA<TimeoutException>()),
      );
      expect(node.calls.length, 1);
      expect(clock.elapsedMilliseconds, greaterThanOrEqualTo(280));
    },
  );

  test('a hung request does not outlive the timeout', () async {
    final clock = Stopwatch()..start();
    await expectLater(
      _Node(
        hang: true,
      ).waitForTransaction('abc', timeout: const Duration(milliseconds: 150)),
      throwsA(isA<TimeoutException>()),
    );
    expect(clock.elapsedMilliseconds, lessThan(1000));
  });
}
