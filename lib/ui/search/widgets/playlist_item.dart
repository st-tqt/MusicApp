import 'package:flutter/material.dart';
import '../../../data/model/playlist.dart';

class PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistItem({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A0F2E).withOpacity(0.6),
            const Color(0xFF2D1B47).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBB6BD9).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildPlaylistImage(),
                const SizedBox(width: 14),
                _buildPlaylistInfo(),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistImage() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFBB6BD9), Color(0xFF00D9FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBB6BD9).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: playlist.image != null && playlist.image!.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          playlist.image!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.playlist_play,
              color: Colors.white,
              size: 32,
            );
          },
        ),
      )
          : const Icon(Icons.playlist_play, color: Colors.white, size: 32),
    );
  }

  Widget _buildPlaylistInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            playlist.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  playlist.userName ?? 'Người dùng ẩn danh',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}