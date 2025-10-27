import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:music_app/ui/home/home.dart';
import 'package:music_app/ui/user/login_page.dart';
import 'package:music_app/ui/user/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ohpsrmbjjvvnmtckfqce.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ocHNybWJqanZ2bm10Y2tmcWNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyNTE5NDEsImV4cCI6MjA3MzgyNzk0MX0.fR0Ppv3qCVhUKr6cshO3oyRcQv-y1zH27Aq0Ukx6na4',
  );

  runApp(
    Phoenix(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
