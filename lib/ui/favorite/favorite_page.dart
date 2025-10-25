import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/model/song.dart';
import '../now_playing/playing.dart';
import 'favorite_viewmodel.dart';

export 'favorite_detail_page.dart';

class FavoriteTab extends StatelessWidget {
  const FavoriteTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const FavoriteTabPage();
  }
}

class FavoriteTabPage extends StatefulWidget {
  const FavoriteTabPage({super.key});

  @override
  State<FavoriteTabPage> createState() => _FavoriteTabPageState();
}

class _FavoriteTabPageState extends State<FavoriteTabPage> {
  List<Song> songs = [];
  late FavoriteViewModel _viewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewModel = FavoriteViewModel();
    _viewModel.loadFavoriteSongs();
    observeData();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF170F23),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF170F23),
        middle: const Text(
          'Favorite Songs',
          style: TextStyle(color: Colors.white),
        ),
        trailing: IconButton(
          onPressed: null,
          icon: const Icon(Icons.more_horiz, color: Colors.white70),
        ),
        border: null,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF170F23),
        body: getBody(),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  Widget getBody() {
    if (_isLoading) {
      return getProgressBar();
    } else if (songs.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có bài hát yêu thích',
          style: TextStyle(fontSize: 18, color: Colors.white60),
        ),
      );
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
    return _FavoriteSongItem(parent: this, song: songs[index]);
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.clear();
        songs.addAll(songList);
        _isLoading = false;
      });
    });
  }

  void navigate(Song song) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) {
          return NowPlaying(songs: songs, playingSong: song);
        },
      ),
    ).then((_) {
      _viewModel.loadFavoriteSongs();
    });
  }

  void removeFavorite(String songId) async {
    final success = await _viewModel.toggleFavorite(songId);
    if (success) {
      _viewModel.loadFavoriteSongs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF2A2139),
            content: Text(
              'Đã xóa khỏi yêu thích',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }
}

class _FavoriteSongItem extends StatelessWidget {
  const _FavoriteSongItem({required this.parent, required this.song});

  final _FavoriteTabPageState parent;
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
          parent.removeFavorite(song.id);
        },
        icon: const Icon(Icons.favorite, color: Color(0xFF9B4DE0)),
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}