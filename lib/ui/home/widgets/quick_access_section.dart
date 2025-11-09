import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/model/song.dart';
import '../../favorite/favorite_detail_page.dart';
import '../../now_playing/playing.dart';

class QuickAccessSection extends StatelessWidget {
  final List<Song> songs;
  final Function(Song, List<Song>)? onSongPlay;

  const QuickAccessSection({super.key, required this.songs, this.onSongPlay});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': Icons.favorite,
        'label': 'Yêu thích',
        'gradient': [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
        'index': 0,
      },
      {
        'icon': Icons.history,
        'label': 'Gần đây',
        'gradient': [Color(0xFFBB6BD9), Color(0xFFD98FFF)],
        'index': 1,
      },
      {
        'icon': Icons.trending_up,
        'label': 'Thịnh hành',
        'gradient': [Color(0xFF00D9FF), Color(0xFF4DE8FF)],
        'index': 2,
      },
      {
        'icon': Icons.shuffle,
        'label': 'Ngẫu nhiên',
        'gradient': [Color(0xFFFF9D6B), Color(0xFFFFBB8F)],
        'index': 3,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Truy cập nhanh',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () =>
                      _handleCategoryTap(context, category['index'] as int),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: category['gradient'] as List<Color>,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (category['gradient'] as List<Color>)[0]
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleCategoryTap(BuildContext context, int index) {
    if (index == 0) {
      // Yêu thích
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => FavoriteDetailPage(onSongPlay: onSongPlay),
        ),
      );
    } else if (index == 3 && songs.isNotEmpty) {
      // Ngẫu nhiên
      final shuffled = List<Song>.from(songs)..shuffle();
      onSongPlay?.call(shuffled[0], shuffled);
      Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
          builder: (context) =>
              NowPlaying(songs: shuffled, playingSong: shuffled[0]),
        ),
      );
    }
  }
}
