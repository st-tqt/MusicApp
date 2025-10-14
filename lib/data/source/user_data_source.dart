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

  Future<UserModel?> registerUser(String name, String email, String password, File? avatarFile) async {
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
      'avatar_url': avatarFile != null ? await uploadAvatar(avatarFile, user.id) : 'https://i.pravatar.cc/150?img=5',
      'role': 'user',
    };

    await supabase.from('users').insert(data);

    return UserModel.fromMap(data);
  }

  Future<String> uploadAvatar(File imageFile, String userId) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName = '$userId.$fileExt';
    final filePath = 'avatars/$fileName';

    await supabase.storage.from('avatars').upload(filePath, imageFile, fileOptions: const FileOptions(upsert: true));

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
    return publicUrl;
  }
}

