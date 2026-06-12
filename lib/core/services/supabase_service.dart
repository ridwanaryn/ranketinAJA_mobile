import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
