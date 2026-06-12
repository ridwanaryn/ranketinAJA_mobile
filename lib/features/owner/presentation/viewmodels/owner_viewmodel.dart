import 'package:flutter/foundation.dart';
import '../../../court/data/models/booking_model.dart';
import '../../../court/data/models/court_model.dart';
import '../../../court/data/repositories/booking_repository.dart';
import '../../../court/data/repositories/court_repository.dart';

class OwnerViewModel extends ChangeNotifier {
  final CourtRepository _courtRepository;
  final BookingRepository _bookingRepository;

  OwnerViewModel({
    CourtRepository? courtRepository,
    BookingRepository? bookingRepository,
  })  : _courtRepository = courtRepository ?? CourtRepository(),
        _bookingRepository = bookingRepository ?? BookingRepository();

  List<CourtModel> _ownedCourts = [];
  List<BookingModel> _ownerBookings = [];
  bool _isLoading = false;
  String? _error;

  List<CourtModel> get ownedCourts => List.unmodifiable(_ownedCourts);
  List<BookingModel> get ownerBookings => List.unmodifiable(_ownerBookings);
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalRevenue =>
      _ownerBookings.fold(0.0, (sum, b) => sum + b.totalPrice);

  int get activeBookingsCount =>
      _ownerBookings.where((b) => b.status == 'confirmed').length;

  List<Map<String, dynamic>> get recentActivities {
    return _ownerBookings.take(6).map((b) {
      return {
        'type': 'booking',
        'title': 'New Booking: ${b.courtName ?? 'Court #${b.fieldId}'}',
        'subtitle': '${_formatDate(b.bookingDate)} • ${b.timeSlot}',
        'amount': '+\$${b.totalPrice.toStringAsFixed(2)}',
        'status': b.status == 'confirmed' ? 'Completed' : b.status,
      };
    }).toList();
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<void> loadOwnerData(int ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _ownedCourts = await _courtRepository.getCourtsByOwner(ownerId);
      _ownerBookings = await _bookingRepository.getBookingsForOwner(ownerId);
    } catch (e) {
      _error = 'Gagal memuat data owner: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCourt({
    required int ownerId,
    required String name,
    required String sportType,
    required double price,
    required String location,
    required String description,
    required List<String> features,
    required bool isIndoor,
  }) async {
    try {
      final created = await _courtRepository.createCourt(
        ownerId: ownerId,
        name: name,
        sportType: sportType,
        pricePerHour: price,
        location: location,
        description: description,
        features: features,
        isIndoor: isIndoor,
      );
      _ownedCourts.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menambah court: $e';
      notifyListeners();
      return false;
    }
  }
}
