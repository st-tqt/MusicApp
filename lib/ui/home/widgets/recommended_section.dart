import 'package:flutter/material.dart';
import '../../../data/model/song.dart';
import 'recommended_list_item.dart';

class RecommendedSection extends StatelessWidget {
  final List<Song> recommendedSongs;
  final bool isLoading;
  final VoidCallback onPlayAll;
  final VoidCallback onRefresh;
  final Function(Song) onSongTap;
  final Function(Song) onMorePressed;

  const RecommendedSection({
    super.key,
    required this.recommendedSongs,
    required this.isLoading,
    required this.onPlayAll,
    required this.onRefresh,
    required this.onSongTap,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0118),
            const Color(0xFF1A0F2E).withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                    ).createShader(bounds),
                    child: const Text(
                      'Gợi ý cho bạn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: onPlayAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B9D).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Phát',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: onRefresh,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A0F2E), Color(0xFF2D1B47)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFBB6BD9).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isLoading
              ? const SizedBox(
                  height: 280,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF6B9D),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 285,
                  child: PageView.builder(
                    padEnds: false,
                    controller: PageController(viewportFraction: 0.92),
                    itemCount: (recommendedSongs.length / 3).ceil(),
                    itemBuilder: (context, pageIndex) {
                      int startIndex = pageIndex * 3;
                      int endIndex = (startIndex + 3).clamp(
                        0,
                        recommendedSongs.length,
                      );
                      List<Song> pageSongs = recommendedSongs.sublist(
                        startIndex,
                        endIndex,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: pageSongs
                              .map(
                                (song) => RecommendedListItem(
                                  song: song,
                                  onTap: () => onSongTap(song),
                                  onMorePressed: () => onMorePressed(song),
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
