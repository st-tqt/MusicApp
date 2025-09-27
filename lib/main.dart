import 'package:flutter/cupertino.dart';
import 'package:music_app/ui/home/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ohpsrmbjjvvnmtckfqce.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ocHNybWJqanZ2bm10Y2tmcWNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyNTE5NDEsImV4cCI6MjA3MzgyNzk0MX0.fR0Ppv3qCVhUKr6cshO3oyRcQv-y1zH27Aq0Ukx6na4',
  );
  runApp(const MusicApp());
}
