import 'package:flutter/material.dart';
import '../../../data/model/song.dart';
import 'trending_item.dart';

class TrendingSection extends StatelessWidget {
  final List<Song> trendingSongs;
  final bool isLoading;
  final List<Song> allSongs;
  final Function(Song, List<Song>)? onSongPlay;
  final Function(Song) onMorePressed;

  const TrendingSection({
    super.key,
    required this.trendingSongs,
    required this.isLoading,
    required this.allSongs,
    this.onSongPlay,
    required this.onMorePressed,
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
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFFF6B9D),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bảng xếp hạng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B9D),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trendingSongs.length,
                itemBuilder: (context, index) {
                  final song = trendingSongs[index];
                  return TrendingItem(
                    song: song,
                    rank: index + 1,
                    allSongs: allSongs,
                    onSongPlay: onSongPlay,
                    onMorePressed: () => onMorePressed(song),
                  );
                },
              ),
      ],
    );
  }
}
