class BookingModel {
  final String id;
  final String courtId;
  final String courtName;
  final String courtImageUrl;
  final DateTime date;
  final String timeSlot;
  final double totalPrice;
  final bool isCompleted;

  BookingModel({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.courtImageUrl,
    required this.date,
    required this.timeSlot,
    required this.totalPrice,
    this.isCompleted = false,
  });
}
