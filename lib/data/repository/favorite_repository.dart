import 'package:music_app/data/source/favorite_source.dart';
import '../model/song.dart';
import 'repository.dart';

abstract interface class FavoriteRepository {
  Future<bool> isFavorite(String songId);
  Future<bool> toggleFavorite(String songId);
  Future<List<Song>?> loadFavoriteSongs();
}

class DefaultFavoriteRepository implements FavoriteRepository {
  final _remoteFavoriteSource = RemoteFavoriteDataSource();
  final _songRepository = DefaultRepository();

  @override
  Future<bool> isFavorite(String songId) async {
    return await _remoteFavoriteSource.isFavorite(songId);
  }

  @override
  Future<bool> toggleFavorite(String songId) async {
    final isFav = await _remoteFavoriteSource.isFavorite(songId);
    if (isFav) {
      return await _remoteFavoriteSource.removeFavorite(songId);
    } else {
      return await _remoteFavoriteSource.addFavorite(songId);
    }
  }

  @override
  Future<List<Song>?> loadFavoriteSongs() async {
    // Lấy danh sách song IDs yêu thích
    final favoriteSongIds = await _remoteFavoriteSource.getFavoriteSongIds();
    if (favoriteSongIds.isEmpty) {
      return [];
    }

    // Load tất cả bài hát
    final allSongs = await _songRepository.loadData();
    if (allSongs == null || allSongs.isEmpty) {
      return [];
    }

    // Filter ra những bài hát yêu thích
    final favoriteSongs = allSongs
        .where((song) => favoriteSongIds.contains(song.id))
        .toList();

    // Sắp xếp theo thứ tự trong favoriteSongIds (mới nhất trước)
    favoriteSongs.sort((a, b) {
      final indexA = favoriteSongIds.indexOf(a.id);
      final indexB = favoriteSongIds.indexOf(b.id);
      return indexA.compareTo(indexB);
    });

    return favoriteSongs;
  }
}