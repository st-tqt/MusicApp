import 'dart:async';

import 'package:music_app/data/repository/repository.dart';
import '../../data/model/song.dart';

import '../../data/model/user.dart';
import '../../data/repository/user_repository.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();
  StreamController<List<Song>> recommendedStream = StreamController();
  final _repository = DefaultRepository();

  void loadSongs() {
    _repository.loadData().then((value) {
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

  void dispose() {
    songStream.close();
    recommendedStream.close();
  }
}

class UserViewModel {
  final UserRepository _repository = UserRepository();
  final StreamController<UserModel?> userStream =
      StreamController<UserModel?>.broadcast();

  loadCurrentUser() async {
    final user = await _repository.fetchCurrentUser();
    userStream.add(user);
  }

  void dispose() {
    userStream.close();
  }
}
