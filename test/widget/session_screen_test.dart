import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesn/models/app_settings.dart';
import 'package:hesn/models/azkar.dart';
import 'package:hesn/screens/session_screen.dart';

import '../fakes/fakes.dart';

AzkarList _list(int n) => AzkarList(
      id: 'morning',
      title: 'أذكار الصباح',
      items: [
        for (var i = 0; i < n; i++)
          AzkarItem(
            id: 'm_$i',
            type: AzkarType.dhikr,
            text: 'ذكر رقم $i',
            repeat: 1,
            source: 'حصن المسلم',
          ),
      ],
    );

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('Done and Skip are always present (voice disabled, US2)',
      (tester) async {
    final log = CallLog();
    await tester.pumpWidget(_wrap(SessionScreen(
      list: _list(2),
      settings: const AppSettings(
          voiceDetectionEnabled: false, handsFreeMode: false),
      tts: FakeTtsService(log),
      vad: FakeVadService(log),
      permissions: FakePermissionService(),
      storage: FakeStorageService(),
      stopGuard: Duration.zero,
    )));
    await tester.pumpAndSettle();

    expect(find.text('تم'), findsOneWidget);
    expect(find.text('تجاوز'), findsOneWidget);
    expect(log.events.contains('vad.start'), isFalse);
  });

  testWidgets('tapping تم advances to the next phrase', (tester) async {
    final log = CallLog();
    await tester.pumpWidget(_wrap(SessionScreen(
      list: _list(2),
      settings: const AppSettings(
          voiceDetectionEnabled: false, handsFreeMode: false),
      tts: FakeTtsService(log),
      vad: FakeVadService(log),
      permissions: FakePermissionService(),
      storage: FakeStorageService(),
      stopGuard: Duration.zero,
    )));
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
  });
}
