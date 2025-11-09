import 'package:flutter/material.dart';
import '../../../data/model/song.dart';

class AlbumArtwork extends StatelessWidget {
  final Song song;
  final double screenWidth;
  final AnimationController animationController;

  const AlbumArtwork({
    super.key,
    required this.song,
    required this.screenWidth,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(animationController),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itunes1.png',
          image: song.image,
          width: screenWidth - delta,
          height: screenWidth - delta,
          fit: BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/itunes1.png',
              width: screenWidth - delta,
              height: screenWidth - delta,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}
