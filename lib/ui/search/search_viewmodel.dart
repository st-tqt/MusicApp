import 'dart:async';
import '../../data/model/song.dart';
import '../../data/model/playlist.dart';
import '../../data/repository/repository.dart';
import '../../data/repository/playlist_repository.dart';

class SearchViewModel {
  final _repository = DefaultRepository();
  final _playlistRepository = DefaultPlaylistRepository();

  final _songsController = StreamController<List<Song>>.broadcast();
  final _playlistsController = StreamController<List<Playlist>>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();

  Stream<List<Song>> get songsStream => _songsController.stream;
  Stream<List<Playlist>> get playlistsStream => _playlistsController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;

  List<Song> _allSongs = [];
  List<Playlist> _allPublicPlaylists = [];

  // Load tất cả dữ liệu
  Future<void> loadAllData() async {
    _loadingController.add(true);

    try {
      final results = await Future.wait([
        _repository.loadData(),
        _playlistRepository.loadPublicPlaylists(),
      ]);

      _allSongs = results[0] as List<Song>? ?? [];
      _allPublicPlaylists = results[1] as List<Playlist>? ?? [];

      print('Loaded ${_allSongs.length} songs');
      print('Loaded ${_allPublicPlaylists.length} playlists');
    } catch (e) {
      print('Error loading data: $e');
    }

    _loadingController.add(false);
  }

  // Tìm kiếm
  void performSearch(String query) {
    if (query.isEmpty) {
      _songsController.add([]);
      _playlistsController.add([]);
      return;
    }

    final lowercaseQuery = query.toLowerCase();

    // Tìm kiếm bài hát
    final searchResultSongs = _allSongs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
          song.artist.toLowerCase().contains(lowercaseQuery);
    }).toList();

    // Tìm kiếm playlist
    final searchResultPlaylists = _allPublicPlaylists.where((playlist) {
      final matchName = playlist.name.toLowerCase().contains(lowercaseQuery);
      final matchDesc = playlist.description?.toLowerCase().contains(lowercaseQuery) ?? false;
      final matchUser = playlist.userName?.toLowerCase().contains(lowercaseQuery) ?? false;

      return matchName || matchDesc || matchUser;
    }).toList();

    _songsController.add(searchResultSongs);
    _playlistsController.add(searchResultPlaylists);

    print('Found ${searchResultSongs.length} songs, ${searchResultPlaylists.length} playlists');
  }

  void dispose() {
    _songsController.close();
    _playlistsController.close();
    _loadingController.close();
  }
}