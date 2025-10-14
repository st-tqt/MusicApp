import 'dart:async';
import '../../data/model/song.dart';
import '../../data/repository/favorite_repository.dart';

class FavoriteViewModel {
  StreamController<List<Song>> songStream = StreamController();
  final _repository = DefaultFavoriteRepository();

  void loadFavoriteSongs() {
    _repository.loadFavoriteSongs().then((value) {
      if (value != null) {
        songStream.add(value);
      } else {
        songStream.add([]);
      }
    });
  }

  Future<bool> toggleFavorite(String songId) async {
    return await _repository.toggleFavorite(songId);
  }

  Future<bool> isFavorite(String songId) async {
    return await _repository.isFavorite(songId);
  }
}