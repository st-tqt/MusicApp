import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/model/user.dart';
import '../home/viewmodel.dart';
import '../now_playing/audio_player_manager.dart';
import 'favorite_page.dart';

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
        backgroundColor: Color(0xFF170F23),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF9B4DE0)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF170F23),
      appBar: AppBar(
        title: const Text("Account", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF170F23),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Phần thông tin user
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(
                    _user!.avatarUrl.isNotEmpty
                        ? _user!.avatarUrl
                        : "https://i.pravatar.cc/150?img=3",
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _user!.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _user!.email,
                  style: const TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Các lựa chọn
          Card(
            color: const Color(0xFF2A2139),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white60,
                  ),
                  onTap: () {
                    // TODO: chuyển sang trang chỉnh sửa hồ sơ
                  },
                ),
                Divider(
                  height: 1,
                  color: const Color(0xFF3D3153),
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_play, color: Colors.white),
                  title: const Text(
                    "My Playlists",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white60,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoriteTab(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: const Color(0xFF3D3153),
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text(
                    "Settings",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white60,
                  ),
                  onTap: () {
                    // TODO: mở tab settings
                  },
                ),
                Divider(
                  height: 1,
                  color: const Color(0xFF3D3153),
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Color(0xFF9B4DE0)),
                  title: const Text(
                    "Log Out",
                    style: TextStyle(color: Color(0xFF9B4DE0)),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white60,
                  ),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
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
              //logout
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
