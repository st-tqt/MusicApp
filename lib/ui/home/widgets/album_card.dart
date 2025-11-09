import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/model/song.dart';
import '../../now_playing/playing.dart';

class AlbumCard extends StatelessWidget {
  final Song song;
  final List<Song> allSongs;
  final Function(Song, List<Song>)? onSongPlay;

  const AlbumCard({
    super.key,
    required this.song,
    required this.allSongs,
    this.onSongPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          onSongPlay?.call(song, allSongs);
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => NowPlaying(
                songs: allSongs,
                playingSong: song,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBB6BD9).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/itunes1.png',
                  image: song.image,
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/itunes1.png',
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}