class CourtModel {
  final int id;
  final int ownerId;
  final String name;
  final String sportType;
  final double pricePerHour;
  final int capacity;
  final bool isIndoor;
  final List<String> features;
  final String? description;
  final String location;
  final String? imageUrl;
  final String status;

  final double rating;
  final int reviewsCount;
  final String ownerName;
  final String? ownerImageUrl;

  CourtModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.sportType,
    required this.pricePerHour,
    required this.capacity,
    required this.isIndoor,
    required this.features,
    this.description,
    required this.location,
    this.imageUrl,
    required this.status,
    this.rating = 4.8,
    this.reviewsCount = 0,
    this.ownerName = 'Owner',
    this.ownerImageUrl,
  });

  String get displaySport {
    if (sportType.isEmpty) return sportType;
    return sportType[0].toUpperCase() + sportType.substring(1);
  }

  List<String> get tags {
    if (features.isNotEmpty) return features;
    return [isIndoor ? 'Indoor' : 'Outdoor'];
  }

  String get displayImageUrl =>
      imageUrl ?? 'https://placehold.co/600x400/png?text=Court';

  String get distance => '0.0 miles away';
  String get locationName => location;

  factory CourtModel.fromMap(Map<String, dynamic> map) {
    final featuresRaw = map['features'];
    final List<String> features;
    if (featuresRaw is List) {
      features = featuresRaw.map((e) => e.toString()).toList();
    } else {
      features = [];
    }
    return CourtModel(
      id: map['id'] as int,
      ownerId: map['owner_id'] as int,
      name: (map['name'] ?? '') as String,
      sportType: (map['sport_type'] ?? '') as String,
      pricePerHour: _parseDouble(map['price_per_hour']),
      capacity: (map['capacity'] ?? 0) as int,
      isIndoor: (map['is_indoor'] ?? false) as bool,
      features: features,
      description: map['description'] as String?,
      location: (map['location'] ?? '') as String,
      imageUrl: map['image_url'] as String?,
      status: (map['status'] ?? 'active') as String,
      rating: _parseDouble(map['avg_rating'], fallback: 4.8),
      reviewsCount: (map['review_count'] ?? 0) as int,
      ownerName: (map['owner_name'] ?? 'Owner') as String,
      ownerImageUrl: map['owner_image_url'] as String?,
    );
  }

  static double _parseDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }
}
