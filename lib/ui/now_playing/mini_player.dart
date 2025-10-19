import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/repository/favorite_repository.dart';
import 'audio_player_manager.dart';
import '../../data/model/song.dart';

class MiniPlayer extends StatefulWidget {
  final Song currentSong;
  final VoidCallback onTap;
  final List<Song> allSongs;
  final Function(Song)? onSongChanged;

  const MiniPlayer({
    Key? key,
    required this.currentSong,
    required this.onTap,
    required this.allSongs,
    this.onSongChanged,
  }) : super(key: key);

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final audioManager = AudioPlayerManager();
  final _favoriteRepository = DefaultFavoriteRepository();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  @override
  void didUpdateWidget(MiniPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSong.id != widget.currentSong.id) {
      _checkFavoriteStatus();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoriteRepository.isFavorite(widget.currentSong.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final success = await _favoriteRepository.toggleFavorite(
      widget.currentSong.id,
    );
    if (success && mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  void _playNext() {
    final currentIndex = widget.allSongs.indexWhere(
          (song) => song.id == widget.currentSong.id,
    );

    if (currentIndex != -1 && currentIndex < widget.allSongs.length - 1) {
      final nextSong = widget.allSongs[currentIndex + 1];
      audioManager.updateSongUrl(nextSong.source);
      audioManager.updateCurrentIndex(currentIndex + 1);

      widget.onSongChanged?.call(nextSong);
    }
  }

  void _playPrev() {
    final currentIndex = widget.allSongs.indexWhere(
          (song) => song.id == widget.currentSong.id,
    );

    if (currentIndex > 0) {
      final prevSong = widget.allSongs[currentIndex - 1];
      audioManager.updateSongUrl(prevSong.source);
      audioManager.updateCurrentIndex(currentIndex - 1);

      widget.onSongChanged?.call(prevSong);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Album art
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        widget.currentSong.image,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Image.asset(
                          'assets/itunes1.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Song info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.currentSong.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.currentSong.artist,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Favorite button
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 24,
                      ),
                      color: _isFavorite ? Colors.red : Colors.white,
                      onPressed: _toggleFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    const SizedBox(width: 6),

                    // Previous button
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 28),
                      color: Colors.white,
                      onPressed: _playPrev,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    const SizedBox(width: 2),

                    // Play/Pause button
                    StreamBuilder<PlayerState>(
                      stream: audioManager.player.playerStateStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data?.playing ?? false;
                        return IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 28,
                          ),
                          color: Colors.white,
                          onPressed: () {
                            if (isPlaying) {
                              audioManager.player.pause();
                            } else {
                              audioManager.player.play();
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        );
                      },
                    ),

                    const SizedBox(width: 6),

                    // Next button
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 28),
                      color: Colors.white,
                      onPressed: _playNext,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    const SizedBox(width: 2),
                  ],
                ),
              ),
            ),

            // Progress bar ở dưới cùng
            StreamBuilder<Duration>(
              stream: audioManager.player.positionStream,
              builder: (context, positionSnapshot) {
                return StreamBuilder<Duration?>(
                  stream: audioManager.player.durationStream,
                  builder: (context, durationSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final duration = durationSnapshot.data ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;

                    return SizedBox(
                      height: 3,
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}