import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/daily_progress.dart';

/// Local persistence for settings and daily progress. No network.
abstract class StorageService {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);

  /// Returns today's progress, resetting to a fresh record when the stored
  /// dateKey != [todayKey] (date-rollover, FR-012).
  Future<DailyProgress> loadProgress(String todayKey);
  Future<void> markListComplete(String listId, String todayKey);
}

class SharedPrefsStorageService implements StorageService {
  static const _settingsKey = 'app_settings';
  static const _progressKey = 'daily_progress';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<AppSettings> loadSettings() async {
    final p = await _prefs;
    final raw = p.getString(_settingsKey);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final p = await _prefs;
    await p.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<DailyProgress> loadProgress(String todayKey) async {
    final p = await _prefs;
    final raw = p.getString(_progressKey);
    final stored = raw == null
        ? DailyProgress(dateKey: todayKey)
        : DailyProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final today = stored.forToday(todayKey);
    if (raw == null || stored.dateKey != todayKey) {
      await p.setString(_progressKey, jsonEncode(today.toJson()));
    }
    return today;
  }

  @override
  Future<void> markListComplete(String listId, String todayKey) async {
    final today = await loadProgress(todayKey);
    final updated = today.markCompleted(listId);
    final p = await _prefs;
    await p.setString(_progressKey, jsonEncode(updated.toJson()));
  }
}
