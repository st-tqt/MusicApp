import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import '../../data/model/song.dart';
import '../now_playing/playing.dart';
import '../playlist/add_to_playlist_dialog.dart';
import 'widgets/recommended_section.dart';
import 'widgets/quick_access_section.dart';
import 'widgets/recently_played_section.dart';
import 'widgets/trending_section.dart';

class HomeTab extends StatelessWidget {
  final Function(Song, List<Song>)? onSongPlay;

  const HomeTab({super.key, this.onSongPlay});

  @override
  Widget build(BuildContext context) {
    return HomeTabPage(onSongPlay: onSongPlay);
  }
}

class HomeTabPage extends StatefulWidget {
  final Function(Song, List<Song>)? onSongPlay;

  const HomeTabPage({super.key, this.onSongPlay});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  List<Song> recommendedSongs = [];
  List<Song> recentSongs = [];
  List<Song> trendingSongs = [];
  late MusicAppViewModel _viewModel;
  bool isLoadingRecommended = true;
  bool isLoadingRecent = true;
  bool isLoadingTrending = true;

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    _viewModel.loadRecommendedSongs();
    _viewModel.loadTrendingSongs();
    _viewModel.loadRecentSongs();
    observeData();
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0A0118),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0118),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: SafeArea(child: getBody()),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return RefreshIndicator(
        color: const Color(0xFFFF6B9D),
        backgroundColor: const Color(0xFF1A0F2E),
        onRefresh: _handleRefresh,
        displacement: 40,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: const Color(0xFF0A0118),
              elevation: 0,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFF6B9D),
                      Color(0xFFBB6BD9),
                      Color(0xFF00D9FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Music App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecommendedSection(
                    recommendedSongs: recommendedSongs,
                    isLoading: isLoadingRecommended,
                    onPlayAll: _playAllRecommended,
                    onRefresh: _reloadRecommendedSongs,
                    onSongTap: _onRecommendedSongTap,
                    onMorePressed: showBottomSheet,
                  ),
                  const SizedBox(height: 32),
                  QuickAccessSection(
                    songs: songs,
                    onSongPlay: widget.onSongPlay,
                  ),
                  const SizedBox(height: 32),
                  RecentlyPlayedSection(
                    recentSongs: recentSongs,
                    isLoading: isLoadingRecent,
                    allSongs: songs,
                    onSongPlay: widget.onSongPlay,
                  ),
                  const SizedBox(height: 32),
                  TrendingSection(
                    trendingSongs: trendingSongs,
                    isLoading: isLoadingTrending,
                    allSongs: songs,
                    onSongPlay: widget.onSongPlay,
                    onMorePressed: showBottomSheet,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isLoadingRecommended = true;
      isLoadingRecent = true;
      isLoadingTrending = true;
    });

    await Future.wait([
      _viewModel.loadSongs(),
      _viewModel.loadRecommendedSongs(),
      _viewModel.loadTrendingSongs(),
      _viewModel.loadRecentSongs(),
    ]);

    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _playAllRecommended() {
    if (recommendedSongs.isNotEmpty) {
      widget.onSongPlay?.call(
        recommendedSongs[0],
        recommendedSongs,
      );
      Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
          builder: (context) => NowPlaying(
            songs: recommendedSongs,
            playingSong: recommendedSongs[0],
          ),
        ),
      );
    }
  }

  void _reloadRecommendedSongs() {
    setState(() {
      isLoadingRecommended = true;
    });
    _viewModel.loadRecommendedSongs();
  }

  void _onRecommendedSongTap(Song song) {
    widget.onSongPlay?.call(song, recommendedSongs);
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) =>
            NowPlaying(songs: recommendedSongs, playingSong: song),
      ),
    );
  }

  Widget getProgressBar() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
      ),
    );
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });

    _viewModel.recommendedStream.stream.listen((songList) {
      setState(() {
        recommendedSongs = songList;
        isLoadingRecommended = false;
      });
    });

    _viewModel.trendingStream.stream.listen((songList) {
      setState(() {
        trendingSongs = songList;
        isLoadingTrending = false;
      });
    });

    _viewModel.recentStream.stream.listen((songList) {
      setState(() {
        recentSongs = songList;
        isLoadingRecent = false;
      });
    });
  }

  void showBottomSheet(Song song) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF1A0F2E), const Color(0xFF0A0118)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: const Color(0xFFBB6BD9).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF6B9D), Color(0xFF00D9FF)],
                        ).createShader(bounds),
                        child: Icon(Icons.playlist_add, color: Colors.white),
                      ),
                      title: Text(
                        'Add to Playlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        showAddToPlaylistDialog(context, song);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}