import 'package:bcrypt/bcrypt.dart';
import '../../../../core/services/supabase_service.dart';

class AuthRemoteDataSource {
  final _client = SupabaseService.client;

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final response = await _client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();
    return response;
  }

  bool verifyPassword(String plain, String hash) {
    final normalized = hash.replaceFirst(r'$2y$', r'$2a$');
    try {
      return BCrypt.checkpw(plain, normalized);
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final hashed = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
    final now = DateTime.now().toUtc().toIso8601String();
    final inserted = await _client.from('users').insert({
      'name': name,
      'email': email,
      'phone': phone,
      'password': hashed,
      'role': role,
      'created_at': now,
      'updated_at': now,
    }).select().single();
    return inserted;
  }
  Future<Map<String, dynamic>> updateUser({
    required int userId,
    required String newName,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    
    // Melakukan update pada tabel 'users'
    final updated = await _client
        .from('users')
        .update({
          'name': newName,
          'updated_at': now,
        })
        .eq('id', userId)
        .select()
        .single();
        
    return updated;
  }
}
