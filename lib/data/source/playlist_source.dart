import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/playlist.dart';
import '../model/song.dart';

abstract interface class PlaylistDataSource {
  Future<List<Playlist>?> loadUserPlaylists(String userId);
  Future<Playlist?> createPlaylist(String userId, String name, String? description, bool isPublic);
  Future<bool> updatePlaylist(String playlistId, String name, String? description, bool isPublic);
  Future<bool> deletePlaylist(String playlistId);
  Future<List<Song>?> loadPlaylistSongs(String playlistId);
  Future<bool> addSongToPlaylist(String playlistId, String songId);
  Future<bool> removeSongFromPlaylist(String playlistId, String songId);
  Future<bool> isSongInPlaylist(String playlistId, String songId);
  Future<List<Playlist>?> loadPublicPlaylists();
}

class RemotePlaylistDataSource implements PlaylistDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Playlist>?> loadUserPlaylists(String userId) async {
    try {
      final response = await supabase
          .from('playlists')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      List<Playlist> playlists = (response as List)
          .map((playlist) => Playlist.fromMap(playlist as Map<String, dynamic>))
          .toList();
      return playlists;
    } catch (e) {
      print('Error loading user playlists: $e');
      return null;
    }
  }

  @override
  Future<Playlist?> createPlaylist(String userId, String name, String? description, bool isPublic) async {
    try {
      final response = await supabase
          .from('playlists')
          .insert({
        'user_id': userId,
        'name': name,
        'description': description,
        'is_public': isPublic,
      })
          .select()
          .single();

      return Playlist.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating playlist: $e');
      return null;
    }
  }

  @override
  Future<bool> updatePlaylist(String playlistId, String name, String? description, bool isPublic) async {
    try {
      await supabase
          .from('playlists')
          .update({
        'name': name,
        'description': description,
        'is_public': isPublic,
      })
          .eq('id', playlistId);

      return true;
    } catch (e) {
      print('Error updating playlist: $e');
      return false;
    }
  }

  @override
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      await supabase
          .from('playlists')
          .delete()
          .eq('id', playlistId);

      return true;
    } catch (e) {
      print('Error deleting playlist: $e');
      return false;
    }
  }

  @override
  Future<List<Song>?> loadPlaylistSongs(String playlistId) async {
    try {
      final response = await supabase
          .from('playlist_songs')
          .select('song_id, songs(*)')
          .eq('playlist_id', playlistId)
          .order('position', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      List<Song> songs = (response as List)
          .map((item) => Song.fromMap(item['songs'] as Map<String, dynamic>))
          .toList();
      return songs;
    } catch (e) {
      print('Error loading playlist songs: $e');
      return null;
    }
  }

  @override
  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    try {
      // Kiểm tra xem bài hát đã có trong playlist chưa
      final existing = await supabase
          .from('playlist_songs')
          .select()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);

      if (existing.isNotEmpty) {
        print('Song already in playlist');
        return false;
      }

      // Lấy vị trí cuối cùng
      final lastPosition = await supabase
          .from('playlist_songs')
          .select('position')
          .eq('playlist_id', playlistId)
          .order('position', ascending: false)
          .limit(1);

      int newPosition = 0;
      if (lastPosition.isNotEmpty) {
        newPosition = (lastPosition[0]['position'] as int? ?? -1) + 1;
      }

      await supabase
          .from('playlist_songs')
          .insert({
        'playlist_id': playlistId,
        'song_id': songId,
        'position': newPosition,
      });

      return true;
    } catch (e) {
      print('Error adding song to playlist: $e');
      return false;
    }
  }

  @override
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      await supabase
          .from('playlist_songs')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);

      return true;
    } catch (e) {
      print('Error removing song from playlist: $e');
      return false;
    }
  }

  @override
  Future<bool> isSongInPlaylist(String playlistId, String songId) async {
    try {
      final response = await supabase
          .from('playlist_songs')
          .select()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);

      return response.isNotEmpty;
    } catch (e) {
      print('Error checking song in playlist: $e');
      return false;
    }
  }

  @override
  Future<List<Playlist>?> loadPublicPlaylists() async {
    try {
      final response = await supabase
          .from('playlists')
          .select('*, profiles(name, avatar_url)')
          .eq('is_public', true)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      List<Playlist> playlists = (response as List)
          .map((playlist) => Playlist.fromMap(playlist as Map<String, dynamic>))
          .toList();
      return playlists;
    } catch (e) {
      print('Error loading public playlists: $e');
      return null;
    }
  }
}