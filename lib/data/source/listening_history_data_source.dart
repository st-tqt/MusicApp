import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/listening_history.dart';

class ListeningHistoryDataSource {
  final supabase = Supabase.instance.client;

  /// Lấy lịch sử nghe nhạc của user
  Future<List<ListeningHistory>> getHistory(String userId) async {
    final response = await supabase
        .from('listening_history')
        .select()
        .eq('user_id', userId)
        .order('listened_at', ascending: false);

    return (response as List)
        .map((e) => ListeningHistory.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Ghi lại lịch sử nghe nhạc
  Future<void> addHistory(String userId, String songId) async {
    await supabase.from('listening_history').insert({
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // text id
      'user_id': userId,
      'song_id': songId,
    });
  }

  /// Xóa lịch sử nghe
  Future<void> clearHistory(String userId) async {
    await supabase.from('listening_history').delete().eq('user_id', userId);
  }
}
