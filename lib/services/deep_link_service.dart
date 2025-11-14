import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/model/user.dart';
import '../ui/user/preview_profile_page.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();

  factory DeepLinkService() => _instance;

  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _appLinks = AppLinks();

    // Listen to deep links khi app đang chạy
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });

    // Handle initial deep link khi app được mở từ link
    _getInitialLink();
  }

  Future<void> _getInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        // Đợi app khởi tạo xong
        await Future.delayed(const Duration(milliseconds: 500));
        _handleDeepLink(uri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('📱 Received deep link: $uri');

    // Parse different types of links
    // Format: musicapp://user/USER_ID
    // Format: https://yourdomain.com/user/USER_ID

    if (uri.pathSegments.isEmpty) return;

    final firstSegment = uri.pathSegments[0];

    switch (firstSegment) {
      case 'user':
        if (uri.pathSegments.length > 1) {
          final userId = uri.pathSegments[1];
          _navigateToUserProfile(userId);
        }
        break;

    // Có thể thêm các route khác
    // case 'playlist':
    //   if (uri.pathSegments.length > 1) {
    //     final playlistId = uri.pathSegments[1];
    //     _navigateToPlaylist(playlistId);
    //   }
    //   break;

      default:
        debugPrint('Unknown deep link path: $firstSegment');
    }
  }

  Future<void> _navigateToUserProfile(String userId) async {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('Navigator context not available');
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
        ),
      ),
    );

    try {
      // Fetch user data từ Supabase
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      // Close loading
      if (_navigatorKey?.currentContext != null) {
        Navigator.of(_navigatorKey!.currentContext!).pop();
      }

      if (response != null) {
        // Parse user data
        final user = UserModel.fromMap(response);

        // Navigate to profile page
        _navigatorKey?.currentState?.push(
          MaterialPageRoute(
            builder: (context) => PreviewProfilePage(
              user: user,
              forceGuestView: true,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading user: $e');

      // Close loading
      if (_navigatorKey?.currentContext != null) {
        Navigator.of(_navigatorKey!.currentContext!).pop();

        // Show error message
        ScaffoldMessenger.of(_navigatorKey!.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải thông tin người dùng'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Thêm method navigate to playlist nếu cần
  // Future<void> _navigateToPlaylist(String playlistId) async {
  //   // Similar to _navigateToUserProfile
  // }

  void dispose() {
    _linkSubscription?.cancel();
  }
}