class Song {
  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
    required this.counter,
  });

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      album: map['album'] as String? ?? '',
      artist: map['artist'] as String? ?? '',
      source: map['source'] as String,
      image: map['image'] as String? ?? '',
      duration: map['duration'] as int? ?? 0,
      counter: map['counter'] as int? ?? 0,
    );
  }

  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  int counter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, '
        'source: $source, image: $image, duration: $duration, counter: $counter}';
  }
}
