class CourtModel {
  final String id;
  final String name;
  final String sportType; // Padel, Tennis, Badminton, Football
  final double pricePerHour;
  final double rating;
  final int reviewsCount;
  final String distance;
  final String locationName;
  final String imageUrl;
  final List<String> tags;
  final String description;
  final String ownerName;
  final String ownerImageUrl;

  CourtModel({
    required this.id,
    required this.name,
    required this.sportType,
    required this.pricePerHour,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.locationName,
    required this.imageUrl,
    required this.tags,
    required this.description,
    required this.ownerName,
    required this.ownerImageUrl,
  });
}
