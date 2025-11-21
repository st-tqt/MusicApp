import '../model/follower.dart';
import '../source/follower_source.dart';

class FollowerRepository {
  final FollowerSource _source = FollowerSource();

  Future<Follower?> followUser(String userId) async {
    return await _source.followUser(userId);
  }

  Future<bool> unfollowUser(String userId) async {
    return await _source.unfollowUser(userId);
  }

  Future<bool> isFollowing(String userId) async {
    return await _source.isFollowing(userId);
  }

  Future<int> getFollowersCount(String userId) async {
    return await _source.getFollowersCount(userId);
  }

  Future<int> getFollowingCount(String userId) async {
    return await _source.getFollowingCount(userId);
  }

  Future<FollowerStats> getFollowerStats(String userId) async {
    return await _source.getFollowerStats(userId);
  }

  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    return await _source.getFollowers(userId);
  }

  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    return await _source.getFollowing(userId);
  }
}