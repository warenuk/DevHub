import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/github/presentation/providers/github_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChartPeriod { days7, days30 }

extension on ChartPeriod {
  int get days =>
      switch (this) { ChartPeriod.days7 => 7, ChartPeriod.days30 => 30 };
}

final chartPeriodProvider =
    StateProvider<ChartPeriod>((ref) => ChartPeriod.days7);

class ChartPoint {
  ChartPoint(this.date, this.count, this.samples);
  final DateTime date; // normalized to local day (midnight)
  final int count;
  final List<String>
      samples; // truncated samples of commit messages for the day
}

String _truncate(String s, {int max = 60}) {
  if (s.length <= max) return s;
  return '${s.substring(0, max - 1).trimRight()}…';
}

List<ChartPoint> _buildDailyCounts(List<CommitInfo> commits, int days) {
  final now = DateTime.now();
  final start =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
  final byDayCount = <DateTime, int>{};
  final byDayTexts = <DateTime, List<String>>{};

  for (final c in commits) {
    final d = c.date.toLocal();
    final key = DateTime(d.year, d.month, d.day);
    if (key.isBefore(start)) continue;
    byDayCount[key] = (byDayCount[key] ?? 0) + 1;
    final list = byDayTexts.putIfAbsent(key, () => <String>[]);
    if (list.length < 3) list.add(_truncate(c.message));
  }

  final points = <ChartPoint>[];
  for (int i = 0; i < days; i++) {
    final d = start.add(Duration(days: i));
    final count = byDayCount[d] ?? 0;
    final samples = byDayTexts[d] ?? const <String>[];
    points.add(ChartPoint(d, count, samples));
  }
  return points;
}

/// Exposes aggregated, chronologically ordered (oldest->newest) daily counts
/// for the selected period, computed from cached DB commits stream.
final commitChartDataProvider = Provider<AsyncValue<List<ChartPoint>>>((ref) {
  final commitsAsync = ref.watch(recentCommitsCacheProvider);
  final period = ref.watch(chartPeriodProvider);
  return commitsAsync.whenData((list) => _buildDailyCounts(list, period.days));
});
