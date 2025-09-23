import 'package:devhub_gpt/features/commits/presentation/pages/commits_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_until_stable.dart';

void main() {
  testWidgets('CommitsPage renders list', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CommitsPage())),
    );
    await pumpUntilStable(tester);
    expect(find.text('Recent Commits'), findsOneWidget);
  });
}
