import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  static AudioPlayerManager? _instance;
  AudioPlayerManager._internal();

  factory AudioPlayerManager() {
    _instance ??= AudioPlayerManager._internal();
    return _instance!;
  }

  final player = AudioPlayer();

  Stream<DurationState>? durationState;
  String songUrl = '';

  void prepare({bool isNewSong = false}) {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
          (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
    if (isNewSong && songUrl.isNotEmpty) {
      player.setUrl(songUrl).then((_) {
        player.play(); // Tự động phát sau khi tải URL mới
      });
    }
  }

  void updateSongUrl(String url) {
    songUrl = url;
    prepare(isNewSong: true);
  }

  void dispose() {
    player.dispose();
  }

  static void reset() {
    _instance = AudioPlayerManager._internal();
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}