import 'package:flutter/foundation.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/review_repository.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingRepository _repository;
  final ReviewRepository _reviewRepository;

  BookingViewModel({
    BookingRepository? repository,
    ReviewRepository? reviewRepository,
  })  : _repository = repository ?? BookingRepository(),
        _reviewRepository = reviewRepository ?? ReviewRepository();

  List<BookingModel> _bookings = [];
  List<String> _bookedSlotsForCurrent = [];
  bool _isLoading = false;
  String? _error;
  final Map<int, ReviewModel> _reviewsByBookingId = {};

  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  List<String> get bookedSlotsForCurrent => _bookedSlotsForCurrent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReviewModel? reviewForBooking(int bookingId) =>
      _reviewsByBookingId[bookingId];
  bool hasReview(int bookingId) =>
      _reviewsByBookingId.containsKey(bookingId);

  Future<void> loadMyBookings(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bookings = await _repository.getBookingsForUser(userId);
      final reviews = await _reviewRepository.getReviewsForUser(userId);
      _reviewsByBookingId
        ..clear()
        ..addEntries(reviews.map((r) => MapEntry(r.bookingId, r)));
    } catch (e) {
      _error = 'Gagal memuat booking: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookedSlots(int fieldId, DateTime date) async {
    try {
      _bookedSlotsForCurrent =
          await _repository.getBookedStartTimes(fieldId, date);
      notifyListeners();
    } catch (e) {
      _bookedSlotsForCurrent = [];
    }
  }

  bool isSlotBooked(String hhmm) {
    return _bookedSlotsForCurrent.contains(hhmm);
  }

  Future<BookingModel?> confirmBooking({
    required int userId,
    required int fieldId,
    required DateTime date,
    required String startHHMM,
    required double totalPrice,
  }) async {
    try {
      final startTime = '$startHHMM:00';
      final hour = int.parse(startHHMM.split(':')[0]);
      final endHour = (hour + 2) % 24;
      final endTime =
          '${endHour.toString().padLeft(2, '0')}:${startHHMM.split(':')[1]}:00';
      final created = await _repository.createBooking(
        userId: userId,
        fieldId: fieldId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        totalPrice: totalPrice,
      );
      _bookings.insert(0, created);
      _bookedSlotsForCurrent.add(startHHMM);
      notifyListeners();
      return created;
    } catch (e) {
      _error = 'Gagal membuat booking: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> submitReview({
    required BookingModel booking,
    required double rating,
    String? review,
  }) async {
    try {
      final created = await _reviewRepository.submitReview(
        bookingId: booking.id,
        userId: booking.userId,
        fieldId: booking.fieldId,
        rating: rating,
        review: review,
      );
      _reviewsByBookingId[booking.id] = created;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengirim review: $e';
      notifyListeners();
      return false;
    }
  }
}
