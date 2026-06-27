import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class ImageUploadService {
  static const String bucketName = 'court-images';

  static String _safeName(String original) {
    final lower = original.toLowerCase();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9._-]'), '_');
    return cleaned.length > 80 ? cleaned.substring(cleaned.length - 80) : cleaned;
  }

  static String _guessContentType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  /// Uploads bytes to the court-images bucket and returns the public URL.
  /// Throws on failure.
  static Future<String> uploadBytes({
    required int ownerId,
    required String filename,
    required Uint8List bytes,
  }) async {
    final client = SupabaseService.client;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'owner_$ownerId/${timestamp}_${_safeName(filename)}';

    await client.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _guessContentType(filename),
            upsert: true,
          ),
        );

    return client.storage.from(bucketName).getPublicUrl(path);
  }

  /// Best-effort delete of a public URL belonging to the court-images bucket.
  /// Returns true if removed, false otherwise.
  static Future<bool> deleteByPublicUrl(String publicUrl) async {
    try {
      final marker = '/object/public/$bucketName/';
      final idx = publicUrl.indexOf(marker);
      if (idx < 0) return false;
      final path = publicUrl.substring(idx + marker.length);
      await SupabaseService.client.storage.from(bucketName).remove([path]);
      return true;
    } catch (_) {
      return false;
    }
  }
}
