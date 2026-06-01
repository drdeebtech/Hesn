import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings.dart';

/// Two daily local reminders (morning + evening). No network/push.
abstract class NotificationService {
  Future<void> init({void Function(String listId)? onTapList});
  Future<void> rescheduleFromSettings(AppSettings settings);
  Future<void> cancelAll();

  /// The listId from a notification that launched the app (cold start), if any.
  Future<String?> launchListId();
}

class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _inited = false;
  void Function(String listId)? _onTapList;

  static const _morningId = 1001;
  static const _eveningId = 1002;
  static const _channelId = 'azkar_reminders';

  @override
  Future<void> init({void Function(String listId)? onTapList}) async {
    _onTapList = onTapList;
    if (_inited) return;
    tzdata.initializeTimeZones();
    final localName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localName));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: (resp) {
        final id = resp.payload;
        if (id != null && id.isNotEmpty) _onTapList?.call(id);
      },
    );
    _inited = true;
  }

  @override
  Future<String?> launchListId() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }

  @override
  Future<void> rescheduleFromSettings(AppSettings settings) async {
    await init();
    await cancelAll();
    await _scheduleDaily(
      id: _morningId,
      hhmm: settings.morningReminderTime,
      title: 'أذكار الصباح',
      body: 'حان وقت أذكار الصباح',
      payload: 'morning',
    );
    await _scheduleDaily(
      id: _eveningId,
      hhmm: settings.eveningReminderTime,
      title: 'أذكار المساء',
      body: 'حان وقت أذكار المساء',
      payload: 'evening',
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _scheduleDaily({
    required int id,
    required String hhmm,
    required String title,
    required String body,
    required String payload,
  }) async {
    final (hour, minute) = AppSettings.parseTime(hhmm);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'تذكير الأذكار',
        channelDescription: 'تذكير يومي بأذكار الصباح والمساء',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOf(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      payload: payload,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
