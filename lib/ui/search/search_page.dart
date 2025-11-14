import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/model/song.dart';
import '../../data/model/playlist.dart';
import '../now_playing/playing.dart';
import '../playlist/playlist_detail_page.dart';
import 'search_viewmodel.dart';
import 'widgets/search_header.dart';
import 'widgets/search_tab_bar.dart';
import 'widgets/search_empty_state.dart';
import 'widgets/song_item.dart';
import 'widgets/playlist_item.dart';

class SearchTab extends StatelessWidget {
  final Function(Song, List<Song>)? onSongPlay;

  const SearchTab({super.key, this.onSongPlay});

  @override
  Widget build(BuildContext context) {
    return SearchPage(onSongPlay: onSongPlay);
  }
}

class SearchPage extends StatefulWidget {
  final Function(Song, List<Song>)? onSongPlay;

  const SearchPage({super.key, this.onSongPlay});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late SearchViewModel _viewModel;

  List<Song> _searchResultSongs = [];
  List<Playlist> _searchResultPlaylists = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _currentTab = 'songs';

  @override
  void initState() {
    super.initState();
    _viewModel = SearchViewModel();

    // Listen to streams
    _viewModel.songsStream.listen((songs) {
      setState(() {
        _searchResultSongs = songs;
      });
    });

    _viewModel.playlistsStream.listen((playlists) {
      setState(() {
        _searchResultPlaylists = playlists;
      });
    });

    _viewModel.loadingStream.listen((loading) {
      setState(() {
        _isLoading = loading;
      });
    });

    _viewModel.loadAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _hasSearched = query.isNotEmpty;
    });
    _viewModel.performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: SafeArea(
        child: Column(
          children: [
            SearchHeader(
              controller: _searchController,
              onSearch: _performSearch,
            ),
            if (_hasSearched)
              SearchTabBar(
                currentTab: _currentTab,
                songsCount: _searchResultSongs.length,
                playlistsCount: _searchResultPlaylists.length,
                onTabChanged: (tab) => setState(() => _currentTab = tab),
              ),
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return const SearchEmptyState();
    }

    if (_currentTab == 'songs') {
      if (_searchResultSongs.isEmpty) {
        return const SearchEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Không tìm thấy bài hát',
          subtitle: 'Thử tìm kiếm với từ khóa khác',
          borderColor: Color(0xFFFF6B9D),
        );
      }
      return _buildSongsList();
    } else {
      if (_searchResultPlaylists.isEmpty) {
        return const SearchEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Không tìm thấy playlist',
          subtitle: 'Thử tìm kiếm với từ khóa khác',
          borderColor: Color(0xFFFF6B9D),
        );
      }
      return _buildPlaylistsList();
    }
  }

  Widget _buildSongsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResultSongs.length,
      itemBuilder: (context, index) {
        return SongItem(
          song: _searchResultSongs[index],
          onTap: () => _handleSongTap(_searchResultSongs[index]),
        );
      },
    );
  }

  Widget _buildPlaylistsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResultPlaylists.length,
      itemBuilder: (context, index) {
        return PlaylistItem(
          playlist: _searchResultPlaylists[index],
          onTap: () => _handlePlaylistTap(_searchResultPlaylists[index]),
        );
      },
    );
  }

  void _handleSongTap(Song song) {
    widget.onSongPlay?.call(song, _searchResultSongs);
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) =>
            NowPlaying(playingSong: song, songs: _searchResultSongs),
      ),
    );
  }

  void _handlePlaylistTap(Playlist playlist) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => PlaylistDetailPage(
          playlist: playlist,
          onSongPlay: widget.onSongPlay,
        ),
      ),
    );
  }
}