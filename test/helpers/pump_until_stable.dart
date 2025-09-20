import 'package:flutter_test/flutter_test.dart';

/// Pumps a widget tree a fixed number of times with a small delay between
/// frames to give asynchronous work time to settle without hanging forever like
/// [WidgetTester.pumpAndSettle].
Future<void> pumpUntilStable(
  WidgetTester tester, {
  int maxPumps = 10,
  Duration interval = const Duration(milliseconds: 100),
}) async {
  await tester.pump();
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(interval);
  }
}
