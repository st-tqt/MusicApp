import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/model/song.dart';

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

  List<Song>? _playlist;
  int _currentIndex = 0;
  LoopMode _loopMode = LoopMode.off;
  bool _isShuffle = false;
  Function(Song)? onSongChanged;

  StreamSubscription<PlayerState>? _playerStateSubscription; // THÊM biến này
  bool _isListenerInitialized = false;

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

    // Lắng nghe sự kiện bài hát kết thúc
    if (!_isListenerInitialized) {
      _playerStateSubscription = player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _handleSongCompleted();
        }
      });
      _isListenerInitialized = true;
    }

    if (isNewSong && songUrl.isNotEmpty) {
      player.setUrl(songUrl).then((_) {
        player.play(); // Tự động phát sau khi tải URL mới
      });
    }
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
  }

  void _handleSongCompleted() {
    if (_loopMode == LoopMode.one) {
      player.seek(Duration.zero);
      player.play();
      return;
    }

    if (_playlist == null || _playlist!.isEmpty) return;

    // Tính index bài tiếp theo
    int nextIndex;
    if (_isShuffle) {
      nextIndex = Random().nextInt(_playlist!.length);
    } else {
      nextIndex = _currentIndex + 1;
      if (nextIndex >= _playlist!.length) {
        if (_loopMode == LoopMode.all) {
          nextIndex = 0;
        } else {
          return; // Dừng nếu hết playlist và không loop
        }
      }
    }

    _currentIndex = nextIndex;
    final nextSong = _playlist![nextIndex];
    updateSongUrl(nextSong.source);

    // Thông báo cho UI cập nhật
    onSongChanged?.call(nextSong);
  }

  void updateSongUrl(String url) {
    songUrl = url;
    prepare(isNewSong: true);
  }

  void dispose() {
    _playerStateSubscription?.cancel();
    player.dispose();
  }

  static void reset() {
    _instance?._playerStateSubscription?.cancel();
    _instance = AudioPlayerManager._internal();
  }

  void setPlaylist(List<Song> songs, int startIndex) {
    _playlist = songs;
    _currentIndex = startIndex;
  }

  void setLoopMode(LoopMode mode) {
    _loopMode = mode;
    player.setLoopMode(mode);
  }

  void setShuffle(bool shuffle) {
    _isShuffle = shuffle;
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