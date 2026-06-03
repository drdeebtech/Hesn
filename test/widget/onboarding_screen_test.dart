import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/screens/onboarding_screen.dart';
import 'package:hesn/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    );

void main() {
  testWidgets('onboarding explains hands-free, listen-only, and manual buttons',
      (tester) async {
    await tester.pumpWidget(_wrap(OnboardingScreen(onDone: () {})));
    await tester.pumpAndSettle();

    expect(find.textContaining('بدون لمس'), findsWidgets);
    expect(find.textContaining('لا نسجّل صوتك'), findsOneWidget);
    expect(find.textContaining('«تم» و«تجاوز»'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'ابدأ'), findsOneWidget);
  });

  testWidgets('tapping ابدأ fires onDone', (tester) async {
    var done = false;
    await tester.pumpWidget(_wrap(OnboardingScreen(onDone: () => done = true)));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'ابدأ'));
    expect(done, isTrue);
  });
}
