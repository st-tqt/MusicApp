import 'package:flutter/material.dart';

class SearchEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color borderColor;

  const SearchEmptyState({
    super.key,
    this.icon = Icons.music_note_rounded,
    this.title = 'Tìm kiếm bài hát yêu thích',
    this.subtitle = 'Nhập tên bài hát, nghệ sĩ hoặc playlist',
    this.borderColor = const Color(0xFFBB6BD9),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconCircle(),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCircle() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A0F2E).withOpacity(0.5),
            const Color(0xFF2D1B47).withOpacity(0.3),
          ],
        ),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 2),
      ),
      child: Icon(icon, size: 64, color: Colors.white.withOpacity(0.4)),
    );
  }
}