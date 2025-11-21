import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repository/follower_repository.dart';
import '../../../data/model/user.dart';
import '../../../data/model/song.dart';
import '../profile/preview_profile_page.dart';

class FollowersListPage extends StatefulWidget {
  final String userId;
  final String userName;
  final int initialTab;
  final Function(Song, List<Song>)? onSongPlay;

  const FollowersListPage({
    super.key,
    required this.userId,
    required this.userName,
    this.initialTab = 0,
    this.onSongPlay,
  });

  @override
  State<FollowersListPage> createState() => _FollowersListPageState();
}

class _FollowersListPageState extends State<FollowersListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FollowerRepository _repository = FollowerRepository();

  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  bool _isLoadingFollowers = true;
  bool _isLoadingFollowing = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadFollowers();
    _loadFollowing();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowers() async {
    setState(() => _isLoadingFollowers = true);
    try {
      final data = await _repository.getFollowers(widget.userId);
      List<UserModel> users = [];

      for (var item in data) {
        final followerId = item['follower_id'] as String?;
        if (followerId == null) continue;

        // Fetch user info from users table
        try {
          final userResponse = await Supabase.instance.client
              .from('users')
              .select()
              .eq('id', followerId)
              .maybeSingle();

          if (userResponse != null) {
            users.add(UserModel(
              id: userResponse['id'] as String,
              email: userResponse['email'] as String? ?? '',
              name: userResponse['name'] as String? ?? 'User',
              avatarUrl: userResponse['avatar_url'] as String? ?? '', role: '',
            ));
          }
        } catch (e) {
          print('Error fetching user $followerId: $e');
        }
      }

      if (mounted) {
        setState(() {
          _followers = users;
          _isLoadingFollowers = false;
        });
      }
    } catch (e) {
      print('Error loading followers: $e');
      if (mounted) {
        setState(() => _isLoadingFollowers = false);
      }
    }
  }

  Future<void> _loadFollowing() async {
    setState(() => _isLoadingFollowing = true);
    try {
      final data = await _repository.getFollowing(widget.userId);
      List<UserModel> users = [];

      for (var item in data) {
        final followingId = item['following_id'] as String?;
        if (followingId == null) continue;

        // Fetch user info from users table
        try {
          final userResponse = await Supabase.instance.client
              .from('users')
              .select()
              .eq('id', followingId)
              .maybeSingle();

          if (userResponse != null) {
            users.add(UserModel(
              id: userResponse['id'] as String,
              email: userResponse['email'] as String? ?? '',
              name: userResponse['name'] as String? ?? 'User',
              avatarUrl: userResponse['avatar_url'] as String? ?? '', role: '',
            ));
          }
        } catch (e) {
          print('Error fetching user $followingId: $e');
        }
      }

      if (mounted) {
        setState(() {
          _following = users;
          _isLoadingFollowing = false;
        });
      }
    } catch (e) {
      print('Error loading following: $e');
      if (mounted) {
        setState(() => _isLoadingFollowing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0F2E),
        elevation: 0,
        title: Text(
          widget.userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF6B9D),
          indicatorWeight: 3,
          labelColor: const Color(0xFFFF6B9D),
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: [
            Tab(text: '${_followers.length} Người theo dõi'),
            Tab(text: '${_following.length} Đang theo dõi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowersList(),
          _buildFollowingList(),
        ],
      ),
    );
  }

  Widget _buildFollowersList() {
    if (_isLoadingFollowers) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
        ),
      );
    }

    if (_followers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'Chưa có người theo dõi',
        subtitle: 'Những người theo dõi sẽ hiển thị ở đây',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowers,
      color: const Color(0xFFFF6B9D),
      backgroundColor: const Color(0xFF1A0F2E),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _followers.length,
        itemBuilder: (context, index) {
          return _buildUserItem(_followers[index]);
        },
      ),
    );
  }

  Widget _buildFollowingList() {
    if (_isLoadingFollowing) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
        ),
      );
    }

    if (_following.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_add_outlined,
        title: 'Chưa theo dõi ai',
        subtitle: 'Những người bạn theo dõi sẽ hiển thị ở đây',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowing,
      color: const Color(0xFFFF6B9D),
      backgroundColor: const Color(0xFF1A0F2E),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _following.length,
        itemBuilder: (context, index) {
          return _buildUserItem(_following[index]);
        },
      ),
    );
  }

  Widget _buildUserItem(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewProfilePage(
                  user: user,
                  onSongPlay: widget.onSongPlay,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(user),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
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
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF0A0118),
          child: CircleAvatar(
            radius: 26,
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
            backgroundColor: const Color(0xFF1A0F2E),
            child: user.avatarUrl.isEmpty
                ? Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
              icon,
              size: 64,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}