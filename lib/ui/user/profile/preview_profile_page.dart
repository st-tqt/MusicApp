import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/playlist.dart';
import '../../../data/model/user.dart';
import '../../../data/model/song.dart';
import '../../../data/repository/follower_repository.dart';
import '../../playlist/playlist_viewmodel.dart';
import '../followers/follower_list_page.dart';
import 'edit_profile_page.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_action_buttons.dart';
import 'widgets/playlist_list_section.dart';

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
  final FollowerRepository _followerRepository = FollowerRepository();

  List<Playlist> _publicPlaylists = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, List<Song>> _playlistSongsCache = {};

  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isFollowLoading = false;

  StreamSubscription? _playlistsSubscription;
  StreamSubscription? _loadingSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = PlaylistViewModel();
    _loadPublicPlaylistsOfSpecificUser();
    _loadFollowerStats();
  }

  @override
  void dispose() {
    _playlistsSubscription?.cancel();
    _loadingSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  // Data Loading Methods
  Future<void> _loadFollowerStats() async {
    try {
      final stats = await _followerRepository.getFollowerStats(widget.user.id);
      if (mounted) {
        setState(() {
          _followersCount = stats.followersCount;
          _followingCount = stats.followingCount;
          _isFollowing = stats.isFollowing;
        });
      }
    } catch (e) {
      print('Error loading follower stats: $e');
    }
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
            _publicPlaylists = playlists.where((p) => p.isPublic == true).toList();
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

  // Action Methods
  Future<void> _toggleFollow() async {
    if (_isFollowLoading) return;

    setState(() => _isFollowLoading = true);

    try {
      if (_isFollowing) {
        final success = await _followerRepository.unfollowUser(widget.user.id);
        if (success && mounted) {
          setState(() {
            _isFollowing = false;
            _followersCount--;
          });
          _showSnackBar('Đã bỏ theo dõi ${widget.user.name}');
        }
      } else {
        final follower = await _followerRepository.followUser(widget.user.id);
        if (follower != null && mounted) {
          setState(() {
            _isFollowing = true;
            _followersCount++;
          });
          _showSnackBar('Đã theo dõi ${widget.user.name}');
        }
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isFollowLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareProfile() async {
    final customLink = 'musicapp://user/${widget.user.id}';
    final shareText = 'Xem profile của ${widget.user.name}\n$customLink';

    try {
      await Share.share(shareText, subject: 'Profile của ${widget.user.name}');
    } catch (e) {
      _showSnackBar('Không thể chia sẻ: ${e.toString()}', isError: true);
    }
  }

  Future<void> _copyProfileLink() async {
    try {
      await Clipboard.setData(ClipboardData(text: 'musicapp://user/${widget.user.id}'));
      _showSnackBar('Đã copy link profile');
    } catch (e) {
      _showSnackBar('Không thể copy: ${e.toString()}', isError: true);
    }
  }

  void _navigateToFollowersList(bool showFollowers) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersListPage(
          userId: widget.user.id,
          userName: widget.user.name,
          initialTab: showFollowers ? 0 : 1,
          onSongPlay: widget.onSongPlay,
        ),
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
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildBottomSheetOption(
                  icon: Icons.share_outlined,
                  title: 'Chia sẻ hồ sơ',
                  onTap: () {
                    Navigator.pop(context);
                    _shareProfile();
                  },
                ),
                _buildBottomSheetOption(
                  icon: Icons.link,
                  title: 'Copy link hồ sơ',
                  onTap: () {
                    Navigator.pop(context);
                    _copyProfileLink();
                  },
                ),
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
                if (!isMyProfile)
                  _buildBottomSheetOption(
                    icon: Icons.flag_outlined,
                    title: 'Báo cáo người dùng',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      _showSnackBar('Báo cáo người dùng: ${widget.user.id}');
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
                color: isDestructive ? Colors.red : Colors.white.withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red : Colors.white.withOpacity(0.9),
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final bool isMyProfileAdminView =
        (widget.user.id == currentUserId) && !widget.forceGuestView;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: CustomScrollView(
        slivers: [
          ProfileHeader(
            user: widget.user,
            followersCount: _followersCount,
            followingCount: _followingCount,
            onFollowersTap: () => _navigateToFollowersList(true),
            onFollowingTap: () => _navigateToFollowersList(false),
          ),
          ProfileActionButtons(
            isMyProfile: isMyProfileAdminView,
            isFollowing: _isFollowing,
            isFollowLoading: _isFollowLoading,
            onEditProfile: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(user: widget.user),
                ),
              );
            },
            onToggleFollow: _toggleFollow,
            onMoreOptions: () => _showMoreOptions(isMyProfile: isMyProfileAdminView),
          ),
          PlaylistListSection(
            playlists: _publicPlaylists,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            getCachedPlaylistSongs: _getCachedPlaylistSongs,
            onRetry: _loadPublicPlaylistsOfSpecificUser,
            onSongPlay: widget.onSongPlay,
          ),
        ],
      ),
    );
  }
}