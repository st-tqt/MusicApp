import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/playlist.dart';
import '../model/song.dart';
import '../source/playlist_source.dart';

abstract interface class PlaylistRepository {
  Future<List<Playlist>?> loadUserPlaylists();
  Future<Playlist?> createPlaylist(String name, String? description, bool isPublic);
  Future<bool> updatePlaylist(String playlistId, String name, String? description, bool isPublic);
  Future<bool> deletePlaylist(String playlistId);
  Future<List<Song>?> loadPlaylistSongs(String playlistId);
  Future<bool> addSongToPlaylist(String playlistId, String songId);
  Future<bool> removeSongFromPlaylist(String playlistId, String songId);
  Future<bool> isSongInPlaylist(String playlistId, String songId);
  Future<List<Playlist>?> loadPublicPlaylists();
}

class DefaultPlaylistRepository implements PlaylistRepository {
  final _remoteDataSource = RemotePlaylistDataSource();
  final supabase = Supabase.instance.client;

  @override
  Future<List<Playlist>?> loadUserPlaylists() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('User not logged in');
      return null;
    }
    return await _remoteDataSource.loadUserPlaylists(userId);
  }

  @override
  Future<Playlist?> createPlaylist(String name, String? description, bool isPublic) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('User not logged in');
      return null;
    }
    return await _remoteDataSource.createPlaylist(userId, name, description, isPublic);
  }

  @override
  Future<bool> updatePlaylist(String playlistId, String name, String? description, bool isPublic) async {
    return await _remoteDataSource.updatePlaylist(playlistId, name, description, isPublic);
  }

  @override
  Future<bool> deletePlaylist(String playlistId) async {
    return await _remoteDataSource.deletePlaylist(playlistId);
  }

  @override
  Future<List<Song>?> loadPlaylistSongs(String playlistId) async {
    return await _remoteDataSource.loadPlaylistSongs(playlistId);
  }

  @override
  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    return await _remoteDataSource.addSongToPlaylist(playlistId, songId);
  }

  @override
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    return await _remoteDataSource.removeSongFromPlaylist(playlistId, songId);
  }

  @override
  Future<bool> isSongInPlaylist(String playlistId, String songId) async {
    return await _remoteDataSource.isSongInPlaylist(playlistId, songId);
  }

  @override
  Future<List<Playlist>?> loadPublicPlaylists() async {
    return await _remoteDataSource.loadPublicPlaylists();
  }
}