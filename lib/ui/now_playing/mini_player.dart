import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'dart:async';
import '../../data/repository/favorite_repository.dart';
import '../../data/repository/listening_history_repository.dart';
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
  final _historyRepository = DefaultListeningHistoryRepository();
  bool _isFavorite = false;

  //StreamSubscription để lắng nghe thay đổi bài hát
  StreamSubscription<Song>? _songChangedSubscription;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();

    //Lắng nghe stream từ AudioPlayerManager
    _songChangedSubscription = audioManager.songChangedStream.listen((song) {
      if (mounted) {
        widget.onSongChanged?.call(song);
      }
    });
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
    //Hủy subscription khi dispose
    _songChangedSubscription?.cancel();
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

      _historyRepository.addToHistory(nextSong.id);

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

      _historyRepository.addToHistory(prevSong.id);

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
          color: const Color(0xFF2A2139),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
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
                          // Sử dụng AnimatedSwitcher để tránh lỗi khi đổi bài
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: SizedBox(
                              key: ValueKey(widget.currentSong.id),
                              height: 17,
                              child: _buildScrollingTitle(),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.currentSong.artist,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
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
                      color: _isFavorite
                          ? const Color(0xFF9B4DE0)
                          : Colors.white,
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
                        backgroundColor: const Color(0xFF3D3153),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF9B4DE0),
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

  Widget _buildScrollingTitle() {
    // Tạo TextPainter để đo kích thước văn bản
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.currentSong.title,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    const containerWidth = 100.0; // Chiều rộng container
    final textWidth = textPainter.size.width;

    // Nếu văn bản ngắn hơn hoặc bằng chiều rộng container, nếu không dùng Marquee
    if (textWidth <= containerWidth) {
      return Text(
        widget.currentSong.title,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Marquee(
      text: widget.currentSong.title,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
        decoration: TextDecoration.none,
      ),
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      blankSpace: 40.0,
      velocity: 25.0,
      pauseAfterRound: const Duration(seconds: 1),
      // startPadding: 10.0,
      accelerationDuration: const Duration(milliseconds: 500),
      accelerationCurve: Curves.linear,
    );
  }
}
