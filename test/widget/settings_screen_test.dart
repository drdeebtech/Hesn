import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/screens/settings_screen.dart';
import 'package:hesn/theme/app_theme.dart';

import '../fakes/fakes.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    );

void main() {
  testWidgets('sensitivity shows a live percentage readout and caption',
      (tester) async {
    await tester.pumpWidget(_wrap(SettingsScreen(
      storage: FakeStorageService(),
      notifications: FakeNotificationService(),
    )));
    await tester.pumpAndSettle();

    // Default sensitivity 0.5 → ٥٠٪ (Arabic-Indic).
    expect(find.text('٥٠٪'), findsWidgets);
    // The context caption (P3) explains what the control does.
    expect(
      find.textContaining('تحدد مستوى الصوت اللازم للكشف'),
      findsOneWidget,
    );
  });

  testWidgets('time row exposes a single tap target with an edit affordance',
      (tester) async {
    await tester.pumpWidget(_wrap(SettingsScreen(
      storage: FakeStorageService(),
      notifications: FakeNotificationService(),
    )));
    await tester.pumpAndSettle();

    // The trailing pill is a value readout, not a second button.
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
    // Both reminder times render as Arabic-Indic readouts.
    expect(find.text('٠٦:٣٠'), findsOneWidget); // morning default
    expect(find.text('١٦:٣٠'), findsOneWidget); // evening default
  });
}
