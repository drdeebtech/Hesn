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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // RTL: content first (right), then a leading accent rail (left).
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(list.title,
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                          Icon(icon, color: cs.primary, size: 28),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${list.length} ذِكر',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 14),
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
              Container(
                width: 5,
                color: completed ? success : cs.primary.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
