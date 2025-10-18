import 'package:music_app/data/source/source.dart';

import '../model/song.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
  Future<bool> incrementCounter(String songId);
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    final remoteSongs = await _remoteDataSource.loadData();
    if (remoteSongs == null || remoteSongs.isEmpty) {
      final localSongs= await _localDataSource.loadData();
      if(localSongs!=null && localSongs.isNotEmpty){
        songs.addAll(localSongs);
      }
    } else {
      songs.addAll(remoteSongs);
    }
    return songs;
  }

  @override
  Future<bool> incrementCounter(String songId) async {
    return await _remoteDataSource.incrementCounter(songId);
  }
}