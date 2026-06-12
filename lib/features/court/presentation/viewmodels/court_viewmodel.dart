import 'package:flutter/foundation.dart';
import '../../data/models/court_model.dart';
import '../../data/repositories/court_repository.dart';

class CourtViewModel extends ChangeNotifier {
  final CourtRepository _repository;

  CourtViewModel({CourtRepository? repository})
      : _repository = repository ?? CourtRepository();

  List<CourtModel> _courts = [];
  bool _isLoading = false;
  String? _error;

  String _selectedSportTab = 'Padel';
  String _searchQuery = '';

  CourtModel? _selectedCourt;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;

  List<CourtModel> get courts => List.unmodifiable(_courts);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedSportTab => _selectedSportTab;
  String get searchQuery => _searchQuery;
  CourtModel? get selectedCourt => _selectedCourt;
  DateTime get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;

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
  }

  double getSubtotal() {
    if (_selectedCourt == null) return 0.0;
    return _selectedCourt!.pricePerHour * 2;
  }

  double getServiceFee() => 5.50;

  double getDiscount() => getSubtotal() * 0.10;

  double calculateTotalDue() =>
      getSubtotal() + getServiceFee() - getDiscount();
}
