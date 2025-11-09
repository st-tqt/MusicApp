import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../audio_player_manager.dart';

class PlayerProgressBar extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;

  const PlayerProgressBar({super.key, required this.audioPlayerManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DurationState>(
      stream: audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;

        return ProgressBar(
          progress: progress,
          total: total,
          buffered: buffered,
          onSeek: audioPlayerManager.player.seek,
          barHeight: 5.0,
          barCapShape: BarCapShape.round,
          baseBarColor: const Color(0xFF3D3153),
          progressBarColor: const Color(0xFF9B4DE0),
          bufferedBarColor: const Color(0xFF3D3153),
          thumbColor: const Color(0xFF9B4DE0),
          thumbGlowColor: const Color(0xFF9B4DE0).withOpacity(0.3),
          thumbRadius: 10.0,
          timeLabelTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        );
      },
    );
  }
}
