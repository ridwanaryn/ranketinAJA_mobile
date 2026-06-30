import '../../../../core/services/supabase_service.dart';

class CourtRemoteDataSource {
  final _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> fetchCourts() async {
    final fields = await _client
        .from('fields')
        .select('*, users!fields_owner_id_fkey(name)')
        .order('id');

    final reviews = await _client.from('reviews').select('field_id, rating');

    final Map<int, List<double>> ratingByField = {};
    for (final r in reviews) {
      final fid = r['field_id'] as int;
      final rating = (r['rating'] as num).toDouble();
      ratingByField.putIfAbsent(fid, () => []).add(rating);
    }

    final List<Map<String, dynamic>> results = [];
    for (final f in fields) {
      final map = Map<String, dynamic>.from(f as Map);
      final fid = map['id'] as int;
      final ratings = ratingByField[fid] ?? [];
      final avg = ratings.isEmpty
          ? 4.8
          : ratings.reduce((a, b) => a + b) / ratings.length;
      map['avg_rating'] = avg;
      map['review_count'] = ratings.length;
      final owner = map['users'];
      if (owner is Map && owner['name'] != null) {
        map['owner_name'] = owner['name'];
      }
      results.add(map);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> fetchCourtsByOwner(int ownerId) async {
    final fields = await _client
        .from('fields')
        .select()
        .eq('owner_id', ownerId)
        .order('id');

    final reviews = await _client.from('reviews').select('field_id, rating');
    final Map<int, List<double>> ratingByField = {};
    for (final r in reviews) {
      final fid = r['field_id'] as int;
      final rating = (r['rating'] as num).toDouble();
      ratingByField.putIfAbsent(fid, () => []).add(rating);
    }

    final List<Map<String, dynamic>> results = [];
    for (final f in fields) {
      final map = Map<String, dynamic>.from(f as Map);
      final fid = map['id'] as int;
      final ratings = ratingByField[fid] ?? [];
      map['avg_rating'] =
          ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
      map['review_count'] = ratings.length;
      results.add(map);
    }
    return results;
  }

  Future<Map<String, dynamic>> createCourt({
    required int ownerId,
    required String name,
    required String sportType,
    required double pricePerHour,
    required int capacity,
    required bool isIndoor,
    required List<String> features,
    required String description,
    required String location,
    String? imageUrl,
    List<String> imageUrls = const [],
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final inserted = await _client.from('fields').insert({
      'owner_id': ownerId,
      'name': name,
      'sport_type': sportType.toLowerCase(),
      'price_per_hour': pricePerHour,
      'capacity': capacity,
      'is_indoor': isIndoor,
      'features': features,
      'description': description,
      'location': location,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'status': 'active',
      'created_at': now,
      'updated_at': now,
    }).select().single();
    return Map<String, dynamic>.from(inserted);
  }

  Future<Map<String, dynamic>> updateCourt({
    required int id,
    required String name,
    required String sportType,
    required double pricePerHour,
    required bool isIndoor,
    required List<String> features,
    required String description,
    required String location,
    String? imageUrl,
    List<String> imageUrls = const [],
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final updated = await _client.from('fields').update({
      'name': name,
      'sport_type': sportType.toLowerCase(),
      'price_per_hour': pricePerHour,
      'is_indoor': isIndoor,
      'features': features,
      'description': description,
      'location': location,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'updated_at': now,
    }).eq('id', id).select().single();
    return Map<String, dynamic>.from(updated);
  }

  Future<void> deleteCourt(int id) async {
    await _client.from('fields').delete().eq('id', id);
  }
}
