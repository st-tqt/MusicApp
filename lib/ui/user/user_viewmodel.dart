
import 'dart:async';
import 'dart:io';

import '../../data/model/user.dart';
import '../../data/repository/user_repository.dart';

class UserViewModel {
  final UserRepository _repository = UserRepository();
  final StreamController<UserModel?> userStream =
  StreamController<UserModel?>.broadcast();

  loadCurrentUser() async {
    final user = await _repository.fetchCurrentUser();
    userStream.add(user);
  }

  Future<UserModel?> updateUser(String userId, String name, File? avatarFile) async {
    try {
      final updatedUser = await _repository.updateUser(userId, name, avatarFile);
      if (updatedUser != null) {
        userStream.add(updatedUser);
      }
      return updatedUser;
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  void dispose() {
    userStream.close();
  }
}