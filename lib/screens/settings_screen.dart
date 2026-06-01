import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.storage,
    required this.notifications,
  });

  final StorageService storage;
  final NotificationService notifications;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings _settings = const AppSettings();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await widget.storage.loadSettings();
    if (!mounted) return;
    setState(() {
      _settings = s;
      _loading = false;
    });
  }

  Future<void> _save(AppSettings next) async {
    setState(() => _settings = next);
    await widget.storage.saveSettings(next);
    await widget.notifications.rescheduleFromSettings(next);
  }

  Future<void> _pickTime(bool morning) async {
    final current = AppSettings.parseTime(
        morning ? _settings.morningReminderTime : _settings.eveningReminderTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.$1, minute: current.$2),
    );
    if (picked == null) return;
    final hhmm =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await _save(morning
        ? _settings.copyWith(morningReminderTime: hhmm)
        : _settings.copyWith(eveningReminderTime: hhmm));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title: const Text('تذكير الصباح'),
                  trailing: Text(_settings.morningReminderTime),
                  onTap: () => _pickTime(true),
                ),
                ListTile(
                  title: const Text('تذكير المساء'),
                  trailing: Text(_settings.eveningReminderTime),
                  onTap: () => _pickTime(false),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('الكشف الصوتي'),
                  subtitle: const Text('الانتقال تلقائياً بعد قراءة الذكر'),
                  value: _settings.voiceDetectionEnabled,
                  onChanged: (v) =>
                      _save(_settings.copyWith(voiceDetectionEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('وضع القيادة (بدون لمس)'),
                  subtitle: const Text(
                      'ينطق العدد ويقرأ الذكر وينتقل تلقائياً — يتطلّب الكشف الصوتي'),
                  value: _settings.handsFreeMode,
                  onChanged: (v) =>
                      _save(_settings.copyWith(handsFreeMode: v)),
                ),
                ListTile(
                  title: const Text('حساسية الكشف'),
                  subtitle: Slider(
                    value: _settings.sensitivity,
                    onChanged: _settings.voiceDetectionEnabled
                        ? (v) => setState(
                            () => _settings = _settings.copyWith(sensitivity: v))
                        : null,
                    onChangeEnd: _settings.voiceDetectionEnabled
                        ? (v) => _save(_settings.copyWith(sensitivity: v))
                        : null,
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'الخصوصية: نستمع فقط لنعرف أنك أنهيت الذكر، لا نسجّل صوتك ولا نحوّله إلى نص ولا يخرج من جهازك.',
                  ),
                ),
              ],
            ),
    );
  }
}
