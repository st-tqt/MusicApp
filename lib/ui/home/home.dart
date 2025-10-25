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
        scaffoldBackgroundColor: const Color(0xFF170F23),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF9B4DE0),
          secondary: const Color(0xFF9B4DE0),
          surface: const Color(0xFF170F23),
          background: const Color(0xFF170F23),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF170F23),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF2A2139),
        dividerColor: const Color(0xFF3D3153),
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
            backgroundColor: const Color(0xFF170F23),
            tabBar: CupertinoTabBar(
              backgroundColor: const Color(0xFF170F23),
              activeColor: const Color(0xFF9B4DE0),
              inactiveColor: Colors.white60,
              border: const Border(
                top: BorderSide(color: Color(0xFF3D3153), width: 0.5),
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
              bottom: tabBarHeight - 11,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
  late MusicAppViewModel _viewModel;
  bool isLoadingRecommended = true;

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    _viewModel.loadRecommendedSongs();
    observeData();
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF170F23),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF170F23),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170F23),
      appBar: AppBar(
        title: const Text('Music App', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF170F23),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
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
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecommendedSection(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tất cả bài hát',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            getListView(),
          ],
        ),
      );
    }
  }

  Widget _buildRecommendedSection() {
    return Container(
      color: const Color(0xFF170F23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gợi ý bài hát',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B4DE0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Phát tất cả',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _reloadRecommendedSongs,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2139),
                          borderRadius: BorderRadius.circular(16),
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
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF9B4DE0)),
                  ),
                )
              : SizedBox(
                  height: 280,
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
                        padding: const EdgeInsets.only(right: 8),
                        child: Column(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onPressed: () {
                showBottomSheet(song);
              },
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
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF9B4DE0)),
    );
  }

  Widget getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Color(0xFF3D3153),
          thickness: 0.5,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget getRow(int index) {
    return _songItemSection(parent: this, song: songs[index]);
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
  }

  void showBottomSheet(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2139),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 200,
            color: const Color(0xFF2A2139),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.playlist_add, color: Colors.white),
                    title: Text(
                      'Add to Playlist',
                      style: TextStyle(color: Colors.white),
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

class _songItemSection extends StatelessWidget {
  const _songItemSection({required this.parent, required this.song});

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itunes1.png',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/itunes1.png', width: 48, height: 48);
          },
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        song.artist,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: IconButton(
        onPressed: () {
          parent.showBottomSheet(song);
        },
        icon: const Icon(Icons.more_horiz, color: Colors.white70),
        onLongPress: () {
          parent.showBottomSheet(song);
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
