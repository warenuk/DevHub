import 'package:devhub_gpt/features/notes/presentation/pages/notes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_until_stable.dart';

void main() {
  testWidgets('NotesPage renders and can add a note', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: NotesPage())),
    );
    await tester.pump();
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('No notes yet'), findsOneWidget);

    // Tap FAB to add
    await tester.tap(find.byType(FloatingActionButton));
    await pumpUntilStable(tester);
    await tester.enterText(find.byType(TextField).at(0), 'First');
    await tester.enterText(find.byType(TextField).at(1), 'Content');
    await tester.tap(find.text('Save'));
    await pumpUntilStable(tester);
    expect(find.text('First'), findsOneWidget);
  });
}
