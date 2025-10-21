import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/listening_history.dart';

abstract class ListeningHistoryDataSource {
  Future<bool> addListeningHistory(String songId);
  Future<List<ListeningHistory>?> getListeningHistoryRecords();
  Future<bool> clearOldHistory();
}

class ListeningHistoryDataSourceImpl implements ListeningHistoryDataSource {
  final _supabase = Supabase.instance.client;
  static const int MAX_HISTORY = 20;

  @override
  Future<bool> addListeningHistory(String songId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) return false;

      final now = DateTime.now();

      // Kiểm tra xem bài hát đã tồn tại trong lịch sử chưa
      final existingRecord = await _supabase
          .from('listening_history')
          .select('id')
          .eq('user_id', userId)
          .eq('song_id', songId)
          .maybeSingle();

      if (existingRecord != null) {
        // Nếu đã tồn tại, chỉ cập nhật thời gian nghe
        await _supabase
            .from('listening_history')
            .update({'listened_at': now.toIso8601String()})
            .eq('id', existingRecord['id']);
      } else {
        // Nếu chưa tồn tại, tạo mới
        await _supabase
            .from('listening_history')
            .insert({
          'user_id': userId,
          'song_id': songId,
          'listened_at': now.toIso8601String(),
        });

        // Chỉ xóa bài cũ khi thêm bài mới (không xóa khi cập nhật)
        await clearOldHistory();
      }

      return true;
    } catch (e) {
      print('[ListeningHistory] Error adding listening history: $e');
      return false;
    }
  }

  @override
  Future<bool> clearOldHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Lấy tất cả lịch sử của user, sắp xếp theo thời gian mới nhất
      final response = await _supabase
          .from('listening_history')
          .select('id, listened_at')
          .eq('user_id', userId)
          .order('listened_at', ascending: false);

      final List<dynamic> histories = response as List<dynamic>;

      // Nếu có nhiều hơn 20 bài, xóa những bài cũ
      if (histories.length > MAX_HISTORY) {
        final idsToDelete = histories
            .skip(MAX_HISTORY)
            .map((item) => item['id'] as String)
            .toList();

        await _supabase
            .from('listening_history')
            .delete()
            .inFilter('id', idsToDelete);
      }

      return true;
    } catch (e) {
      print('[ListeningHistory] Error clearing old history: $e');
      return false;
    }
  }

  @override
  Future<List<ListeningHistory>?> getListeningHistoryRecords() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) return null;

      final response = await _supabase
          .from('listening_history')
          .select('id, user_id, song_id, listened_at')
          .eq('user_id', userId)
          .order('listened_at', ascending: false)
          .limit(MAX_HISTORY);

      final List<dynamic> data = response as List<dynamic>;

      final List<ListeningHistory> histories = data
          .map((item) => ListeningHistory.fromMap(item as Map<String, dynamic>))
          .toList();

      return histories;
    } catch (e) {
      print('[ListeningHistory] Error getting listening history: $e');
      return null;
    }
  }
}