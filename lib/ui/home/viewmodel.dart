import 'dart:async';

import 'package:music_app/data/repository/repository.dart';
import '../../data/model/song.dart';

import '../../data/model/user.dart';
import '../../data/repository/user_repository.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();

  void loadSongs() {
    final repository = DefaultRepository();
    repository.loadData().then((value) => songStream.add(value!));
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