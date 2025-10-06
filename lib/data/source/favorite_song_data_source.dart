import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/favorite_song.dart';

class FavoriteSongDataSource {
  final supabase = Supabase.instance.client;

  /// Lấy danh sách bài hát user đã thích
  Future<List<FavoriteSong>> getFavorites(String userId) async {
    final response = await supabase
        .from('favorite_songs')
        .select()
        .eq('user_id', userId);

    return (response as List)
        .map((e) => FavoriteSong.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Thêm bài hát vào favorites
  Future<void> addFavorite(String userId, String songId) async {
    await supabase.from('favorite_songs').insert({
      'user_id': userId,
      'song_id': songId,
    });
  }

  /// Bỏ thích bài hát
  Future<void> removeFavorite(String userId, String songId) async {
    await supabase
        .from('favorite_songs')
        .delete()
        .eq('user_id', userId)
        .eq('song_id', songId);
  }
}
