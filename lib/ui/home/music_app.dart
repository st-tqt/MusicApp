import 'package:flutter/material.dart';
import 'music_home_page.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicApp',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0118),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFF6B9D),
          secondary: const Color(0xFF00D9FF),
          surface: const Color(0xFF1A0F2E),
          background: const Color(0xFF0A0118),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0118),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF1A0F2E),
        dividerColor: const Color(0xFF2D1B47),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}