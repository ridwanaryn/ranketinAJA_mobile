import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _kUserId = 'session_user_id';
  static const _kUserEmail = 'session_user_email';
  static const _kUserName = 'session_user_name';
  static const _kUserRole = 'session_user_role';

  Future<void> saveSession({
    required int userId,
    required String email,
    required String name,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUserId, userId);
    await prefs.setString(_kUserEmail, email);
    await prefs.setString(_kUserName, name);
    await prefs.setString(_kUserRole, role);
  }

  Future<Map<String, dynamic>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_kUserId);
    if (id == null) return null;
    return {
      'id': id,
      'email': prefs.getString(_kUserEmail) ?? '',
      'name': prefs.getString(_kUserName) ?? '',
      'role': prefs.getString(_kUserRole) ?? 'player',
    };
  }
  
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
    await prefs.remove(_kUserEmail);
    await prefs.remove(_kUserName);
    await prefs.remove(_kUserRole);
  }
}
