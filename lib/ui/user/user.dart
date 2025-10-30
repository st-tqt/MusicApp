import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:music_app/ui/playlist/playlist_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/model/user.dart';
import '../home/viewmodel.dart';
import '../now_playing/audio_player_manager.dart';
import '../favorite/favorite_page.dart';

class AccountTab extends StatelessWidget {
  AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountPage();
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late UserViewModel _viewModel;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _viewModel = UserViewModel();
    _viewModel.loadCurrentUser();
    _viewModel.userStream.stream.listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0118),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0A0118),
            elevation: 0,
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
                      Container(
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
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
                              backgroundImage: NetworkImage(
                                _user!.avatarUrl.isNotEmpty
                                    ? _user!.avatarUrl
                                    : "https://i.pravatar.cc/150?img=3",
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                        ).createShader(bounds),
                        child: Text(
                          _user!.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _user!.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildMenuSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.edit,
          title: "Edit Profile",
          subtitle: "Update your personal information",
          gradient: const [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
          onTap: () {
            // TODO: chuyển sang trang chỉnh sửa hồ sơ
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.playlist_play,
          title: "My Playlists",
          subtitle: "Manage your music collections",
          gradient: const [Color(0xFFBB6BD9), Color(0xFFD98FFF)],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlaylistPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.favorite,
          title: "Favorite Songs",
          subtitle: "Your liked tracks",
          gradient: const [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
          onTap: () {
            // Navigate to favorites
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.settings,
          title: "Settings",
          subtitle: "App preferences and options",
          gradient: const [Color(0xFF00D9FF), Color(0xFF4DE8FF)],
          onTap: () {
            // TODO: mở tab settings
          },
        ),
        const SizedBox(height: 24),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          border: Border.all(color: gradient[0].withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
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
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B9D).withOpacity(0.2),
              const Color(0xFFBB6BD9).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF6B9D).withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout,
                color: Color(0xFFFF6B9D),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Log Out",
              style: TextStyle(
                color: Color(0xFFFF6B9D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.pop(context);
                final audioPlayer = AudioPlayerManager();
                await audioPlayer.player.stop();
                AudioPlayerManager.reset();
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Phoenix.rebirth(context);
                }
              },
              child: const Text("Log Out"),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
