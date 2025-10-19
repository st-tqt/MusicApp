import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/discovery/discovery.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/now_playing/audio_player_manager.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:music_app/ui/user/user.dart';

import '../../data/model/song.dart';
import '../now_playing/mini_player.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  @override
  void initState() {
    super.initState();

    // Lắng nghe thay đổi bài hát
    _audioManager.onSongChanged = (song) {
      setState(() {
        _currentSong = song;
      });
    };
  }

  void updateCurrentSong(Song song, List<Song> songs) {
    setState(() {
      _currentSong = song;
      _allSongs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Music App')),
      child: Stack(
        children: [
          // Tab chính
          CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
              // Truyền callback xuống HomeTab
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

          // MINI PLAYER
          if (_currentSong != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight + 11,
              // tự động lấy chiều cao tab bar (~50)
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                // thêm tí khoảng cách
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getBody());
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
    return const Center(child: CircularProgressIndicator());
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
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
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 400,
            color: Colors.grey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Modal Bottom Sheet'),
                  ElevatedButton(
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
    // GỌI CALLBACK ĐỂ CẬP NHẬT MINI PLAYER
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
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        onPressed: () {
          parent.showBottomSheet();
        },
        icon: const Icon(Icons.more_horiz),
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
