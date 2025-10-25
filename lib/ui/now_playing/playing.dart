import 'dart:math';
import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import '../../data/repository/repository.dart';
import '../../data/repository/favorite_repository.dart';
import '../../data/repository/listening_history_repository.dart';
import '../playlist/add_to_playlist_dialog.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(songs: songs, playingSong: playingSong);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  late double _currentAnimationPosotion;
  bool _isShuffle = false;
  late LoopMode _loopMode;

  final _favoriteRepository = DefaultFavoriteRepository();
  final _repository = DefaultRepository();
  final _listeningHistoryRepository = DefaultListeningHistoryRepository();
  String? _lastHistorySongId;

  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  String? _countedSongId;

  // THÊM: StreamSubscription để lắng nghe thay đổi bài hát
  StreamSubscription<Song>? _songChangedSubscription;

  @override
  void initState() {
    super.initState();

    _currentAnimationPosotion = 0.0;
    _song = widget.playingSong;
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );

    _audioPlayerManager = AudioPlayerManager();

    final currentUrl = _audioPlayerManager.songUrl;
    final newUrl = _song.source;

    if (currentUrl.isEmpty) {
      // TRƯỜNG HỢP 1: Chưa có bài nào (lần đầu mở app)
      _audioPlayerManager.updateSongUrl(newUrl);
      _audioPlayerManager.prepare(isNewSong: true);

    } else if (currentUrl != newUrl) {
      // TRƯỜNG HỢP 2: Đang phát bài KHÁC → Chuyển sang bài mới
      _audioPlayerManager.player.stop();
      _audioPlayerManager.updateSongUrl(newUrl);
      _audioPlayerManager.prepare(isNewSong: true);

    } else {
      // TRƯỜNG HỢP 3: Đang phát ĐÚNG BÀI NÀY → Giữ nguyên, chỉ setup lại UI
      _audioPlayerManager.prepare(isNewSong: false);

      // Sync lại animation với trạng thái player
      if (_audioPlayerManager.player.playing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _playRotationAnimation();
        });
      }
    }

    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _loopMode = _audioPlayerManager.loopMode;

    _checkFavoriteStatus();
    _incrementSongCounter(_song.id);
    _addToListeningHistory(_song.id);

    _audioPlayerManager.setPlaylist(widget.songs, _selectedItemIndex);
    // Cancel subscription cũ nếu có
    _songChangedSubscription?.cancel();

    // THAY ĐỔI: Lắng nghe stream thay vì set callback
    _songChangedSubscription = _audioPlayerManager.songChangedStream.listen((song) {
      if (mounted) {
        setState(() {
          _song = song;
          _selectedItemIndex = widget.songs.indexOf(song);
          _checkFavoriteStatus();
          _incrementSongCounter(song.id);
          _addToListeningHistory(song.id);

          _stopRotationAnimation();
          _resetRotationAnimation();
        });
      }
    });
  }

  Future<void> _addToListeningHistory(String songId) async {
    if (_lastHistorySongId == songId) return;
    _lastHistorySongId = songId;

    try {
      await _listeningHistoryRepository.addToHistory(songId);
    } catch (e) {
      print('Error adding to listening history: $e');
    }
  }

  Future<void> _incrementSongCounter(String songId) async {
    if (_countedSongId == songId) return;

    _countedSongId = songId;
    await _repository.incrementCounter(songId);
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoriteRepository.isFavorite(_song.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;

    setState(() {
      _isLoadingFavorite = true;
    });

    final success = await _favoriteRepository.toggleFavorite(_song.id);

    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
        _isLoadingFavorite = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2A2139),
            content: Text(
              _isFavorite ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích',
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      setState(() {
        _isLoadingFavorite = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF2A2139),
            content: Text(
              'Có lỗi xảy ra, vui lòng thử lại',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF170F23),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF170F23),
        middle: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.white),
        ),
        trailing: IconButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF2A2139),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.playlist_add, color: Colors.white,),
                      title: Text(
                        'Add to Playlist',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        showAddToPlaylistDialog(context, _song);
                      },
                    ),
                    // ... các option khác
                  ],
                ),
            );
          },
          icon: const Icon(Icons.more_horiz, color: Colors.white),
        ),
        border: null,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF170F23),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _song.album,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text('_ ___ _', style: TextStyle(color: Colors.white30)),
              const SizedBox(height: 48),
              RotationTransition(
                turns: Tween(
                  begin: 0.0,
                  end: 1.0,
                ).animate(_imageAnimationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/itunes1.png',
                    image: _song.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, strackTrace) {
                      return Image.asset(
                        'assets/itunes1.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ),

              Padding(
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
                            _song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _song.artist,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      IconButton(
                        onPressed: _isLoadingFavorite ? null : _toggleFavorite,
                        icon: _isLoadingFavorite
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF9B4DE0),
                          ),
                        )
                            : Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_outline,
                        ),
                        color: _isFavorite
                            ? const Color(0xFF9B4DE0)
                            : Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: _progressBar(),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: _mediaButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // THÊM: Hủy subscription
    _songChangedSubscription?.cancel();
    _imageAnimationController.dispose();
    super.dispose();
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
            function: _setShuffle,
            icon: Icons.shuffle,
            color: _getShuffleColor(),
            size: 24,
          ),
          MediaButtonControl(
            function: _setPrevSong,
            icon: Icons.skip_previous,
            color: Colors.white,
            size: 36,
          ),
          _playButton(),
          MediaButtonControl(
            function: _setNextSong,
            icon: Icons.skip_next,
            color: Colors.white,
            size: 36,
          ),
          MediaButtonControl(
            function: _setupRepeatOption,
            icon: _repeatingIcon(),
            color: _getRepeatingIconColor(),
            size: 24,
          ),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          total: total,
          buffered: buffered,
          onSeek: _audioPlayerManager.player.seek,
          barHeight: 5.0,
          barCapShape: BarCapShape.round,
          baseBarColor: const Color(0xFF3D3153),
          progressBarColor: const Color(0xFF9B4DE0),
          bufferedBarColor: const Color(0xFF3D3153),
          thumbColor: const Color(0xFF9B4DE0),
          thumbGlowColor: const Color(0xFF9B4DE0).withOpacity(0.3),
          thumbRadius: 10.0,
          timeLabelTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          _pauseRotationAnimation();
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(color: Color(0xFF9B4DE0)),
          );
        } else if (playing != true) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.play();
              _imageAnimationController.forward(
                from: _currentAnimationPosotion,
              );
              _imageAnimationController.repeat();
            },
            icon: Icons.play_arrow,
            color: Colors.white,
            size: 48,
          );
        } else if (processingState != ProcessingState.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _playRotationAnimation();
          });
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
              _pauseRotationAnimation();
            },
            icon: Icons.pause,
            color: Colors.white,
            size: 48,
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _playRotationAnimation();
          });
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
              _pauseRotationAnimation();
            },
            icon: Icons.replay,
            color: Colors.white,
            size: 48,
          );
        }
      },
    );
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
      _audioPlayerManager.setShuffle(_isShuffle);
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? const Color(0xFF9B4DE0) : Colors.white60;
  }

  void _setNextSong() {
    if (widget.songs.isEmpty) return;

    setState(() {
      int newIndex;
      if (_isShuffle) {
        var random = Random();
        do {
          newIndex = random.nextInt(widget.songs.length);
        } while (newIndex == _selectedItemIndex && widget.songs.length > 1);
      } else {
        if (_selectedItemIndex < widget.songs.length - 1) {
          newIndex = _selectedItemIndex + 1;
        } else if (_loopMode == LoopMode.all &&
            _selectedItemIndex == widget.songs.length - 1) {
          newIndex = 0;
        } else {
          return;
        }
      }

      _selectedItemIndex = newIndex;
      _audioPlayerManager.updateCurrentIndex(newIndex);
      _song = widget.songs[_selectedItemIndex];
      _audioPlayerManager.updateSongUrl(_song.source);

      _audioPlayerManager.notifySongChanged(_song);

      _incrementSongCounter(_song.id);
      _checkFavoriteStatus();
      _addToListeningHistory(_song.id);

      _stopRotationAnimation();
      _resetRotationAnimation();
    });
  }

  void _setPrevSong() {
    if (widget.songs.isEmpty) return;

    setState(() {
      int newIndex;
      if (_isShuffle) {
        var random = Random();
        do {
          newIndex = random.nextInt(widget.songs.length);
        } while (newIndex == _selectedItemIndex && widget.songs.length > 1);
      } else {
        if (_loopMode == LoopMode.all && _selectedItemIndex == 0) {
          newIndex = widget.songs.length - 1;
        } else if (_selectedItemIndex > 0) {
          newIndex = _selectedItemIndex - 1;
        } else {
          return;
        }
      }

      _selectedItemIndex = newIndex;
      _audioPlayerManager.updateCurrentIndex(newIndex);
      _song = widget.songs[_selectedItemIndex];
      _audioPlayerManager.updateSongUrl(_song.source);

      _audioPlayerManager.notifySongChanged(_song);

      _incrementSongCounter(_song.id);
      _checkFavoriteStatus();
      _addToListeningHistory(_song.id);

      _stopRotationAnimation();
      _resetRotationAnimation();
    });
  }

  void _setupRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.setLoopMode(_loopMode);
    });
  }

  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  Color? _getRepeatingIconColor() {
    return _loopMode == LoopMode.off ? Colors.white60 : const Color(0xFF9B4DE0);
  }

  void _playRotationAnimation() {
    _imageAnimationController.forward(from: _currentAnimationPosotion);
    _imageAnimationController.repeat();
  }

  void _pauseRotationAnimation() {
    _stopRotationAnimation();
    _currentAnimationPosotion = _imageAnimationController.value;
  }

  void _stopRotationAnimation() {
    _imageAnimationController.stop();
  }

  void _resetRotationAnimation() {
    _currentAnimationPosotion = 0.0;
    _imageAnimationController.value = _currentAnimationPosotion;
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final Color? color;
  final double? size;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Colors.white,
    );
  }
}