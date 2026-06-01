import 'dart:async';

import 'package:hesn/models/app_settings.dart';
import 'package:hesn/models/daily_progress.dart';
import 'package:hesn/services/storage_service.dart';
import 'package:hesn/services/cue_service.dart';
import 'package:hesn/services/permission_service.dart';
import 'package:hesn/services/tts_service.dart';
import 'package:hesn/services/vad_service.dart';

/// Records call order so tests can assert PLAY -> STOP -> LISTEN ordering.
class CallLog {
  final List<String> events = [];
  void add(String e) => events.add(e);
}

class FakeTtsService implements TtsService {
  FakeTtsService(this.log, {this.arabicVoice = true});
  final CallLog log;
  bool arabicVoice;
  bool speaking = false;

  /// Every utterance passed to [speak], in order (for assertions).
  final List<String> spoken = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> speak(String text) async {
    speaking = true;
    log.add('speak');
    spoken.add(text);
    // Simulate playback that completes before returning.
    speaking = false;
  }

  @override
  Future<void> stop() async {
    log.add('stop');
    speaking = false;
  }

  @override
  Future<bool> hasArabicVoice() async => arabicVoice;

  @override
  Future<void> dispose() async {}
}

class FakeCueService implements CueService {
  FakeCueService(this.log);
  final CallLog log;
  @override
  Future<void> transition() async => log.add('cue');
}

class FakeVadService implements VadService {
  FakeVadService(this.log, {this.granted = true});
  final CallLog log;
  bool granted;
  final StreamController<double> controller =
      StreamController<double>.broadcast();

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Stream<double> start({required double sensitivity}) {
    log.add('vad.start');
    return controller.stream;
  }

  @override
  Future<void> stop() async {
    log.add('vad.stop');
  }
}

class FakePermissionService implements PermissionService {
  FakePermissionService({this.granted = true});
  bool granted;

  @override
  Future<bool> micGranted() async => granted;

  @override
  Future<bool> requestMic() async => granted;
}

class FakeStorageService implements StorageService {
  AppSettings _settings = const AppSettings();
  DailyProgress? _progress;

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async => _settings = settings;

  @override
  Future<DailyProgress> loadProgress(String todayKey) async {
    final stored = _progress ?? DailyProgress(dateKey: todayKey);
    final today = stored.forToday(todayKey);
    _progress = today;
    return today;
  }

  @override
  Future<void> markListComplete(String listId, String todayKey) async {
    final today = await loadProgress(todayKey);
    _progress = today.markCompleted(listId);
  }
}
