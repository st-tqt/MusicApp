import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/model/playlist.dart';
import '../../data/model/user.dart';
import '../../data/model/song.dart';
import '../playlist/playlist_detail_page.dart';
import '../playlist/playlist_viewmodel.dart';
import 'CRUD/edit_profile_page.dart';

class PreviewProfilePage extends StatefulWidget {
  final UserModel user;
  final Function(Song, List<Song>)? onSongPlay;
  final bool forceGuestView;

  const PreviewProfilePage({
    super.key,
    required this.user,
    this.onSongPlay,
    this.forceGuestView = false,
  });

  @override
  State<PreviewProfilePage> createState() => _PreviewProfilePageState();
}

class _PreviewProfilePageState extends State<PreviewProfilePage> {
  late PlaylistViewModel _viewModel;
  List<Playlist> _publicPlaylists = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Cache songs để tránh load lại nhiều lần
  final Map<String, List<Song>> _playlistSongsCache = {};

  // State cho follow (dữ liệu ảo tạm thời)
  bool _isFollowing = false;
  int _followersCount = 127; // Dữ liệu ảo
  int _followingCount = 45; // Dữ liệu ảo

  StreamSubscription? _playlistsSubscription;
  StreamSubscription? _loadingSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = PlaylistViewModel();
    _loadPublicPlaylistsOfSpecificUser();
  }

  Future<void> _loadPublicPlaylistsOfSpecificUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _playlistsSubscription?.cancel();
    await _loadingSubscription?.cancel();

    _playlistsSubscription = _viewModel.playlistsStream.listen(
      (playlists) {
        if (mounted) {
          setState(() {
            _publicPlaylists = playlists
                .where((p) => p.isPublic == true)
                .toList();
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Không thể tải playlists';
            _isLoading = false;
          });
        }
      },
    );

    _loadingSubscription = _viewModel.loadingStream.listen((loading) {
      if (mounted) {
        setState(() {
          _isLoading = loading;
        });
      }
    });

    try {
      await _viewModel.loadPlaylistsForUser(widget.user.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải playlists';
          _isLoading = false;
        });
      }
    }
  }

  Future<List<Song>> _getCachedPlaylistSongs(String playlistId) async {
    if (_playlistSongsCache.containsKey(playlistId)) {
      return _playlistSongsCache[playlistId]!;
    }

    final songs = await _viewModel.loadPlaylistSongs(playlistId);
    if (songs != null) {
      _playlistSongsCache[playlistId] = songs;
      return songs;
    }
    return [];
  }

  Future<void> _toggleFollow() async {
    // TODO: Implement real follow/unfollow API
    // try {
    //   if (_isFollowing) {
    //     await UserRepository().unfollowUser(widgets.user.id);
    //   } else {
    //     await UserRepository().followUser(widgets.user.id);
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Lỗi: ${e.toString()}')),
    //   );
    //   return;
    // }

    setState(() {
      if (_isFollowing) {
        _isFollowing = false;
        _followersCount--;
      } else {
        _isFollowing = true;
        _followersCount++;
      }
    });
  }

  Future<void> _shareProfile() async {
    // Tạo deep link - có thể chọn 1 trong 2 format:

    // Option 1: Custom scheme (hoạt động offline)
    final customLink = 'musicapp://user/${widget.user.id}';

    // Option 2: Universal link (cần domain và server setup)
    // final universalLink = 'https://your-domain.com/user/${widgets.user.id}';

    // Tạo nội dung share
    final shareText = 'Xem profile của ${widget.user.name}\n$customLink';

    try {
      // Share link
      await Share.share(
        shareText,
        subject: 'Profile của ${widget.user.name}',
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chia sẻ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyProfileLink() async {
    final link = 'musicapp://user/${widget.user.id}';

    try {
      await Clipboard.setData(ClipboardData(text: link));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã copy link profile'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể copy: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _playlistsSubscription?.cancel();
    _loadingSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final bool isMyProfileAdminView =
        (widget.user.id == currentUserId) && !widget.forceGuestView;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildActionButtons(isMyProfileAdminView),
          _buildPlaylistsHeader(),
          _buildPlaylistsContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0A0118),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A0F2E).withOpacity(0.8),
                const Color(0xFF0A0118),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildAvatar(),
                const SizedBox(height: 16),
                _buildUserName(),
                const SizedBox(height: 8),
                _buildFollowStats(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFF0A0118),
          child: CircleAvatar(
            radius: 56,
            backgroundImage: widget.user.avatarUrl.isNotEmpty
                ? NetworkImage(widget.user.avatarUrl)
                : null,
            backgroundColor: const Color(0xFF1A0F2E),
            child: widget.user.avatarUrl.isEmpty
                ? Text(
                    widget.user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildUserName() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
      ).createShader(bounds),
      child: Text(
        widget.user.name,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFollowStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$_followersCount người theo dõi',
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '•',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ),
        Text(
          'Đang theo dõi $_followingCount',
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMyProfileAdminView) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: isMyProfileAdminView
            ? _buildEditProfileButton()
            : _buildFollowButton(),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF6B9D).withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: widget.user),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Chỉnh sửa hồ sơ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildMoreOptionsButton(isMyProfile: true),
      ],
    );
  }

  Widget _buildFollowButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: _isFollowing
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: _isFollowing ? Colors.white.withOpacity(0.1) : null,
              border: _isFollowing
                  ? Border.all(
                      color: const Color(0xFFFF6B9D).withOpacity(0.4),
                      width: 1.5,
                    )
                  : null,
              boxShadow: _isFollowing
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleFollow,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      _isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildMoreOptionsButton(isMyProfile: false),
      ],
    );
  }

  Widget _buildMoreOptionsButton({required bool isMyProfile}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFBB6BD9).withOpacity(0.4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMoreOptions(isMyProfile: isMyProfile),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.9)),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistsHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Text(
          'Playlists',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistsContent() {
    if (_errorMessage != null) {
      return SliverFillRemaining(child: _buildErrorState());
    }

    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
          ),
        ),
      );
    }

    if (_publicPlaylists.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final playlist = _publicPlaylists[index];
          return _buildPlaylistItem(playlist);
        }, childCount: _publicPlaylists.length),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A0F2E).withOpacity(0.5),
                  const Color(0xFF2D1B47).withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFBB6BD9).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _errorMessage ?? 'Đã có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPublicPlaylistsOfSpecificUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A0F2E).withOpacity(0.5),
                  const Color(0xFF2D1B47).withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFBB6BD9).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.playlist_play_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Không có playlist công khai',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo và chia sẻ playlist đầu tiên',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistItem(Playlist playlist) {
    return FutureBuilder<List<Song>>(
      future: _getCachedPlaylistSongs(playlist.id),
      builder: (context, snapshot) {
        String? firstSongImage;
        int songCount = 0;

        if (snapshot.hasData) {
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
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => PlaylistDetailPage(
                      playlist: playlist,
                      onSongPlay: widget.onSongPlay,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _buildPlaylistImage(firstSongImage),
                    const SizedBox(width: 14),
                    _buildPlaylistInfo(playlist, songCount),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaylistImage(String? firstSongImage) {
    return Container(
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
          : const Icon(Icons.playlist_play, color: Color(0xFFBB6BD9), size: 32),
    );
  }

  Widget _buildPlaylistInfo(Playlist playlist, int songCount) {
    return Expanded(
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
          Text(
            '$songCount bài hát',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions({required bool isMyProfile}) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A0F2E),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: const Color(0xFFBB6BD9).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Chia sẻ hồ sơ
                _buildBottomSheetOption(
                  icon: Icons.share_outlined,
                  title: 'Chia sẻ hồ sơ',
                  onTap: () {
                    Navigator.pop(context);
                    _shareProfile();
                  },
                ),

                //Copy link
                _buildBottomSheetOption(
                  icon: Icons.link,
                  title: 'Copy link hồ sơ',
                  onTap: () {
                    Navigator.pop(context);
                    _copyProfileLink();
                  },
                ),

                // Xem dưới tư cách khách (chỉ hiển thị nếu là hồ sơ của tôi)
                if (isMyProfile)
                  _buildBottomSheetOption(
                    icon: Icons.remove_red_eye_outlined,
                    title: 'Xem dưới tư cách khách',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreviewProfilePage(
                            user: widget.user,
                            onSongPlay: widget.onSongPlay,
                            forceGuestView: true,
                          ),
                        ),
                      );
                    },
                  ),

                // Báo cáo người dùng
                if (!isMyProfile)
                  _buildBottomSheetOption(
                    icon: Icons.flag_outlined,
                    title: 'Báo cáo người dùng',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Báo cáo người dùng: ${widget.user.id}',
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? Colors.red
                    : Colors.white.withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDestructive
                      ? Colors.red
                      : Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
