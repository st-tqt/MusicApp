import '../model/user.dart';
import '../source/user_data_source.dart';

class UserRepository {
  final UserDataSource _dataSource = UserDataSource();

  Future<UserModel?> fetchFirstUser() {
    return _dataSource.getFirstUser();
  }

  Future<UserModel?> register(String name, String email, String password) {
    return _dataSource.registerUser(name, email, password);
  }
}
