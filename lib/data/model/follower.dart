class Follower {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  Follower({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory Follower.fromJson(Map<String, dynamic> map) {
    return Follower(
      id: map['id'] as String,
      followerId: map['follower_id'] as String,
      followingId: map['following_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class FollowerStats {
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  FollowerStats({
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
  });
}