import 'package:flutter/services.dart';

/// Non-spoken audio/haptic cue for hands-free transitions (FR-026). Uses only
/// built-in platform facilities — no audio dependency, no asset files
/// (Constitution Principle VI).
abstract class CueService {
  Future<void> transition();
}

class PlatformCueService implements CueService {
  const PlatformCueService();

  @override
  Future<void> transition() async {
    await SystemSound.play(SystemSoundType.click);
    await HapticFeedback.lightImpact();
  }
}
