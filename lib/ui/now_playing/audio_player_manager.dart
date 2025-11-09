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
  LoopMode loopMode = LoopMode.off;
  bool _isShuffle = false;

  // Dùng StreamController thay vì callback
  final _songChangedController = StreamController<Song>.broadcast();

  Stream<Song> get songChangedStream => _songChangedController.stream;

  StreamSubscription<PlayerState>? _playerStateSubscription;
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
        player.play();
      });
    }
  }

  void notifySongChanged(Song song) {
    _songChangedController.add(song);
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
  }

  void _handleSongCompleted() {
    if (loopMode == LoopMode.one) {
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
        if (loopMode == LoopMode.all) {
          nextIndex = 0;
        } else {
          return; // Dừng nếu hết playlist và không loop
        }
      }
    }

    _currentIndex = nextIndex;
    final nextSong = _playlist![nextIndex];
    updateSongUrl(nextSong.source);

    // THAY ĐỔI: Phát sự kiện qua Stream
    _songChangedController.add(nextSong);
  }

  void updateSongUrl(String url) {
    songUrl = url;
    prepare(isNewSong: true);
  }

  Future<void> dispose() async {
    try {
      await player.stop();
      await _playerStateSubscription?.cancel();
      _playerStateSubscription = null;
      await _songChangedController.close();

      await player.dispose();

      _isListenerInitialized = false;
    } catch (e) {
      print('Error disposing AudioPlayerManager: $e');
    }
  }

  static Future<void> reset() async {
    if (_instance != null) {
      await _instance!.dispose();
      _instance = null;
    } else {
      print('AudioPlayerManager singleton was already null');
    }
  }

  void setPlaylist(List<Song> songs, int startIndex) {
    _playlist = songs;
    _currentIndex = startIndex;
  }

  void setLoopMode(LoopMode mode) {
    loopMode = mode;
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
