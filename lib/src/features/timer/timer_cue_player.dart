import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kintore/src/features/timer/timer_cubit.dart';

class TimerCuePlayer {
  final _countdownPlayer = AudioPlayer();
  final _startPlayer = AudioPlayer();
  final _stopPlayer = AudioPlayer();
  var _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await Future.wait([
      _prepare(_countdownPlayer, 'audio/countdown.wav'),
      _prepare(_startPlayer, 'audio/start.wav'),
      _prepare(_stopPlayer, 'audio/stop.wav'),
    ]);
  }

  Future<void> play(TimerCue cue) async {
    try {
      await initialize();
      final player = switch (cue) {
        TimerCue.countdown => _countdownPlayer,
        TimerCue.start => _startPlayer,
        TimerCue.stop => _stopPlayer,
      };
      await player.stop();
      await player.resume();
      if (cue != TimerCue.countdown) {
        await HapticFeedback.mediumImpact();
      }
    } catch (error) {
      debugPrint('Timer cue playback failed: $error');
    }
  }

  Future<void> _prepare(AudioPlayer player, String assetPath) async {
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setVolume(1);
    await player.setSource(AssetSource(assetPath));
  }

  Future<void> dispose() async {
    await Future.wait([
      _countdownPlayer.dispose(),
      _startPlayer.dispose(),
      _stopPlayer.dispose(),
    ]);
  }
}
