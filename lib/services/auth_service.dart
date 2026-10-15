import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storage = StorageService();

  Future<User?> login(String username, String password) async {
    final users = await _storage.getUsers();
    try {
      return users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async => _storage.saveSession(null);

  Future<User?> getCurrentUser() async => _storage.getSession();
}
