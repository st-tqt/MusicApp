class FavoriteSong {
  FavoriteSong({
    required this.userId,
    required this.songId,
    required this.likedAt,
  });

  factory FavoriteSong.fromMap(Map<String, dynamic> map) {
    return FavoriteSong(
      userId: map['user_id'] as String,
      songId: map['song_id'] as String,
      likedAt: DateTime.parse(map['liked_at']),
    );
  }

  String userId;
  String songId;
  DateTime likedAt;

  @override
  String toString() {
    return 'FavoriteSong{userId: $userId, songId: $songId, likedAt: $likedAt}';
  }
}
