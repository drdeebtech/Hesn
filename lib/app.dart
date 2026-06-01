import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/azkar_repository.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'services/vad_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

/// Root widget. Forces Arabic locale + RTL and wires the concrete services.
class HesnApp extends StatelessWidget {
  const HesnApp({
    super.key,
    required this.repository,
    required this.storage,
    required this.notifications,
    required this.tts,
    required this.vad,
    required this.permissions,
  });

  final AzkarRepository repository;
  final StorageService storage;
  final NotificationService notifications;
  final TtsService tts;
  final VadService vad;
  final PermissionService permissions;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حصن',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: HomeScreen(
        repository: repository,
        storage: storage,
        notifications: notifications,
        tts: tts,
        vad: vad,
        permissions: permissions,
      ),
    );
  }
}
