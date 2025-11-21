import 'package:flutter/material.dart';
import '../../../../data/model/user.dart';

class ProfileActionButtons extends StatelessWidget {
  final bool isMyProfile;
  final bool isFollowing;
  final bool isFollowLoading;
  final VoidCallback onEditProfile;
  final VoidCallback onToggleFollow;
  final VoidCallback onMoreOptions;

  const ProfileActionButtons({
    super.key,
    required this.isMyProfile,
    required this.isFollowing,
    required this.isFollowLoading,
    required this.onEditProfile,
    required this.onToggleFollow,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: isMyProfile ? _buildEditProfileButton() : _buildFollowButton(),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF6B9D).withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEditProfile,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Chỉnh sửa hồ sơ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildMoreOptionsButton(),
      ],
    );
  }

  Widget _buildFollowButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isFollowing
                  ? null
                  : const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              color: isFollowing ? Colors.white.withOpacity(0.1) : null,
              border: isFollowing
                  ? Border.all(
                color: const Color(0xFFFF6B9D).withOpacity(0.4),
                width: 1.5,
              )
                  : null,
              boxShadow: isFollowing
                  ? null
                  : [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isFollowLoading ? null : onToggleFollow,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: isFollowLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildMoreOptionsButton(),
      ],
    );
  }

  Widget _buildMoreOptionsButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFBB6BD9).withOpacity(0.4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onMoreOptions,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.9)),
          ),
        ),
      ),
    );
  }
}