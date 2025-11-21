import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../data/model/playlist.dart';
import '../../../../data/model/song.dart';
import '../../../playlist/playlist_detail_page.dart';

class PlaylistListSection extends StatelessWidget {
  final List<Playlist> playlists;
  final bool isLoading;
  final String? errorMessage;
  final Function(String) getCachedPlaylistSongs;
  final VoidCallback onRetry;
  final Function(Song, List<Song>)? onSongPlay;

  const PlaylistListSection({
    super.key,
    required this.playlists,
    required this.isLoading,
    required this.errorMessage,
    required this.getCachedPlaylistSongs,
    required this.onRetry,
    this.onSongPlay,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildHeader(),
        if (errorMessage != null) _buildErrorState(),
        if (isLoading) _buildLoadingState(),
        if (!isLoading && errorMessage == null && playlists.isEmpty)
          _buildEmptyState(),
        if (!isLoading && errorMessage == null && playlists.isNotEmpty)
          _buildPlaylistsList(context),
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Text(
        'Playlists',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A0F2E).withOpacity(0.5),
                    const Color(0xFF2D1B47).withOpacity(0.3),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFBB6BD9).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              errorMessage ?? 'Đã có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A0F2E).withOpacity(0.5),
                    const Color(0xFF2D1B47).withOpacity(0.3),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFBB6BD9).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.playlist_play_rounded,
                size: 64,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Không có playlist công khai',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tạo và chia sẻ playlist đầu tiên',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: playlists.map((playlist) {
          return FutureBuilder<List<Song>>(
            future: getCachedPlaylistSongs(playlist.id) as Future<List<Song>>,
            builder: (context, snapshot) {
              String? firstSongImage;
              int songCount = 0;

              if (snapshot.hasData) {
                songCount = snapshot.data!.length;
                if (snapshot.data!.isNotEmpty) {
                  firstSongImage = snapshot.data!.first.image;
                }
              }

              return _buildPlaylistItem(
                context,
                playlist,
                firstSongImage,
                songCount,
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlaylistItem(
      BuildContext context,
      Playlist playlist,
      String? firstSongImage,
      int songCount,
      ) {
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
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => PlaylistDetailPage(
                  playlist: playlist,
                  onSongPlay: onSongPlay,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildPlaylistImage(firstSongImage),
                const SizedBox(width: 14),
                _buildPlaylistInfo(playlist, songCount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistImage(String? firstSongImage) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: firstSongImage == null
            ? LinearGradient(
          colors: [
            const Color(0xFFBB6BD9).withOpacity(0.3),
            const Color(0xFF00D9FF).withOpacity(0.2),
          ],
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBB6BD9).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: firstSongImage != null && firstSongImage.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          firstSongImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.playlist_play,
              color: Color(0xFFBB6BD9),
              size: 32,
            );
          },
        ),
      )
          : const Icon(Icons.playlist_play, color: Color(0xFFBB6BD9), size: 32),
    );
  }

  Widget _buildPlaylistInfo(Playlist playlist, int songCount) {
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
          Text(
            '$songCount bài hát',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}