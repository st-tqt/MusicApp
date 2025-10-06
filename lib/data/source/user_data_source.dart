import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user.dart';

class UserDataSource {
  final supabase = Supabase.instance.client;

  Future<UserModel?> getFirstUser() async {
    final response = await supabase
        .from('users')
        .select()
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<UserModel?> registerUser(String name, String email, String password) async {
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
      'avatar_url': "https://i.pravatar.cc/150?img=5",
      'role': 'user',
    };

    await supabase.from('users').insert(data);

    return UserModel.fromMap(data);
  }
}

