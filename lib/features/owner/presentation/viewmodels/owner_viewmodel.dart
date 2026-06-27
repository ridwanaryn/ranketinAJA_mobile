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
  String _searchQuery = '';

  List<CourtModel> get ownedCourts => List.unmodifiable(_ownedCourts);
  List<CourtModel> get filteredCourts {
    if (_searchQuery.trim().isEmpty) return ownedCourts;
    final q = _searchQuery.toLowerCase();
    return _ownedCourts.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q) ||
          c.sportType.toLowerCase().contains(q);
    }).toList();
  }

  List<BookingModel> get ownerBookings => List.unmodifiable(_ownerBookings);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

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

  /// Monthly revenue for the last 6 months (oldest -> newest).
  /// Each entry: { 'label': 'Jan', 'year': 2026, 'month': 1, 'total': 1234.56 }
  List<Map<String, dynamic>> get monthlyRevenue {
    final now = DateTime.now();
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final List<Map<String, dynamic>> buckets = [];
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      buckets.add({
        'label': monthNames[m.month - 1],
        'year': m.year,
        'month': m.month,
        'total': 0.0,
      });
    }
    for (final b in _ownerBookings) {
      for (final bucket in buckets) {
        if (b.bookingDate.year == bucket['year'] &&
            b.bookingDate.month == bucket['month']) {
          bucket['total'] = (bucket['total'] as double) + b.totalPrice;
          break;
        }
      }
    }
    return buckets;
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
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
    List<String> imageUrls = const [],
  }) async {
    try {
      final primaryImage = imageUrls.isNotEmpty ? imageUrls.first : null;
      final created = await _courtRepository.createCourt(
        ownerId: ownerId,
        name: name,
        sportType: sportType,
        pricePerHour: price,
        location: location,
        description: description,
        features: features,
        isIndoor: isIndoor,
        imageUrl: primaryImage,
        imageUrls: imageUrls,
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

  Future<bool> updateCourt({
    required int id,
    required String name,
    required String sportType,
    required double price,
    required String location,
    required String description,
    required List<String> features,
    required bool isIndoor,
    List<String> imageUrls = const [],
  }) async {
    try {
      final primaryImage = imageUrls.isNotEmpty ? imageUrls.first : null;
      final updated = await _courtRepository.updateCourt(
        id: id,
        name: name,
        sportType: sportType,
        pricePerHour: price,
        location: location,
        description: description,
        features: features,
        isIndoor: isIndoor,
        imageUrl: primaryImage,
        imageUrls: imageUrls,
      );
      final idx = _ownedCourts.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _ownedCourts[idx] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengubah court: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourt(int id) async {
    try {
      await _courtRepository.deleteCourt(id);
      _ownedCourts.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus court: $e';
      notifyListeners();
      return false;
    }
  }
}
