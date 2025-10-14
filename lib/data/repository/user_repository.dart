import 'dart:io';

import '../model/user.dart';
import '../source/user_data_source.dart';

class UserRepository {
  final UserDataSource _dataSource = UserDataSource();

  Future<UserModel?> fetchCurrentUser() {
    return _dataSource.getCurrentUser();
  }

  Future<UserModel?> register(String name, String email, String password, File? avatarFile) {
    return _dataSource.registerUser(name, email, password, avatarFile);
  }
}
