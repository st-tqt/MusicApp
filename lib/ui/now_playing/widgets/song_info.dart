import 'package:flutter/material.dart';
import '../../../data/model/song.dart';

class SongInfo extends StatelessWidget {
  final Song song;
  final bool isFavorite;
  final bool isLoadingFavorite;
  final VoidCallback onToggleFavorite;

  const SongInfo({
    super.key,
    required this.song,
    required this.isFavorite,
    required this.isLoadingFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64, bottom: 16),
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined),
              color: Colors.white,
            ),
            Column(
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  song.artist,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
            IconButton(
              onPressed: isLoadingFavorite ? null : onToggleFavorite,
              icon: isLoadingFavorite
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF9B4DE0),
                      ),
                    )
                  : Icon(isFavorite ? Icons.favorite : Icons.favorite_outline),
              color: isFavorite ? const Color(0xFF9B4DE0) : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
