import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user.dart';

class UserDataSource {
  final supabase = Supabase.instance.client;

  Future<UserModel?> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<UserModel?> registerUser(
    String name,
    String email,
    String password,
    File? avatarFile,
  ) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) return null;

    // insert vào bảng users
    final data = {
      'id': user.id,
      'name': name,
      'email': email,
      'avatar_url': avatarFile != null
          ? await uploadAvatar(avatarFile, user.id)
          : 'https://i.pravatar.cc/150?img=5',
      'role': 'user',
    };

    await supabase.from('users').insert(data);

    return UserModel.fromMap(data);
  }

  Future<UserModel?> updateUser(
    String userId,
    String name,
    File? avatarFile,
  ) async {
    String? newAvatarUrl;

    if (avatarFile != null) {
      newAvatarUrl = await uploadAvatar(avatarFile, userId);
    }

    final data = <String, dynamic>{'name': name};

    if (newAvatarUrl != null) {
      data['avatar_url'] = newAvatarUrl;
    }

    await supabase.from('users').update(data).eq('id', userId);

    final response = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<String> uploadAvatar(File imageFile, String userId) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName = '$userId.$fileExt';
    final filePath = 'avatars/$fileName';

    try {
      final extensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      for (var ext in extensions) {
        if (ext != fileExt) {
          try {
            await supabase.storage
                .from('avatars')
                .remove(['avatars/$userId.$ext']);
          } catch (e) {
            // File không tồn tại, bỏ qua
          }
        }
      }
    } catch (e) {
      print('Error cleaning old avatars: $e');
    }

    await supabase.storage
        .from('avatars')
        .upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    // Thêm timestamp để bypass cache
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final publicUrl = supabase.storage
        .from('avatars')
        .getPublicUrl(filePath);

    return '$publicUrl?t=$timestamp';
  }
}
