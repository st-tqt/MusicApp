import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class FavoriteDataSource {
  Future<bool> isFavorite(String songId);
  Future<bool> addFavorite(String songId);
  Future<bool> removeFavorite(String songId);
  Future<List<String>> getFavoriteSongIds();
}

class RemoteFavoriteDataSource implements FavoriteDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<bool> isFavorite(String songId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await supabase
          .from('favorite_songs')
          .select('song_id')
          .eq('user_id', userId)
          .eq('song_id', songId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  @override
  Future<bool> addFavorite(String songId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase.from('favorite_songs').insert({
        'user_id': userId,
        'song_id': songId,
        'liked_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error adding favorite: $e');
      return false;
    }
  }

  @override
  Future<bool> removeFavorite(String songId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase
          .from('favorite_songs')
          .delete()
          .eq('user_id', userId)
          .eq('song_id', songId);

      return true;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getFavoriteSongIds() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await supabase
          .from('favorite_songs')
          .select('song_id')
          .eq('user_id', userId)
          .order('liked_at', ascending: false);

      return (response as List)
          .map((item) => item['song_id'] as String)
          .toList();
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }
}