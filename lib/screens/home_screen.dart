import 'package:flutter/material.dart';

import '../data/azkar_repository.dart';
import '../models/azkar.dart';
import '../models/daily_progress.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/vad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_badge.dart';
import 'session_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AzkarList>? _lists;
  DailyProgress? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lists = await widget.repository.loadAll();
    final progress = await widget.storage
        .loadProgress(DailyProgress.dateKeyFor(DateTime.now()));
    if (!mounted) return;
    setState(() {
      _lists = lists;
      _progress = progress;
      _loading = false;
    });
  }

  Future<void> _openList(AzkarList list) async {
    final settings = await widget.storage.loadSettings();
    if (!mounted) return;
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SessionScreen(
          list: list,
          settings: settings,
          tts: widget.tts,
          vad: widget.vad,
          permissions: widget.permissions,
          storage: widget.storage,
        ),
      ),
    );
    if (done == true) await _load();
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          storage: widget.storage,
          notifications: widget.notifications,
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حصن'),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final list in _lists!)
                  _ListCard(
                    list: list,
                    completed:
                        _progress?.isCompleted(list.id) ?? false,
                    onTap: () => _openList(list),
                  ),
              ],
            ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.list,
    required this.completed,
    required this.onTap,
  });

  final AzkarList list;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final success = Theme.of(context).extension<HesnColors>()!.success;
    final isMorning = list.id == 'morning';
    final icon = isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round;

    // State carried by a full border + soft background tint (not a side stripe).
    final borderColor = completed ? success : cs.outline;
    final tint = completed ? success.withValues(alpha: 0.06) : cs.surface;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: completed ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Leading time-of-day icon disc (RTL: visually trailing).
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: cs.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(list.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('${list.length} ذِكر',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProgressBadge(completed: completed),
                  FilledButton.icon(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('ابدأ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
