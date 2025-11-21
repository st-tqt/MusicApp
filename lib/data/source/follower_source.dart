import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/follower.dart';

class FollowerSource {
  final SupabaseClient _client = Supabase.instance.client;

  // Follow user
  Future<Follower?> followUser(String followingId) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      if (currentUserId == followingId) {
        throw Exception('Cannot follow yourself');
      }

      final response = await _client
          .from('followers')
          .insert({
        'follower_id': currentUserId,
        'following_id': followingId,
      })
          .select()
          .single();

      return Follower.fromJson(response);
    } catch (e) {
      print('Error following user: $e');
      return null;
    }
  }

  // Unfollow user
  Future<bool> unfollowUser(String followingId) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from('followers')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', followingId);

      return true;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  // Check if current user is following another user
  Future<bool> isFollowing(String userId) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) return false;

      final response = await _client
          .from('followers')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  // Get followers count
  Future<int> getFollowersCount(String userId) async {
    try {
      final response = await _client
          .from('followers')
          .select()
          .eq('following_id', userId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print('Error getting followers count: $e');
      return 0;
    }
  }

  // Get following count
  Future<int> getFollowingCount(String userId) async {
    try {
      final response = await _client
          .from('followers')
          .select()
          .eq('follower_id', userId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print('Error getting following count: $e');
      return 0;
    }
  }

  // Get follower stats (all in one call)
  Future<FollowerStats> getFollowerStats(String userId) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;

      // Get followers count
      final followersResponse = await _client
          .from('followers')
          .select()
          .eq('following_id', userId)
          .count(CountOption.exact);

      // Get following count
      final followingResponse = await _client
          .from('followers')
          .select()
          .eq('follower_id', userId)
          .count(CountOption.exact);

      // Check if current user is following
      bool isFollowing = false;
      if (currentUserId != null && currentUserId != userId) {
        final followResponse = await _client
            .from('followers')
            .select('id')
            .eq('follower_id', currentUserId)
            .eq('following_id', userId)
            .maybeSingle();

        isFollowing = followResponse != null;
      }

      return FollowerStats(
        followersCount: followersResponse.count,
        followingCount: followingResponse.count,
        isFollowing: isFollowing,
      );
    } catch (e) {
      print('Error getting follower stats: $e');
      return FollowerStats(
        followersCount: 0,
        followingCount: 0,
        isFollowing: false,
      );
    }
  }

  // Get list of followers (only follower IDs)
  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      final response = await _client
          .from('followers')
          .select('*')
          .eq('following_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting followers list: $e');
      return [];
    }
  }

  // Get list of following (only following IDs)
  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      final response = await _client
          .from('followers')
          .select('*')
          .eq('follower_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting following list: $e');
      return [];
    }
  }
}