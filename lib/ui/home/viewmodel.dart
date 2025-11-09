import 'dart:async';

import 'package:music_app/data/repository/repository.dart';
import 'package:music_app/data/repository/listening_history_repository.dart';
import '../../data/model/song.dart';

import '../../data/model/user.dart';
import '../../data/repository/user_repository.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();
  StreamController<List<Song>> recommendedStream = StreamController();
  StreamController<List<Song>> trendingStream = StreamController();
  StreamController<List<Song>> recentStream = StreamController();
  final _repository = DefaultRepository();
  final _historyRepository = DefaultListeningHistoryRepository();

  Future<void> loadSongs() async {
    await _repository.loadData().then((value) {
      if (value != null) {
        songStream.add(value);
      }
    });
  }

  Future<void> loadRecommendedSongs() async {
    final songs = await _repository.loadRandomSongs(12);
    if (songs != null) {
      recommendedStream.add(songs);
    }
  }

  Future<void> loadTrendingSongs() async {
    final songs = await _repository.loadTrendingSongs(5);
    if (songs != null) {
      trendingStream.add(songs);
    }
  }

  Future<void> loadRecentSongs() async {
    final songs = await _historyRepository.getHistorySongs();
    if (songs != null) {
      recentStream.add(songs);
    }
  }

  void dispose() {
    songStream.close();
    recommendedStream.close();
    trendingStream.close();
    recentStream.close();
  }
}