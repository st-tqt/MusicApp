import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:music_app/ui/user/login_page.dart';
import 'package:music_app/ui/home/home.dart';

import '../home/music_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Đợi Supabase khôi phục session từ storage
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Lấy session hiện tại
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null && session.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MusicHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo với gradient border
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red,
                    Colors.purple,
                    Colors.blue,
                    Colors.cyan,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1a1a2e),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.music_note,
                    size: 80,
                    color: Colors.blue.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              "Music App",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),

            // Loading Indicator
            CircularProgressIndicator(
              color: Colors.blue.shade300,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}