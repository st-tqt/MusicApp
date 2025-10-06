class ListeningHistory {
  ListeningHistory({
    required this.id,
    required this.userId,
    required this.songId,
    required this.listenedAt,
  });

  factory ListeningHistory.fromMap(Map<String, dynamic> map) {
    return ListeningHistory(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      songId: map['song_id'] as String,
      listenedAt: DateTime.parse(map['listened_at']),
    );
  }

  String id;      
  String userId;
  String songId;
  DateTime listenedAt;

  @override
  String toString() {
    return 'ListeningHistory{id: $id, userId: $userId, songId: $songId, listenedAt: $listenedAt}';
  }
}
