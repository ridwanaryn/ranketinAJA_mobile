import '../datasources/booking_remote_datasource.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final BookingRemoteDataSource _remote;
  BookingRepository({BookingRemoteDataSource? remote})
      : _remote = remote ?? BookingRemoteDataSource();

  Future<List<BookingModel>> getBookingsForUser(int userId) async {
    final rows = await _remote.fetchBookingsForUser(userId);
    return rows.map(BookingModel.fromMap).toList();
  }

  Future<List<BookingModel>> getBookingsForOwner(int ownerId) async {
    final rows = await _remote.fetchBookingsForOwner(ownerId);
    return rows.map(BookingModel.fromMap).toList();
  }

  Future<List<String>> getBookedStartTimes(int fieldId, DateTime date) async {
    final rows = await _remote.fetchBookingsForFieldOnDate(fieldId, date);
    return rows.map((r) {
      final s = (r['start_time'] ?? '') as String;
      return s.length >= 5 ? s.substring(0, 5) : s;
    }).toList();
  }

  Future<BookingModel> createBooking({
    required int userId,
    required int fieldId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required double totalPrice,
  }) async {
    final row = await _remote.createBooking(
      userId: userId,
      fieldId: fieldId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      totalPrice: totalPrice,
    );
    return BookingModel.fromMap(row);
  }
}
