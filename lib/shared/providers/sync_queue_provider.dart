import 'package:devhub_gpt/shared/network/queue/sync_queue.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(
    maxConcurrentGlobal: 8,
    concurrencyPerKey: 1,
    minDelayPerKey: const Duration(milliseconds: 350),
    maxJitter: const Duration(milliseconds: 120),
  );
});
