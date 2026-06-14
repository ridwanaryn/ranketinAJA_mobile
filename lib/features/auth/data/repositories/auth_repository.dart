import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel? user;
  final String? error;
  AuthResult({this.user, this.error});
  bool get isSuccess => user != null;
}

class AuthRepository {
  final AuthRemoteDataSource _remote;
  AuthRepository({AuthRemoteDataSource? remote})
      : _remote = remote ?? AuthRemoteDataSource();

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final row = await _remote.findUserByEmail(email);
      if (row == null) {
        return AuthResult(error: 'Email tidak terdaftar');
      }
      final hash = (row['password'] ?? '') as String;
      if (!_remote.verifyPassword(password, hash)) {
        return AuthResult(error: 'Password salah');
      }
      return AuthResult(user: UserModel.fromMap(row));
    } catch (e) {
      return AuthResult(error: 'Gagal login: $e');
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final existing = await _remote.findUserByEmail(email);
      if (existing != null) {
        return AuthResult(error: 'Email sudah terdaftar');
      }
      final row = await _remote.createUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      return AuthResult(user: UserModel.fromMap(row));
    } catch (e) {
      return AuthResult(error: 'Gagal mendaftar: $e');
    }
  }
  Future<AuthResult> updateName({
    required int userId,
    required String newName,
  }) async {
    try {
      // PERHATIAN: Anda juga harus membuat fungsi updateUser di AuthRemoteDataSource
      final row = await _remote.updateUser(
        userId: userId,
        newName: newName,
      );
      return AuthResult(user: UserModel.fromMap(row));
    } catch (e) {
      return AuthResult(error: 'Gagal memperbarui profil: $e');
    }
  }
}
