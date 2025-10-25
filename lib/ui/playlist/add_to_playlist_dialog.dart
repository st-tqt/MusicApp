import 'package:flutter/material.dart';
import '../../data/model/playlist.dart';
import '../../data/model/song.dart';
import 'playlist_viewmodel.dart';

/// Dialog để thêm bài hát vào playlist
/// Sử dụng: showAddToPlaylistDialog(context, song)
void showAddToPlaylistDialog(BuildContext context, Song song) {
  showDialog(
    context: context,
    builder: (context) => AddToPlaylistDialogWrapper(song: song),
  );
}

/// Wrapper widget để load data trước khi hiển thị dialog
class AddToPlaylistDialogWrapper extends StatefulWidget {
  final Song song;

  const AddToPlaylistDialogWrapper({super.key, required this.song});

  @override
  State<AddToPlaylistDialogWrapper> createState() => _AddToPlaylistDialogWrapperState();
}

class _AddToPlaylistDialogWrapperState extends State<AddToPlaylistDialogWrapper> {
  final _viewModel = PlaylistViewModel();
  List<Playlist>? _playlists;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _viewModel.getUserPlaylists();
    setState(() {
      _playlists = playlists;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        backgroundColor: Color(0xFF2A2139),
        content: SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF9B4DE0)),
          ),
        ),
      );
    }

    return AddToPlaylistDialog(
      song: widget.song,
      playlists: _playlists ?? [],
      viewModel: _viewModel,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}

class AddToPlaylistDialog extends StatefulWidget {
  final Song song;
  final List<Playlist> playlists;
  final PlaylistViewModel viewModel;

  const AddToPlaylistDialog({
    super.key,
    required this.song,
    required this.playlists,
    required this.viewModel,
  });

  @override
  State<AddToPlaylistDialog> createState() => _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  final Map<String, bool> _songInPlaylist = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSongInPlaylists();
  }

  Future<void> _checkSongInPlaylists() async {
    setState(() {
      _isLoading = true;
    });

    for (var playlist in widget.playlists) {
      final isIn = await widget.viewModel.isSongInPlaylist(
        playlist.id,
        widget.song.id,
      );
      _songInPlaylist[playlist.id] = isIn;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2139),
      title: const Text(
        'Add to Playlist',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF9B4DE0)),
        )
            : widget.playlists.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No playlists yet.\nCreate a playlist first.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          itemCount: widget.playlists.length,
          itemBuilder: (context, index) {
            final playlist = widget.playlists[index];
            final isInPlaylist = _songInPlaylist[playlist.id] ?? false;

            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF9B4DE0).withOpacity(0.2),
                ),
                child: playlist.image != null && playlist.image!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    playlist.image!,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.playlist_play,
                  color: Color(0xFF9B4DE0),
                ),
              ),
              title: Text(
                playlist.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: isInPlaylist
                  ? const Icon(
                Icons.check_circle,
                color: Color(0xFF9B4DE0),
              )
                  : const Icon(
                Icons.add_circle_outline,
                color: Colors.white54,
              ),
              onTap: isInPlaylist
                  ? null
                  : () async {
                final success = await widget.viewModel.addSongToPlaylist(
                  playlist.id,
                  widget.song.id,
                );

                if (success) {
                  setState(() {
                    _songInPlaylist[playlist.id] = true;
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added to ${playlist.name}',
                        ),
                        backgroundColor: const Color(0xFF9B4DE0),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add song'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.viewModel.dispose();
            Navigator.pop(context);
          },
          child: Text(
            'Close',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ),
        if (widget.playlists.isEmpty)
          ElevatedButton(
            onPressed: () {
              widget.viewModel.dispose();
              Navigator.pop(context);
              // TODO: Navigate to create playlist page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B4DE0),
            ),
            child: const Text(
              'Create Playlist',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }
}