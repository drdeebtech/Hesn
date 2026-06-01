import 'package:flutter/material.dart';

import '../data/azkar_repository.dart';
import '../models/azkar.dart';
import '../models/daily_progress.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/vad_service.dart';
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(list.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${list.length} ذِكر',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProgressBadge(completed: completed),
                  FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.play_arrow),
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
