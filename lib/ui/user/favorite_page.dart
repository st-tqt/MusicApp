import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/model/song.dart';
import '../now_playing/playing.dart';
import 'favorite_viewmodel.dart';

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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Favorite Songs'),
        trailing: IconButton(
          onPressed: null, // Có thể thêm chức năng cho nút này nếu cần
          icon: Icon(Icons.more_horiz),
        ),
      ),
      child: Scaffold(body: getBody()),
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
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
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
      // Reload lại danh sách khi quay về (có thể đã thay đổi favorite)
      _viewModel.loadFavoriteSongs();
    });
  }

  void removeFavorite(String songId) async {
    final success = await _viewModel.toggleFavorite(songId);
    if (success) {
      // Reload lại danh sách
      _viewModel.loadFavoriteSongs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khỏi yêu thích'),
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
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        onPressed: () {
          // Xóa khỏi favorite
          parent.removeFavorite(song.id);
        },
        icon: const Icon(Icons.favorite, color: Colors.red),
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
