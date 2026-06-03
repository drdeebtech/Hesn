import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../util/arabic_numbers.dart';

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
    final current = AppSettings.parseTime(morning
        ? _settings.morningReminderTime
        : _settings.eveningReminderTime);
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _sectionHeader('التذكيرات'),
                Card(
                  child: Column(
                    children: [
                      _timeRow('تذكير الصباح', _settings.morningReminderTime,
                          () => _pickTime(true)),
                      Divider(height: 1, color: cs.outlineVariant),
                      _timeRow('تذكير المساء', _settings.eveningReminderTime,
                          () => _pickTime(false)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _sectionHeader('التشغيل'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('الكشف الصوتي'),
                        subtitle:
                            const Text('الانتقال تلقائياً بعد قراءة الذكر'),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _sensitivity(cs),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'نستمع فقط لنعرف أنك أنهيت الذكر، لا نسجّل صوتك ولا نحوّله إلى نص ولا يخرج من جهازك.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _sensitivity(ColorScheme cs) {
    final text = Theme.of(context).textTheme;
    final enabled = _settings.voiceDetectionEnabled;
    final percent = (_settings.sensitivity * 100).round();
    final disabledColor = cs.onSurfaceVariant.withValues(alpha: 0.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الحساسية',
                style: text.bodyLarge
                    ?.copyWith(color: enabled ? null : disabledColor)),
            // Live value readout.
            Text('${toArabicDigits(percent.toString())}٪',
                style: text.bodyLarge?.copyWith(
                    color: enabled ? cs.primary : disabledColor,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 2),
        // Context caption (P3): what the control actually does.
        Text('تحدد مستوى الصوت اللازم للكشف — ارفعها في الأماكن الهادئة.',
            style: text.bodyMedium),
        Slider(
          value: _settings.sensitivity,
          divisions: 10,
          label: '${toArabicDigits(percent.toString())}٪',
          onChanged: enabled
              ? (v) =>
                  setState(() => _settings = _settings.copyWith(sensitivity: v))
              : null,
          onChangeEnd:
              enabled ? (v) => _save(_settings.copyWith(sensitivity: v)) : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('عالية', style: text.bodyMedium),
            Text('منخفضة', style: text.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
        child: Text(text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: .3)),
      );

  Widget _timeRow(String label, String time, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    // Single affordance: the whole row is the tap target. The trailing pill is
    // a value readout (not a second button), so there's no double affordance.
    return ListTile(
      leading: Icon(Icons.notifications_active_outlined, color: cs.primary),
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(toArabicDigits(time),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            const SizedBox(width: 6),
            Icon(Icons.edit_outlined, size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
