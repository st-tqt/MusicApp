import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/song.dart';

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class RemoteDataSource implements DataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Song>?> loadData() async {
    final response = await supabase.from('songs').select();
    if (response.isEmpty) {
      return null;
    }
    List<Song> songs = (response as List)
        .map((song) => Song.fromMap(song as Map<String, dynamic>))
        .toList();
    return songs;
  }
}

class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    final String response = await rootBundle.loadString('assets/songs.json');
    final jsonBody = jsonDecode(response) as Map;
    final songList = jsonBody['songs'] as List;
    List<Song> songs = songList
        .map((song) => Song.fromMap(song as Map<String, dynamic>))
        .toList();
    return songs;
  }
}
