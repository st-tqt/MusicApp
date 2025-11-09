import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/model/song.dart';
import '../../now_playing/playing.dart';

class TrendingItem extends StatelessWidget {
  final Song song;
  final int rank;
  final List<Song> allSongs;
  final Function(Song, List<Song>)? onSongPlay;
  final VoidCallback onMorePressed;

  const TrendingItem({
    super.key,
    required this.song,
    required this.rank,
    required this.allSongs,
    this.onSongPlay,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSongPlay?.call(song, allSongs);
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (context) =>
                NowPlaying(songs: allSongs, playingSong: song),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF1A0F2E).withOpacity(0.4),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2D1B47).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: rank <= 3
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                      )
                    : null,
                color: rank > 3 ? const Color(0xFF2D1B47) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/itunes1.png',
                image: song.image,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/itunes1.png',
                    width: 48,
                    height: 48,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.7)),
              onPressed: onMorePressed,
            ),
          ],
        ),
      ),
    );
  }
}
