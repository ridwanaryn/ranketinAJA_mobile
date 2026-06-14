class BookingModel {
  final int id;
  final int userId;
  final int fieldId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double totalPrice;
  final String status;

  final String? courtName;
  final String? courtImageUrl;

  BookingModel({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.courtName,
    this.courtImageUrl,
  });

  String get timeSlot {
    return '${_short(startTime)} - ${_short(endTime)}';
  }

  String _short(String t) {
    if (t.length >= 5) return t.substring(0, 5);
    return t;
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final field = map['fields'] is Map ? map['fields'] as Map : null;
    return BookingModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      fieldId: map['field_id'] as int,
      bookingDate: DateTime.parse(map['booking_date'] as String),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      totalPrice: _parseDouble(map['total_price']),
      status: (map['status'] ?? 'confirmed') as String,
      courtName: field != null ? field['name'] as String? : null,
      courtImageUrl: field != null ? field['image_url'] as String? : null,
    );
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
