import 'package:flutter/material.dart';

import 'app.dart';
import 'data/azkar_repository.dart';
import 'screens/session_screen.dart';
import 'services/cue_service.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'services/vad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = AzkarRepository();
  final storage = SharedPrefsStorageService();
  final notifications = LocalNotificationService();
  final tts = FlutterTtsService();
  final vad = RecordVadService();
  final permissions = PermissionHandlerService();
  const cue = PlatformCueService();
  final navigatorKey = GlobalKey<NavigatorState>();

  // Open a session straight from a reminder tap (FR-027).
  Future<void> openSession(String listId) async {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    final list = await repository.byId(listId);
    final settings = await storage.loadSettings();
    await nav.push(MaterialPageRoute(
      builder: (_) => SessionScreen(
        list: list,
        settings: settings,
        tts: tts,
        vad: vad,
        permissions: permissions,
        storage: storage,
        cue: cue,
      ),
    ));
    // Refresh progress is handled by HomeScreen on return.
  }

  await notifications.init(onTapList: openSession);
  final settings = await storage.loadSettings();
  await notifications.rescheduleFromSettings(settings);

  // Cold start from a notification → jump straight into that session.
  final launchListId = await notifications.launchListId();

  runApp(HesnApp(
    repository: repository,
    storage: storage,
    notifications: notifications,
    tts: tts,
    vad: vad,
    permissions: permissions,
    navigatorKey: navigatorKey,
  ));

  if (launchListId != null && launchListId.isNotEmpty) {
    WidgetsBinding.instance.addPostFrameCallback((_) => openSession(launchListId));
  }
}
