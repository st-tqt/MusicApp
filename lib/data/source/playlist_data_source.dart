import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/playlist.dart';

class PlaylistDataSource {
  final supabase = Supabase.instance.client;

  Future<List<Playlist>> getUserPlaylists(String userId) async {
    final response = await supabase
        .from('playlists')
        .select()
        .eq('user_id', userId);

    return (response as List)
        .map((item) => Playlist.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createPlaylist(String userId, String name) async {
    await supabase.from('playlists').insert({
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // text id
      'user_id': userId,
      'name': name,
    });
  }
}
