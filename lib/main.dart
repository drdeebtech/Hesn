import 'package:flutter/material.dart';

import 'app.dart';
import 'data/azkar_repository.dart';
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

  // Reconcile reminders on launch (backstop for reboot, FR-016).
  await notifications.init();
  final settings = await storage.loadSettings();
  await notifications.rescheduleFromSettings(settings);

  runApp(HesnApp(
    repository: repository,
    storage: storage,
    notifications: notifications,
    tts: tts,
    vad: vad,
    permissions: permissions,
  ));
}
