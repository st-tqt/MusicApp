import 'package:flutter/material.dart';

class SearchTabBar extends StatelessWidget {
  final String currentTab;
  final int songsCount;
  final int playlistsCount;
  final Function(String) onTabChanged;

  const SearchTabBar({
    super.key,
    required this.currentTab,
    required this.songsCount,
    required this.playlistsCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F2E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBB6BD9).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Bài hát ($songsCount)',
              isSelected: currentTab == 'songs',
              onTap: () => onTabChanged('songs'),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'Playlist ($playlistsCount)',
              isSelected: currentTab == 'playlists',
              onTap: () => onTabChanged('playlists'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFBB6BD9)],
          )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(isSelected ? 1.0 : 0.6),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}