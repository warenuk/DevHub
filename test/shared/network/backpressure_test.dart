import 'package:devhub_gpt/shared/network/queue/sync_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncQueue backpressure', () {
    test('enforces per-key min delay with jitter', () async {
      final q = SyncQueue(
        maxConcurrentGlobal: 4,
        concurrencyPerKey: 1,
        minDelayPerKey: const Duration(milliseconds: 200),
        maxJitter: const Duration(milliseconds: 1),
      );
      final stamps = <DateTime>[];
      Future<void> work(String k) async {
        stamps.add(DateTime.now());
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      // three tasks for one key must be spaced by >=200ms
      await Future.wait([
        q.enqueue(queueKey: 'repos', priority: 1, run: () async => work('repos')),
        q.enqueue(queueKey: 'repos', priority: 1, run: () async => work('repos')),
        q.enqueue(queueKey: 'repos', priority: 1, run: () async => work('repos')),
      ]);
      expect(stamps.length, 3);
      final d1 = stamps[1].difference(stamps[0]).inMilliseconds;
      final d2 = stamps[2].difference(stamps[1]).inMilliseconds;
      expect(d1 >= 190, isTrue, reason: 'd1=$d1 ms');
      expect(d2 >= 190, isTrue, reason: 'd2=$d2 ms');
    });

    test('respects priority ordering', () async {
      final q = SyncQueue(
        maxConcurrentGlobal: 1,
        concurrencyPerKey: 1,
        minDelayPerKey: const Duration(milliseconds: 0),
        maxJitter: const Duration(milliseconds: 0),
      );
      final order = <int>[];
      await Future.wait([
        q.enqueue(queueKey: 'k', priority: 1, run: () async { order.add(1); return 1; }),
        q.enqueue(queueKey: 'k', priority: 5, run: () async { order.add(5); return 5; }),
        q.enqueue(queueKey: 'k', priority: 3, run: () async { order.add(3); return 3; }),
      ]);
      expect(order, [5, 3, 1]);
    });
  });
}
