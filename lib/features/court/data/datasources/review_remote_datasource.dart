import '../../../../core/services/supabase_service.dart';

class ReviewRemoteDataSource {
  final _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> fetchReviewsForUser(int userId) async {
    final result = await _client
        .from('reviews')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(
      result.map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<List<Map<String, dynamic>>> fetchReviewsForField(int fieldId) async {
    final result = await _client
        .from('reviews')
        .select('*, users!reviews_user_id_fkey(name)')
        .eq('field_id', fieldId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(
      result.map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<Map<String, dynamic>?> fetchReviewForBooking(int bookingId) async {
    final result = await _client
        .from('reviews')
        .select()
        .eq('booking_id', bookingId)
        .maybeSingle();
    if (result == null) return null;
    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>> upsertReview({
    required int bookingId,
    required int userId,
    required int fieldId,
    required double rating,
    String? review,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final existing = await fetchReviewForBooking(bookingId);
    final payload = {
      'booking_id': bookingId,
      'user_id': userId,
      'field_id': fieldId,
      'rating': rating,
      'review': review,
      'updated_at': now,
    };
    if (existing == null) {
      payload['created_at'] = now;
      final inserted = await _client
          .from('reviews')
          .insert(payload)
          .select()
          .single();
      return Map<String, dynamic>.from(inserted);
    } else {
      final updated = await _client
          .from('reviews')
          .update(payload)
          .eq('id', existing['id'] as int)
          .select()
          .single();
      return Map<String, dynamic>.from(updated);
    }
  }
}
