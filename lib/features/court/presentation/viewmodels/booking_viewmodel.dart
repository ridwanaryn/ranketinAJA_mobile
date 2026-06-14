import 'package:flutter/foundation.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingRepository _repository;

  BookingViewModel({BookingRepository? repository})
      : _repository = repository ?? BookingRepository();

  List<BookingModel> _bookings = [];
  List<String> _bookedSlotsForCurrent = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  List<String> get bookedSlotsForCurrent => _bookedSlotsForCurrent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyBookings(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bookings = await _repository.getBookingsForUser(userId);
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
}
