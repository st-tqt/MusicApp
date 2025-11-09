import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../audio_player_manager.dart';
import 'media_button_control.dart';

class PlayButton extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onPlayStateChanged;

  const PlayButton({
    super.key,
    required this.audioPlayerManager,
    required this.onPlay,
    required this.onPause,
    required this.onPlayStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(color: Color(0xFF9B4DE0)),
          );
        } else if (playing != true) {
          return MediaButtonControl(
            function: () {
              audioPlayerManager.player.play();
              onPlay();
            },
            icon: Icons.play_arrow,
            color: Colors.white,
            size: 48,
          );
        } else if (processingState != ProcessingState.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onPlayStateChanged();
          });
          return MediaButtonControl(
            function: () {
              audioPlayerManager.player.pause();
              onPause();
            },
            icon: Icons.pause,
            color: Colors.white,
            size: 48,
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onPlayStateChanged();
          });
          return MediaButtonControl(
            function: () {
              audioPlayerManager.player.pause();
              onPause();
            },
            icon: Icons.replay,
            color: Colors.white,
            size: 48,
          );
        }
      },
    );
  }
}
