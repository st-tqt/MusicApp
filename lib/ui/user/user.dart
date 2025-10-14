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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Account"), centerTitle: true),
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
                Text(_user!.name, style: Theme.of(context).textTheme.titleLarge),
                Text(_user!.email, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Các lựa chọn
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Edit Profile"),
                  onTap: () {
                    // TODO: chuyển sang trang chỉnh sửa hồ sơ
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: const Text("My Playlists"),
                  onTap: () {
                    // TODO: mở danh sách playlist
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FavoriteTab()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {
                    // TODO: mở tab settings

                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.red),
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
              onPressed: () async {
                Navigator.pop(context);
                // TODO: xử lý log out ở đây
                // Xóa session Supabase
                await Supabase.instance.client.auth.signOut();

                // Restart toàn bộ app
                Phoenix.rebirth(context);
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
