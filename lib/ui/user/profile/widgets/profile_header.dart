import 'package:flutter/material.dart';
import '../../../../data/model/user.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final int followersCount;
  final int followingCount;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.followersCount,
    required this.followingCount,
    required this.onFollowersTap,
    required this.onFollowingTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0A0118),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A0F2E).withOpacity(0.8),
                const Color(0xFF0A0118),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildAvatar(),
                const SizedBox(height: 16),
                _buildUserName(),
                const SizedBox(height: 8),
                _buildFollowStats(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFF0A0118),
          child: CircleAvatar(
            radius: 56,
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
            backgroundColor: const Color(0xFF1A0F2E),
            child: user.avatarUrl.isEmpty
                ? Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildUserName() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
      ).createShader(bounds),
      child: Text(
        user.name,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFollowStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onFollowersTap,
          child: Text(
            '$followersCount người theo dõi',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '•',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ),
        GestureDetector(
          onTap: onFollowingTap,
          child: Text(
            'Đang theo dõi $followingCount',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}