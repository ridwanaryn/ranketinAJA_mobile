import 'package:flutter/foundation.dart';
import '../../data/models/court_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/court_repository.dart';
import '../../data/repositories/review_repository.dart';

class CourtViewModel extends ChangeNotifier {
  final CourtRepository _repository;
  final ReviewRepository _reviewRepository;

  CourtViewModel({
    CourtRepository? repository,
    ReviewRepository? reviewRepository,
  })  : _repository = repository ?? CourtRepository(),
        _reviewRepository = reviewRepository ?? ReviewRepository();

  List<CourtModel> _courts = [];
  bool _isLoading = false;
  String? _error;

  String _selectedSportTab = 'Padel';
  String _searchQuery = '';

  CourtModel? _selectedCourt;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;

  List<ReviewModel> _reviewsForSelected = [];
  bool _isLoadingReviews = false;

  List<CourtModel> get courts => List.unmodifiable(_courts);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedSportTab => _selectedSportTab;
  String get searchQuery => _searchQuery;
  CourtModel? get selectedCourt => _selectedCourt;
  DateTime get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;

  List<ReviewModel> get reviewsForSelected =>
      List.unmodifiable(_reviewsForSelected);
  bool get isLoadingReviews => _isLoadingReviews;

  double get selectedAvgRating {
    if (_reviewsForSelected.isEmpty) return 0.0;
    final sum = _reviewsForSelected.fold<double>(0, (s, r) => s + r.rating);
    return sum / _reviewsForSelected.length;
  }

  List<CourtModel> get filteredCourts {
    return _courts.where((c) {
      final matchesTab =
          c.sportType.toLowerCase() == _selectedSportTab.toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q);
      return matchesTab && matchesSearch;
    }).toList();
  }

  Future<void> loadCourts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _courts = await _repository.getCourts();
    } catch (e) {
      _error = 'Gagal memuat data court: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReviewsForSelected() async {
    final court = _selectedCourt;
    if (court == null) {
      _reviewsForSelected = [];
      notifyListeners();
      return;
    }
    _isLoadingReviews = true;
    notifyListeners();
    try {
      _reviewsForSelected =
          await _reviewRepository.getReviewsForField(court.id);
    } catch (_) {
      _reviewsForSelected = [];
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  void setSportTab(String tab) {
    _selectedSportTab = tab;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCourt(CourtModel court) {
    _selectedCourt = court;
    _selectedTimeSlot = null;
    _reviewsForSelected = [];
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedTimeSlot = null;
    notifyListeners();
  }

  void selectTimeSlot(String slot) {
    _selectedTimeSlot = slot;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCourt = null;
    _selectedTimeSlot = null;
    _reviewsForSelected = [];
  }

  double getSubtotal() {
    if (_selectedCourt == null) return 0.0;
    return _selectedCourt!.pricePerHour * 2;
  }

  double getServiceFee() => 5.50;

  double calculateTotalDue() => getSubtotal() + getServiceFee();
}
