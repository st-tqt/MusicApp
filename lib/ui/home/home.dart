import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/ui/discovery/discovery.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:music_app/ui/user/user.dart';

import '../../data/model/song.dart';
import '../../data/repository/listening_history_repository.dart';
import '../now_playing/mini_player.dart';
import '../now_playing/playing.dart';

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
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    AccountTab(),
    const SettingTab(),
  ];

  final _audioManager = AudioPlayerManager();
  Song? _currentSong;
  List<Song> _allSongs = [];
  StreamSubscription<Song>? _songChangedSubscription;
  final _historyRepository = DefaultListeningHistoryRepository();

  @override
  void initState() {
    super.initState();

    // Đăng ký lắng nghe stream
    _songChangedSubscription = _audioManager.songChangedStream.listen((song) {
      _historyRepository.addToHistory(song.id);
      setState(() {
        _currentSong = song;
      });
    });
  }

  @override
  void dispose() {
    // Hủy subscription
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0xFF170F23),
        navigationBar: CupertinoNavigationBar(
          backgroundColor: const Color(0xFF170F23),
          middle: const Text(
            'Music App',
            style: TextStyle(color: Colors.white),
          ),
          border: null,
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
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.album),
                    label: 'Discovery',
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
                if (index == 0) {
                  return HomeTab(
                    onSongPlay: (song, songs) {
                      updateCurrentSong(song, songs);
                    },
                  );
                }
                return _tabs[index];
              },
            ),

            if (_currentSong != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: kBottomNavigationBarHeight + 11,
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
                      Navigator.push(
                        context,
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
      ),
    );
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
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    obderveData();
    super.initState();

    // Set status bar màu tối
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
      body: SafeArea(child: getBody()),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF9B4DE0)),
    );
  }

  ListView getListView() {
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
    );
  }

  Widget getRow(int index) {
    return _songItemSection(parent: this, song: songs[index]);
  }

  void obderveData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2139),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 400,
            color: const Color(0xFF2A2139),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Modal Bottom Sheet',
                    style: TextStyle(color: Colors.white),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B4DE0),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close Bottom Sheet'),
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

    Navigator.push(
      context,
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
          parent.showBottomSheet();
        },
        icon: const Icon(Icons.more_horiz, color: Colors.white70),
        onLongPress: () {
          parent.showBottomSheet();
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
