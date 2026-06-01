/// Phases of a single-phrase lifecycle in a guided azkar session.
///
/// The order is significant and encodes Constitution Principle II
/// (PLAY -> STOP -> LISTEN): the microphone may only be live during
/// [listening], and [listening] can only be entered after [stopping] has
/// completed. There is never a direct transition from [playing] to
/// [listening].
enum SessionPhase {
  /// No session running.
  idle,

  /// TTS is speaking the current phrase. Mic MUST be closed.
  playing,

  /// TTS has been told to stop; waiting for playback teardown before listening.
  stopping,

  /// Mic is live, watching amplitude (VAD). Only reachable after [stopping].
  listening,

  /// Transitioning to the next phrase (or to [done]).
  advancing,

  /// The whole list is finished.
  done,
}
