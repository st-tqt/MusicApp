import 'package:flutter/material.dart';
import '../../../data/model/song.dart';
import 'album_card.dart';

class RecentlyPlayedSection extends StatelessWidget {
  final List<Song> recentSongs;
  final bool isLoading;
  final List<Song> allSongs;
  final Function(Song, List<Song>)? onSongPlay;

  const RecentlyPlayedSection({
    super.key,
    required this.recentSongs,
    required this.isLoading,
    required this.allSongs,
    this.onSongPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nghe gần đây',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(color: Color(0xFFBB6BD9)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        isLoading
            ? const SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B9D),
                    ),
                  ),
                ),
              )
            : recentSongs.isEmpty
            ? SizedBox(
                height: 180,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có lịch sử nghe nhạc',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: recentSongs.take(10).length,
                  itemBuilder: (context, index) {
                    final song = recentSongs[index];
                    return AlbumCard(
                      song: song,
                      allSongs: allSongs,
                      onSongPlay: onSongPlay,
                    );
                  },
                ),
              ),
      ],
    );
  }
}
