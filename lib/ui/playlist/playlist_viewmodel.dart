import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/model/playlist.dart';
import '../../data/model/song.dart';
import '../../data/repository/playlist_repository.dart';

class PlaylistViewModel {
  final _repository = DefaultPlaylistRepository();
  final _playlistsController = StreamController<List<Playlist>>.broadcast();
  final _loadingController = StreamController<bool>.broadcast();

  Stream<List<Playlist>> get playlistsStream => _playlistsController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;

  Future<void> loadUserPlaylists() async {
    _loadingController.add(true);

    final playlists = await _repository.loadUserPlaylists();
    if (playlists != null) {
      _playlistsController.add(playlists);
    }
    _loadingController.add(false);
  }

  // Thêm method mới để trả về List<Playlist> trực tiếp
  Future<List<Playlist>?> getUserPlaylists() async {
    return await _repository.loadUserPlaylists();
  }

  Future<Playlist?> createPlaylist(String name, String? description, bool isPublic) async {
    _loadingController.add(true);
    final playlist = await _repository.createPlaylist(name, description, isPublic);
    _loadingController.add(false);

    if (playlist != null) {
      await loadUserPlaylists();
    }

    return playlist;
  }

  Future<bool> updatePlaylist(String playlistId, String name, String? description, bool isPublic) async {
    _loadingController.add(true);
    final success = await _repository.updatePlaylist(playlistId, name, description, isPublic);
    _loadingController.add(false);

    if (success) {
      await loadUserPlaylists();
    }

    return success;
  }

  Future<bool> deletePlaylist(String playlistId) async {
    _loadingController.add(true);
    final success = await _repository.deletePlaylist(playlistId);
    _loadingController.add(false);

    if (success) {
      await loadUserPlaylists();
    }

    return success;
  }

  Future<List<Song>?> loadPlaylistSongs(String playlistId) async {
    return await _repository.loadPlaylistSongs(playlistId);
  }

  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    return await _repository.addSongToPlaylist(playlistId, songId);
  }

  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    return await _repository.removeSongFromPlaylist(playlistId, songId);
  }

  Future<bool> isSongInPlaylist(String playlistId, String songId) async {
    return await _repository.isSongInPlaylist(playlistId, songId);
  }

  Future<List<Playlist>?> loadPublicPlaylists() async {
    return await _repository.loadPublicPlaylists();
  }

  void dispose() {
    _playlistsController.close();
    _loadingController.close();
  }
}