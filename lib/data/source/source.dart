import 'dart:convert';
import 'dart:math';
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

  @override
  Future<bool> incrementCounter(String songId) async {
    try {
      final response = await supabase
          .from('songs')
          .select('counter')
          .eq('id', songId)
          .single();

      final currentCounter = response['counter'] as int? ?? 0;

      await supabase
          .from('songs')
          .update({'counter': currentCounter + 1})
          .eq('id', songId);

      return true;
    } catch (e) {
      print('Error incrementing counter: $e');
      return false;
    }
  }

  Future<List<Song>?> loadRandomSongs(int limit) async {
    try {
      // Lấy tất cả bài hát
      final response = await supabase.from('songs').select();
      if (response.isEmpty) {
        return null;
      }

      List<Song> allSongs = (response as List)
          .map((song) => Song.fromMap(song as Map<String, dynamic>))
          .toList();

      // Shuffle và lấy số lượng bài hát theo limit
      allSongs.shuffle(Random());
      return allSongs.take(limit).toList();
    } catch (e) {
      print('Error loading random songs: $e');
      return null;
    }
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