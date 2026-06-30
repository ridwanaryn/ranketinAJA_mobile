class ReviewModel {
  final int id;
  final int bookingId;
  final int userId;
  final int fieldId;
  final double rating;
  final String? review;
  final DateTime? createdAt;
  final String? userName;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.fieldId,
    required this.rating,
    this.review,
    this.createdAt,
    this.userName,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    final user = map['users'] is Map ? map['users'] as Map : null;
    return ReviewModel(
      id: map['id'] as int,
      bookingId: map['booking_id'] as int,
      userId: map['user_id'] as int,
      fieldId: map['field_id'] as int,
      rating: _parseDouble(map['rating']),
      review: map['review'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      userName: user != null ? user['name'] as String? : null,
    );
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
