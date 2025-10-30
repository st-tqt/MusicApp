import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:music_app/ui/user/user.dart';

import '../../data/model/song.dart';
import '../../data/repository/listening_history_repository.dart';
import '../now_playing/mini_player.dart';
import '../now_playing/playing.dart';
import '../playlist/add_to_playlist_dialog.dart';
import '../playlist/playlist_page.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicApp',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0118),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFF6B9D),
          secondary: const Color(0xFF00D9FF),
          surface: const Color(0xFF1A0F2E),
          background: const Color(0xFF0A0118),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0118),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF1A0F2E),
        dividerColor: const Color(0xFF2D1B47),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  int _currentTabIndex = 0;

  late List<Widget> _tabs;

  final _audioManager = AudioPlayerManager();
  Song? _currentSong;
  List<Song> _allSongs = [];
  StreamSubscription<Song>? _songChangedSubscription;
  final _historyRepository = DefaultListeningHistoryRepository();

  @override
  void initState() {
    super.initState();

    _tabs = [
      HomeTab(
        onSongPlay: (song, songs) {
          updateCurrentSong(song, songs);
        },
      ),
      PlaylistTab(
        onSongPlay: (song, songs) {
          updateCurrentSong(song, songs);
        },
      ),
      AccountTab(),
      const SettingTab(),
    ];

    _songChangedSubscription = _audioManager.songChangedStream.listen((song) {
      _historyRepository.addToHistory(song.id);
      setState(() {
        _currentSong = song;
      });
    });
  }

  @override
  void dispose() {
    _songChangedSubscription?.cancel();
    super.dispose();
  }

  void updateCurrentSong(Song song, List<Song> songs) {
    setState(() {
      _currentSong = song;
      _allSongs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final tabBarHeight = kBottomNavigationBarHeight + bottomPadding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        children: [
          CupertinoTabScaffold(
            backgroundColor: const Color(0xFF0A0118),
            tabBar: CupertinoTabBar(
              backgroundColor: const Color(0xFF0A0118),
              activeColor: const Color(0xFFFF6B9D),
              inactiveColor: Colors.white60,
              border: const Border(
                top: BorderSide(color: Color(0xFF2D1B47), width: 0.5),
              ),
              currentIndex: _currentTabIndex,
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.playlist_play),
                  label: 'Playlists',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Account',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              return CupertinoTabView(
                builder: (context) {
                  return _tabs[index];
                },
              );
            },
          ),
          if (_currentSong != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: tabBarHeight - 13,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: MiniPlayer(
                  currentSong: _currentSong!,
                  allSongs: _allSongs,
                  onSongChanged: (song) {
                    setState(() {
                      _currentSong = song;
                    });
                  },
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                        builder: (context) => NowPlaying(
                          playingSong: _currentSong!,
                          songs: _allSongs,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PlaylistTab extends StatelessWidget {
  final Function(Song, List<Song>)? onSongPlay;

  const PlaylistTab({super.key, this.onSongPlay});

  @override
  Widget build(BuildContext context) {
    return PlaylistPage(onSongPlay: onSongPlay);
  }
}

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
      return CustomScrollView(
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
                _buildRecommendedSection(),
                const SizedBox(height: 32),
                _buildQuickAccessSection(),
                const SizedBox(height: 32),
                _buildRecentlyPlayedSection(),
                const SizedBox(height: 32),
                _buildTrendingSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildRecommendedSection() {
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
                      onTap: () {
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
                      },
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
                      onTap: _reloadRecommendedSongs,
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
          isLoadingRecommended
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
                              .map((song) => _buildRecommendedListItem(song))
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

  Widget _buildQuickAccessSection() {
    final categories = [
      {
        'icon': Icons.favorite,
        'label': 'Yêu thích',
        'gradient': [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
      },
      {
        'icon': Icons.history,
        'label': 'Gần đây',
        'gradient': [Color(0xFFBB6BD9), Color(0xFFD98FFF)],
      },
      {
        'icon': Icons.trending_up,
        'label': 'Thịnh hành',
        'gradient': [Color(0xFF00D9FF), Color(0xFF4DE8FF)],
      },
      {
        'icon': Icons.shuffle,
        'label': 'Ngẫu nhiên',
        'gradient': [Color(0xFFFF9D6B), Color(0xFFFFBB8F)],
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
                  onTap: () {
                    if (index == 3 && songs.isNotEmpty) {
                      final shuffled = List<Song>.from(songs)..shuffle();
                      widget.onSongPlay?.call(shuffled[0], shuffled);
                      Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute(
                          builder: (context) => NowPlaying(
                            songs: shuffled,
                            playingSong: shuffled[0],
                          ),
                        ),
                      );
                    }
                  },
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

  Widget _buildRecentlyPlayedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nghe gần đây',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
        isLoadingRecent
            ? const SizedBox(
          height: 180,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFFFF6B9D),
              ),
            ),
          ),
        )
            : recentSongs.isEmpty
            ? SizedBox(
          height: 180,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chưa có lịch sử nghe nhạc',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        )
            : SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: recentSongs.take(10).length,
            itemBuilder: (context, index) {
              final song = recentSongs[index];
              return _buildAlbumCard(song, recentSongs);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSection() {
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
        isLoadingTrending
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
            return _buildTrendingItem(song, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildAlbumCard(Song song, List<Song> recentSongs) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          widget.onSongPlay?.call(song, songs);
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => NowPlaying(songs: songs, playingSong: song),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBB6BD9).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/itunes1.png',
                  image: song.image,
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/itunes1.png',
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingItem(Song song, int rank) {
    return InkWell(
      onTap: () {
        widget.onSongPlay?.call(song, songs);
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (context) => NowPlaying(songs: songs, playingSong: song),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF1A0F2E).withOpacity(0.4),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2D1B47).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: rank <= 3
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                      )
                    : null,
                color: rank > 3 ? const Color(0xFF2D1B47) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/itunes1.png',
                image: song.image,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/itunes1.png',
                    width: 48,
                    height: 48,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.7)),
              onPressed: () => showBottomSheet(song),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedListItem(Song song) {
    return InkWell(
      onTap: () {
        widget.onSongPlay?.call(song, recommendedSongs);
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (context) =>
                NowPlaying(songs: recommendedSongs, playingSong: song),
          ),
        );
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A0F2E).withOpacity(0.6),
              const Color(0xFF2D1B47).withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFBB6BD9).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B9D).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/itunes1.png',
                  image: song.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/itunes1.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                onPressed: () {
                  showBottomSheet(song);
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reloadRecommendedSongs() {
    setState(() {
      isLoadingRecommended = true;
    });
    _viewModel.loadRecommendedSongs();
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
      backgroundColor: Colors.transparent,
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
              height: 200,
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

  void navigate(Song song) {
    widget.onSongPlay?.call(song, songs);

    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) {
          return NowPlaying(songs: songs, playingSong: song);
        },
      ),
    );
  }
}
