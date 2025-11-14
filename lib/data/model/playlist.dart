class Playlist {
  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.image,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      image: map['image'] as String?,
      isPublic: map['is_public'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),

      userName: map['profiles']?['name'] as String?,
      userAvatar: map['profiles']?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'image': image,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String id;
  String userId;
  String name;
  String? description;
  String? image;
  bool isPublic;
  DateTime createdAt;
  DateTime updatedAt;
  String? userName;
  String? userAvatar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist{id: $id, userId: $userId, name: $name, description: $description, '
        'image: $image, isPublic: $isPublic, userName: $userName, '
        'createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

class PlaylistSong {
  PlaylistSong({
    required this.id,
    required this.playlistId,
    required this.songId,
    required this.addedAt,
    this.position,
  });

  factory PlaylistSong.fromMap(Map<String, dynamic> map) {
    return PlaylistSong(
      id: map['id'] as String,
      playlistId: map['playlist_id'] as String,
      songId: map['song_id'] as String,
      addedAt: DateTime.parse(map['added_at'] as String),
      position: map['position'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playlist_id': playlistId,
      'song_id': songId,
      'added_at': addedAt.toIso8601String(),
      'position': position,
    };
  }

  String id;
  String playlistId;
  String songId;
  DateTime addedAt;
  int? position;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistSong &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}