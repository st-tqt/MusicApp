import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/ui/home/home_tab.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/ui/user/user.dart';
import '../../data/model/song.dart';
import '../../data/repository/listening_history_repository.dart';
import '../now_playing/mini_player.dart';
import '../now_playing/playing.dart';
import '../playlist/playlist_page.dart';
import '../search/search_page.dart';
import 'home.dart' hide HomeTab;

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
      SearchTab(
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
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.playlist_play),
                  label: 'Playlists',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Account',
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
