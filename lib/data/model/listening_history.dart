class ListeningHistory {
  ListeningHistory({
    required this.userId,
    required this.songId,
    required this.listenedAt,
  });

  factory ListeningHistory.fromMap(Map<String, dynamic> map) {
    return ListeningHistory(
      userId: map['user_id'] as String,
      songId: map['song_id'] as String,
      listenedAt: DateTime.parse(map['listened_at'] as String),
    );
  }

  String userId;
  String songId;
  DateTime listenedAt;

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'song_id': songId,
      'listened_at': listenedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ListeningHistory{userId: $userId, songId: $songId, listenedAt: $listenedAt}';
  }
}