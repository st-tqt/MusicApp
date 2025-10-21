import '../model/song.dart';
import '../model/listening_history.dart';
import '../source/listening_history_source.dart';
import 'repository.dart';

abstract class ListeningHistoryRepository {
  Future<bool> addToHistory(String songId);
  Future<List<Song>?> getHistorySongs();
  Future<List<ListeningHistory>?> getHistoryRecords();
}

class DefaultListeningHistoryRepository implements ListeningHistoryRepository {
  final _dataSource = ListeningHistoryDataSourceImpl();
  final _songRepository = DefaultRepository();

  @override
  Future<bool> addToHistory(String songId) async {
    final result = await _dataSource.addListeningHistory(songId);
    return result;
  }

  @override
  Future<List<ListeningHistory>?> getHistoryRecords() async {
    return await _dataSource.getListeningHistoryRecords();
  }

  @override
  Future<List<Song>?> getHistorySongs() async {
    try {
      // Lấy danh sách ListeningHistory
      final histories = await _dataSource.getListeningHistoryRecords();
      if (histories == null || histories.isEmpty) return [];

      // Lấy danh sách songId (không trùng lặp, giữ thứ tự)
      final List<String> songIds = [];
      final Set<String> addedIds = {};

      for (var history in histories) {
        if (!addedIds.contains(history.songId)) {
          songIds.add(history.songId);
          addedIds.add(history.songId);
        }
      }

      // Lấy thông tin chi tiết các bài hát
      final songs = await _songRepository.loadSongsByIds(songIds);
      if (songs == null) return [];

      // Sắp xếp songs theo thứ tự của songIds
      final Map<String, Song> songMap = {for (var song in songs) song.id: song};
      final List<Song> orderedSongs = [];

      for (var songId in songIds) {
        final song = songMap[songId];
        if (song != null) {
          orderedSongs.add(song);
        }
      }

      return orderedSongs;
    } catch (e) {
      print('[Repository] Error getting history songs: $e');
      return null;
    }
  }
}