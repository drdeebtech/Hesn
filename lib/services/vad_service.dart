import 'dart:math' as math;
import 'dart:typed_data';

import 'package:record/record.dart';

/// Microphone voice-activity detection by **amplitude only**.
///
/// Constitution Principle III: MUST NOT write audio to disk, MUST NOT
/// transcribe, MUST NOT touch the network. [start] emits a normalized 0..1
/// loudness level per sample; [stop] releases the mic.
abstract class VadService {
  Future<bool> hasPermission();
  Stream<double> start({required double sensitivity});
  Future<void> stop();
}

/// `record`-backed implementation using a raw PCM stream (no file is created).
/// Each PCM chunk is reduced to an RMS level and mapped to 0..1.
class RecordVadService implements VadService {
  RecordVadService([AudioRecorder? recorder])
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Stream<double> start({required double sensitivity}) async* {
    const config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );
    final stream = await _recorder.startStream(config);
    await for (final chunk in stream) {
      yield _levelFromPcm16(chunk);
    }
  }

  @override
  Future<void> stop() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }

  /// RMS of signed 16-bit little-endian PCM, mapped to a 0..1 loudness level.
  static double _levelFromPcm16(Uint8List bytes) {
    if (bytes.length < 2) return 0.0;
    final data = ByteData.sublistView(bytes);
    final samples = bytes.length ~/ 2;
    double sumSq = 0;
    for (var i = 0; i < samples; i++) {
      final s = data.getInt16(i * 2, Endian.little) / 32768.0;
      sumSq += s * s;
    }
    final rms = math.sqrt(sumSq / samples);
    // Map RMS (~0..1) to a perceptual 0..1 via dBFS clamp.
    final db = 20 * (math.log(rms <= 0 ? 1e-7 : rms) / math.ln10);
    // -60 dBFS (silence) -> 0 ; 0 dBFS (max) -> 1
    final level = (db + 60) / 60;
    return level.clamp(0.0, 1.0);
  }
}
