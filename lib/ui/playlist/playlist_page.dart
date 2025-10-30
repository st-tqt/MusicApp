import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/model/playlist.dart';
import '../../data/model/song.dart';
import '../favorite/favorite_detail_page.dart';
import 'playlist_viewmodel.dart';
import 'playlist_detail_page.dart';
import '../favorite/favorite_page.dart';

class PlaylistPage extends StatefulWidget {
  final Function(Song, List<Song>)? onSongPlay;

  const PlaylistPage({super.key, this.onSongPlay});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late PlaylistViewModel _viewModel;
  List<Playlist> _playlists = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = PlaylistViewModel();
    _viewModel.playlistsStream.listen((playlists) {
      setState(() {
        _playlists = playlists;
      });
    });
    _viewModel.loadingStream.listen((loading) {
      setState(() {
        _isLoading = loading;
      });
    });
    _viewModel.loadUserPlaylists();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF0A0118),
            elevation: 0,
            expandedHeight: 120,
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
                  'Playlists',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                  onPressed: () => _showCreatePlaylistDialog(),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _isLoading
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
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildFavoritePlaylistCard(),
                      if (_playlists.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                            ).createShader(bounds),
                            child: const Text(
                              'Playlist của tôi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = _playlists[index];
                          return _buildPlaylistCard(playlist);
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritePlaylistCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0F2E), Color(0xFF2D1B47)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    FavoriteDetailPage(onSongPlay: widget.onSongPlay),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yêu thích',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.lock,
                            size: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Playlist hệ thống',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return FutureBuilder<List<Song>?>(
      future: _viewModel.loadPlaylistSongs(playlist.id),
      builder: (context, snapshot) {
        String? firstSongImage;
        int songCount = 0;

        if (snapshot.hasData && snapshot.data != null) {
          songCount = snapshot.data!.length;
          if (snapshot.data!.isNotEmpty) {
            firstSongImage = snapshot.data!.first.image;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A0F2E).withOpacity(0.6),
                const Color(0xFF2D1B47).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBB6BD9).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => PlaylistDetailPage(
                      playlist: playlist,
                      onSongPlay: widget.onSongPlay,
                    ),
                  ),
                );
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: firstSongImage == null
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFFBB6BD9).withOpacity(0.3),
                                  const Color(0xFF00D9FF).withOpacity(0.2),
                                ],
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBB6BD9).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: firstSongImage != null && firstSongImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                firstSongImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.playlist_play,
                                    color: Color(0xFFBB6BD9),
                                    size: 32,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.playlist_play,
                              color: Color(0xFFBB6BD9),
                              size: 32,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (playlist.description != null &&
                              playlist.description!.isNotEmpty)
                            Text(
                              playlist.description!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                playlist.isPublic ? Icons.public : Icons.lock,
                                size: 13,
                                color: Colors.white.withOpacity(0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                playlist.isPublic ? "Công khai" : "Riêng tư",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.music_note,
                                size: 13,
                                color: Colors.white.withOpacity(0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$songCount bài hát',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      color: const Color(0xFF1A0F2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color(0xFFBB6BD9).withOpacity(0.3),
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditPlaylistDialog(playlist);
                        } else if (value == 'delete') {
                          _showDeletePlaylistDialog(playlist);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B9D),
                                        Color(0xFFBB6BD9),
                                      ],
                                    ).createShader(bounds),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Chỉnh sửa',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: const [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
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

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0F2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFFBB6BD9).withOpacity(0.3)),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
            ).createShader(bounds),
            child: const Text(
              'Tạo Playlist',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tên Playlist',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFBB6BD9),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFBB6BD9),
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isPublic,
                    onChanged: (value) {
                      setDialogState(() {
                        isPublic = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFBB6BD9),
                    checkColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  const Text(
                    'Đặt công khai',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.pop(context);
                  await _viewModel.createPlaylist(
                    nameController.text.trim(),
                    descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    isPublic,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Tạo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPlaylistDialog(Playlist playlist) {
    final nameController = TextEditingController(text: playlist.name);
    final descriptionController = TextEditingController(
      text: playlist.description ?? '',
    );
    bool isPublic = playlist.isPublic;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0F2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFFBB6BD9).withOpacity(0.3)),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
            ).createShader(bounds),
            child: const Text(
              'Chỉnh sửa Playlist',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tên Playlist',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFBB6BD9),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFBB6BD9),
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isPublic,
                    onChanged: (value) {
                      setDialogState(() {
                        isPublic = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFBB6BD9),
                    checkColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  const Text(
                    'Đặt công khai',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.pop(context);
                  await _viewModel.updatePlaylist(
                    playlist.id,
                    nameController.text.trim(),
                    descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    isPublic,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletePlaylistDialog(Playlist playlist) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Xóa Playlist'),
        content: Text('Bạn có chắc chắn muốn xóa "${playlist.name}"?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await _viewModel.deletePlaylist(playlist.id);
            },
            child: const Text('Xóa'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }
}
