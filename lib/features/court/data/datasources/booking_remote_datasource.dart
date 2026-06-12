import '../../../../core/services/supabase_service.dart';

class BookingRemoteDataSource {
  final _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> fetchBookingsForUser(int userId) async {
    final result = await _client
        .from('bookings')
        .select('*, fields(name, image_url)')
        .eq('user_id', userId)
        .order('booking_date', ascending: false);
    return List<Map<String, dynamic>>.from(
      result.map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<List<Map<String, dynamic>>> fetchBookingsForOwner(int ownerId) async {
    final fields = await _client
        .from('fields')
        .select('id')
        .eq('owner_id', ownerId);
    final ids = fields.map((e) => e['id'] as int).toList();
    if (ids.isEmpty) return [];
    final result = await _client
        .from('bookings')
        .select('*, fields(name, image_url, sport_type, owner_id)')
        .inFilter('field_id', ids)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(
      result.map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<List<Map<String, dynamic>>> fetchBookingsForFieldOnDate(
    int fieldId,
    DateTime date,
  ) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final result = await _client
        .from('bookings')
        .select('start_time, end_time')
        .eq('field_id', fieldId)
        .eq('booking_date', dateStr);
    return List<Map<String, dynamic>>.from(
      result.map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<Map<String, dynamic>> createBooking({
    required int userId,
    required int fieldId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required double totalPrice,
  }) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final now = DateTime.now().toUtc().toIso8601String();
    final inserted = await _client.from('bookings').insert({
      'user_id': userId,
      'field_id': fieldId,
      'booking_date': dateStr,
      'start_time': startTime,
      'end_time': endTime,
      'total_price': totalPrice,
      'status': 'confirmed',
      'created_at': now,
      'updated_at': now,
    }).select('*, fields(name, image_url)').single();
    return Map<String, dynamic>.from(inserted);
  }
}
