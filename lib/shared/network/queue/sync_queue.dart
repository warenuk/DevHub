import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';

/// Прості черги з пріоритетами та backpressure (мінімальні затримки + джиттер)
/// для мережевих запитів.
///
/// Дизайн ключів:
///  - queueKey: логічна сутність/ендпоінт (наприклад, 'repos', 'commits', 'activity', 'notes').
///  - per-key послідовність: не більше [concurrencyPerKey] одночасних завдань для одного ключа.
///  - глобальний ліміт одночасності: [maxConcurrentGlobal].
///
/// Планувальник витягує найвищий пріоритет, який не порушує обмежень.
class SyncQueue {
  SyncQueue({
    this.maxConcurrentGlobal = 8,
    this.concurrencyPerKey = 1,
    this.minDelayPerKey = const Duration(milliseconds: 300),
    this.maxJitter = const Duration(milliseconds: 120),
  });

  final int maxConcurrentGlobal;
  final int concurrencyPerKey;
  final Duration minDelayPerKey;
  final Duration maxJitter;

  final PriorityQueue<_QueuedTask> _pending = PriorityQueue<_QueuedTask>(_taskComparator);
  final _activeByKey = <String, int>{};
  final _lastEmissionByKey = <String, DateTime>{};
  int _activeGlobal = 0;
  bool _tickScheduled = false;

  static int _taskComparator(_QueuedTask a, _QueuedTask b) {
    final byP = b.priority.compareTo(a.priority); // більший пріоритет вище
    if (byP != 0) return byP;
    return a.enqueuedAt.compareTo(b.enqueuedAt); // FIFO в межах пріоритету
  }

  Future<T> enqueue<T>({
    required String queueKey,
    required int priority,
    required Future<T> Function() run,
  }) {
    final c = Completer<T>();
    _pending.add(_QueuedTask(
      queueKey: queueKey,
      priority: priority,
      enqueuedAt: DateTime.now(),
      run: () => run(),
      complete: (value) => c.complete(value as T),
      completeError: (e, s) => c.completeError(e, s),
    ),);
    _scheduleTick();
    return c.future;
  }

  void _scheduleTick() {
    if (_tickScheduled) return;
    _tickScheduled = true;
    scheduleMicrotask(() async {
      _tickScheduled = false;
      await _drain();
    },);
  }

  Future<void> _drain() async {
    while (_activeGlobal < maxConcurrentGlobal && _pending.isNotEmpty) {
      final task = _pickNextEligible();
      if (task == null) break;
      _start(task);
    }
  }

  _QueuedTask? _pickNextEligible() {
    // Перебираємо в порядку пріоритету й часу.
    final List<_QueuedTask> tmp = <_QueuedTask>[];
    _QueuedTask? picked;
    while (_pending.isNotEmpty) {
      final t = _pending.removeFirst();
      final activeForKey = _activeByKey[t.queueKey] ?? 0;
      if (activeForKey >= concurrencyPerKey) {
        tmp.add(t);
        continue;
      }
      picked = t;
      break;
    }
    // Повертаймо назад усі, що не підійшли.
    for (final t in tmp) {
      _pending.add(t);
    }
    return picked;
  }

  Future<void> _respectPerKeyBackpressure(String key) async {
    final last = _lastEmissionByKey[key];
    final now = DateTime.now();
    if (last == null) return;
    final elapsed = now.difference(last);
    final need = minDelayPerKey - elapsed;
    if (need <= Duration.zero) return;
    final rnd = Random();
    final add = maxJitter.inMicroseconds > 0
        ? Duration(microseconds: rnd.nextInt(maxJitter.inMicroseconds + 1))
        : Duration.zero;
    await Future<void>.delayed(need + add);
  }

  void _start(_QueuedTask task) {
    _activeGlobal++;
    _activeByKey.update(task.queueKey, (v) => v + 1, ifAbsent: () => 1);
    () async {
      try {
        await _respectPerKeyBackpressure(task.queueKey);
        final res = await task.run();
        task.complete(res);
      } catch (e, s) {
        task.completeError(e, s);
      } finally {
        _lastEmissionByKey[task.queueKey] = DateTime.now();
        _activeGlobal--;
        final left = (_activeByKey[task.queueKey] ?? 1) - 1;
        if (left <= 0) {
          _activeByKey.remove(task.queueKey);
        } else {
          _activeByKey[task.queueKey] = left;
        }
        _scheduleTick();
      }
    }();
  }
}

class _QueuedTask {
  _QueuedTask({
    required this.queueKey,
    required this.priority,
    required this.enqueuedAt,
    required this.run,
    required this.complete,
    required this.completeError,
  });
  final String queueKey;
  final int priority;
  final DateTime enqueuedAt;
  final Future<dynamic> Function() run;
  final void Function(dynamic) complete;
  final void Function(Object, StackTrace) completeError;
}
