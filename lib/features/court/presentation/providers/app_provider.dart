import 'package:flutter/material.dart';
import '../../data/models/court_model.dart';
import '../../data/models/booking_model.dart';

class AppProvider extends ChangeNotifier {
  // Authentication State
  bool _isAuthenticated = false;
  String _userRole = 'player'; // 'player' or 'owner'
  String _userName = '';
  String _userEmail = '';

  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;
  String get userName => _userName;
  String get userEmail => _userEmail;

  // Selected Court for Booking Flow
  CourtModel? _selectedCourt;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;

  CourtModel? get selectedCourt => _selectedCourt;
  DateTime get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;

  // Search & Filtering State
  String _selectedSportTab = 'Padel'; // Padel, Tennis, Badminton, Football
  String _searchQuery = '';

  String get selectedSportTab => _selectedSportTab;
  String get searchQuery => _searchQuery;

  // Mock Database lists
  final List<CourtModel> _courts = [
    CourtModel(
      id: 'court_1',
      name: 'Apex Padel Center',
      sportType: 'Padel',
      pricePerHour: 45.0,
      rating: 4.9,
      reviewsCount: 84,
      distance: '0.8 miles away',
      locationName: 'Chamartín, Madrid',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBrm3ei7dGJaSUfJOZ1EQz_8zS_t1X3miNBn8pkVqEnD8ScqDhylxZms6iya5Uz3caoJfJcz5FtaZ77ncDNr-n6clfC1YntAaUUpHeBn6OA9Dym35Gur7aGARZStp4d2GZPUKOBfwVFle3GxX-21i_AgcOJipsiG_UU-LwnhRsJqgZOPRXHiFscfJZOm_KCm06JH3KNXfO95OFOXx9vIX_dBUd37mO1qFxQwNRvvwDcxtN2S8FB3SGWGGyWwZb0z_z8zyIYE7VCnA',
      tags: ['Indoor', 'Pro-Turf'],
      description: 'Engineered for peak performance. Featuring state of the art blue indoor padel turf with architectural high ceilings and professional glass walls. Perfect bounce guaranteed.',
      ownerName: 'Marcus Thorne',
      ownerImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDegK-4yDQDw8UprTtHt093TVvQH0_iIVApyXWw-X9pJEfZzc998rGSqR287JxywroMXyHm14rtx3Da2scLU2Wme6SOc_S29RjJ3Zf1JpHNd5tljtfal7uDjTMIPLU48ZWE6clCRD25akvd_zuiekO7s_SKV_cZdMUd6rpuNuttFPGHIJLokhvvrLAuST_fIeCcQU5dIKHZ9szQaR3l4wKU7s5kl-kW4UpBgSrnLkCqFgKI4sZM_OwWA8bG4qwczygmzzjabFuqbQ',
    ),
    CourtModel(
      id: 'court_2',
      name: 'The Royal Grass Club',
      sportType: 'Tennis',
      pricePerHour: 60.0,
      rating: 5.0,
      reviewsCount: 142,
      distance: '2.4 miles away',
      locationName: 'Salamanca, Madrid',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDxYrQspsOzVuXx-t2ZxiFakKuY6bcGUdTV-6_52mQMzT4tqIN-c3go2RNwtFJxJE04VQHnsJsGFxEOmZ6Rhg7NBvQH-kDVcT3udjL6seRFzHFxblwDyu2IojnKazYOW-gIQy4soeCqrNuIVV1_i7eKMC9JbdG2fRbtcsxbqo5xNPJYD9T9UVpYgCzUOuM-Y1cfoEnNMavZP9Zwa4hXSvEXn0WPPeac8I1KLF_-vkYD0mS67iuvRIverOFsQAJKc2sv5GFYM9MJGA',
      tags: ['Outdoor', 'Cafe Access'],
      description: 'Elite outdoor red clay courts surrounded by lush green hills. Features a full service sports cafe, locker rooms, and spectator seating. Host of the regional clay court series.',
      ownerName: 'Marcus Thorne',
      ownerImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDegK-4yDQDw8UprTtHt093TVvQH0_iIVApyXWw-X9pJEfZzc998rGSqR287JxywroMXyHm14rtx3Da2scLU2Wme6SOc_S29RjJ3Zf1JpHNd5tljtfal7uDjTMIPLU48ZWE6clCRD25akvd_zuiekO7s_SKV_cZdMUd6rpuNuttFPGHIJLokhvvrLAuST_fIeCcQU5dIKHZ9szQaR3l4wKU7s5kl-kW4UpBgSrnLkCqFgKI4sZM_OwWA8bG4qwczygmzzjabFuqbQ',
    ),
    CourtModel(
      id: 'court_3',
      name: 'Velocity Sports Hall',
      sportType: 'Badminton',
      pricePerHour: 30.0,
      rating: 4.7,
      reviewsCount: 65,
      distance: '1.5 miles away',
      locationName: 'Tetuán, Madrid',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBvDXz1-96JVcE5N6SJdnfEUXN4nsM5xvioh_h4Ybmp3NBTVUEQZssEK8AwEbZr_v9-FPuCusse-a4eVL7KgjrVmfgN-eIdB0ge83P_o8txe6uc15dU8k-eH3pWkTI4_Ix8SsFJqTG2GQQosmxP4SEaHiHJQg-vzgZeuYEdjv12TlWzjx5IFdE9d6N5ZDYXsQgajHpuoKnF2mCu_bWFASPlX8_wLukEOYxu3VO3w9u3geobWhum4Nv_mIAuog_5nGHRiKxENSBAoA',
      tags: ['Multi-sport', 'Locker Rooms'],
      description: 'Professional indoor badminton courts with high coefficient friction green flooring. High speed ventilation and non-glare overhead lighting systems ensure premium athletic performance.',
      ownerName: 'Marcus Thorne',
      ownerImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDegK-4yDQDw8UprTtHt093TVvQH0_iIVApyXWw-X9pJEfZzc998rGSqR287JxywroMXyHm14rtx3Da2scLU2Wme6SOc_S29RjJ3Zf1JpHNd5tljtfal7uDjTMIPLU48ZWE6clCRD25akvd_zuiekO7s_SKV_cZdMUd6rpuNuttFPGHIJLokhvvrLAuST_fIeCcQU5dIKHZ9szQaR3l4wKU7s5kl-kW4UpBgSrnLkCqFgKI4sZM_OwWA8bG4qwczygmzzjabFuqbQ',
    ),
    CourtModel(
      id: 'court_4',
      name: 'Urban Padel Hub',
      sportType: 'Padel',
      pricePerHour: 38.0,
      rating: 4.8,
      reviewsCount: 93,
      distance: '3.1 miles away',
      locationName: 'Arganzuela, Madrid',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDX0PXrrrFOFDPJ-NvqDHELTK1OIKVTnyS-P4wgRe4BkWRSklr6BR3kIpPlOtGzjovfEsSd6S29laUBTOCiCdKkxlNCBM75QDnqWGqY4z7TWayeQPF9UgcZ9on8JlCYGczS92w2qQ0fApGVtQfQHaGuU3a-ZTQ9OSBNZwzwHoP7VMSPNmhM1mKbJg8LqCI8KyoikoREz36FfgR8s1ui-2goIb5bkDRteiAXXq_yLcR4ZO3tY2PLSF6jXQ1bExSEzxF-9s3BVBWUng',
      tags: ['24/7 Access', 'Parking'],
      description: 'Multiple outdoor padel courts featuring high intensity LED floodlights for nighttime matches. Includes secure onsite parking and keyless mobile check-in access.',
      ownerName: 'Marcus Thorne',
      ownerImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDegK-4yDQDw8UprTtHt093TVvQH0_iIVApyXWw-X9pJEfZzc998rGSqR287JxywroMXyHm14rtx3Da2scLU2Wme6SOc_S29RjJ3Zf1JpHNd5tljtfal7uDjTMIPLU48ZWE6clCRD25akvd_zuiekO7s_SKV_cZdMUd6rpuNuttFPGHIJLokhvvrLAuST_fIeCcQU5dIKHZ9szQaR3l4wKU7s5kl-kW4UpBgSrnLkCqFgKI4sZM_OwWA8bG4qwczygmzzjabFuqbQ',
    ),
    CourtModel(
      id: 'court_5',
      name: 'The Velocity Grounds: Pitch A',
      sportType: 'Football',
      pricePerHour: 85.0,
      rating: 4.9,
      reviewsCount: 128,
      distance: '1.2 miles away',
      locationName: 'Olympic District, Madrid',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCvqN2m1b-Bv324yj37h_UMUFc4pXAM0YCm5x638JrDGUcSvlvGp83JOL9lvb-yoHkomNWhC4ZwFZWCf_4RjeQKke8lS01vHG1cUmhYcyJPB6y08Atjdjh08neo1PV-lxR2rKBrpD41UeEMpGtSKJJPlH1ZOFMQoYOU8WS66hHvs2X7925NabwdMlDVXQhw9tXbZTnd7VeV9A54Wjr0bHFkzFnzoDkAnKcnP1p8fYsS3b4u-k1EP44pJEbwIqXO3kK_QwQgXIjbXQ',
      tags: ['Premium Turf', 'Night Lights', 'Outdoor', 'Showers'],
      description: 'Engineered for peak athletic performance, Pitch A features the latest Pro-Flow synthetic turf and high-density impact padding. Offers professional-grade traction.',
      ownerName: 'Marcus Thorne',
      ownerImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDegK-4yDQDw8UprTtHt093TVvQH0_iIVApyXWw-X9pJEfZzc998rGSqR287JxywroMXyHm14rtx3Da2scLU2Wme6SOc_S29RjJ3Zf1JpHNd5tljtfal7uDjTMIPLU48ZWE6clCRD25akvd_zuiekO7s_SKV_cZdMUd6rpuNuttFPGHIJLokhvvrLAuST_fIeCcQU5dIKHZ9szQaR3l4wKU7s5kl-kW4UpBgSrnLkCqFgKI4sZM_OwWA8bG4qwczygmzzjabFuqbQ',
    ),
  ];

  final List<BookingModel> _bookings = [];

  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  // Get filtered courts based on selected tab and search query
  List<CourtModel> get filteredCourts {
    return _courts.where((court) {
      final matchesTab = court.sportType.toLowerCase() == _selectedSportTab.toLowerCase();
      final matchesSearch = court.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          court.locationName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();
  }

  List<CourtModel> get allCourts => List.unmodifiable(_courts);

  // Time Slots configuration (Selected day mock slots status)
  // Store map of dateString -> list of booked slots
  final Map<String, List<String>> _bookedSlots = {
    // Today/Tomorrow default booked slots for pitch/court
    'default': ['02:30 PM'],
  };

  bool isSlotBooked(DateTime date, String slot) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    final booked = _bookedSlots[dateKey] ?? _bookedSlots['default']!;
    return booked.contains(slot);
  }

  // Owner dashboard data
  double _ownerRevenue = 24850.00;
  int _activeBookingsCount = 142;
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'type': 'booking',
      'title': 'New Booking: 5-a-side Tournament',
      'subtitle': 'Main Pitch Alpha • 2 hours ago',
      'amount': r'+$80.00',
      'status': 'Completed',
    },
    {
      'type': 'adjustment',
      'title': 'Booking Rescheduled: Private Session',
      'subtitle': 'The Cage • 4 hours ago',
      'amount': r'-$15.00',
      'status': 'Adjustment',
    },
    {
      'type': 'verification',
      'title': 'New Account: Soccer Academy Pro',
      'subtitle': 'Verified Owner • Today, 09:15 AM',
      'amount': null,
      'status': 'Verified',
    }
  ];

  double get ownerRevenue => _ownerRevenue;
  int get activeBookingsCount => _activeBookingsCount;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  // Actions
  void login(String email, String role) {
    _isAuthenticated = true;
    _userEmail = email;
    _userRole = role;
    _userName = email.split('@').first;
    _userName = _userName[0].toUpperCase() + _userName.substring(1);
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userRole = 'player';
    _userEmail = '';
    _userName = '';
    notifyListeners();
  }

  void toggleUserRole() {
    _userRole = _userRole == 'player' ? 'owner' : 'player';
    notifyListeners();
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
    _selectedTimeSlot = null; // reset slot selection
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

  // Finalize booking
  void confirmBooking() {
    if (_selectedCourt == null || _selectedTimeSlot == null) return;
    
    final finalPrice = calculateTotalDue();
    final newBooking = BookingModel(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      courtId: _selectedCourt!.id,
      courtName: _selectedCourt!.name,
      courtImageUrl: _selectedCourt!.imageUrl,
      date: _selectedDate,
      timeSlot: _selectedTimeSlot!,
      totalPrice: finalPrice,
    );

    // Save slot as booked
    final dateKey = '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';
    if (!_bookedSlots.containsKey(dateKey)) {
      _bookedSlots[dateKey] = [];
    }
    _bookedSlots[dateKey]!.add(_selectedTimeSlot!);

    // Insert booking
    _bookings.insert(0, newBooking);

    // Increment owner metrics
    _ownerRevenue += finalPrice;
    _activeBookingsCount += 1;

    // Add recent activity
    _recentActivities.insert(0, {
      'type': 'booking',
      'title': 'New Booking: ${_selectedCourt!.name}',
      'subtitle': '${_selectedCourt!.sportType} • Just now',
      'amount': '+\$${finalPrice.toStringAsFixed(2)}',
      'status': 'Completed',
    });

    notifyListeners();
  }

  // Owner action: Add custom court
  void addCourt({
    required String name,
    required String sportType,
    required double price,
    required String location,
    required List<String> tags,
    required String description,
  }) {
    final newCourt = CourtModel(
      id: 'court_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      sportType: sportType,
      pricePerHour: price,
      rating: 5.0,
      reviewsCount: 0,
      distance: '0.0 miles away',
      locationName: location,
      imageUrl: _getSportDefaultImage(sportType),
      tags: tags,
      description: description,
      ownerName: _userName.isNotEmpty ? _userName : 'Marcus Thorne',
      ownerImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDegK-4yDQDw8UprTtHt093TVvQH0_iIVApyXWw-X9pJEfZzc998rGSqR287JxywroMXyHm14rtx3Da2scLU2Wme6SOc_S29RjJ3Zf1JpHNd5tljtfal7uDjTMIPLU48ZWE6clCRD25akvd_zuiekO7s_SKV_cZdMUd6rpuNuttFPGHIJLokhvvrLAuST_fIeCcQU5dIKHZ9szQaR3l4wKU7s5kl-kW4UpBgSrnLkCqFgKI4sZM_OwWA8bG4qwczygmzzjabFuqbQ',
    );
    _courts.add(newCourt);
    notifyListeners();
  }

  String _getSportDefaultImage(String sport) {
    switch (sport.toLowerCase()) {
      case 'padel':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuBrm3ei7dGJaSUfJOZ1EQz_8zS_t1X3miNBn8pkVqEnD8ScqDhylxZms6iya5Uz3caoJfJcz5FtaZ77ncDNr-n6clfC1YntAaUUpHeBn6OA9Dym35Gur7aGARZStp4d2GZPUKOBfwVFle3GxX-21i_AgcOJipsiG_UU-LwnhRsJqgZOPRXHiFscfJZOm_KCm06JH3KNXfO95OFOXx9vIX_dBUd37mO1qFxQwNRvvwDcxtN2S8FB3SGWGGyWwZb0z_z8zyIYE7VCnA';
      case 'tennis':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuDxYrQspsOzVuXx-t2ZxiFakKuY6bcGUdTV-6_52mQMzT4tqIN-c3go2RNwtFJxJE04VQHnsJsGFxEOmZ6Rhg7NBvQH-kDVcT3udjL6seRFzHFxblwDyu2IojnKazYOW-gIQy4soeCqrNuIVV1_i7eKMC9JbdG2fRbtcsxbqo5xNPJYD9T9UVpYgCzUOuM-Y1cfoEnNMavZP9Zwa4hXSvEXn0WPPeac8I1KLF_-vkYD0mS67iuvRIverOFsQAJKc2sv5GFYM9MJGA';
      case 'badminton':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuBvDXz1-96JVcE5N6SJdnfEUXN4nsM5xvioh_h4Ybmp3NBTVUEQZssEK8AwEbZr_v9-FPuCusse-a4eVL7KgjrVmfgN-eIdB0ge83P_o8txe6uc15dU8k-eH3pWkTI4_Ix8SsFJqTG2GQQosmxP4SEaHiHJQg-vzgZeuYEdjv12TlWzjx5IFdE9d6N5ZDYXsQgajHpuoKnF2mCu_bWFASPlX8_wLukEOYxu3VO3w9u3geobWhum4Nv_mIAuog_5nGHRiKxENSBAoA';
      default:
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuCvqN2m1b-Bv324yj37h_UMUFc4pXAM0YCm5x638JrDGUcSvlvGp83JOL9lvb-yoHkomNWhC4ZwFZWCf_4RjeQKke8lS01vHG1cUmhYcyJPB6y08Atjdjh08neo1PV-lxR2rKBrpD41UeEMpGtSKJJPlH1ZOFMQoYOU8WS66hHvs2X7925NabwdMlDVXQhw9tXbZTnd7VeV9A54Wjr0bHFkzFnzoDkAnKcnP1p8fYsS3b4u-k1EP44pJEbwIqXO3kK_QwQgXIjbXQ';
    }
  }

  // Calculations for Checkout
  double getSubtotal() {
    if (_selectedCourt == null) return 0.0;
    // Default duration is 2 hours (as shown in the checkout design "Court Rental (2 hrs)")
    return _selectedCourt!.pricePerHour * 2;
  }

  double getServiceFee() {
    return 5.50; // matching detail from Stitch "Service Fee: $5.50"
  }

  double getDiscount() {
    // 10% flash discount as in Stitch confirmation design
    return getSubtotal() * 0.10;
  }

  double calculateTotalDue() {
    return getSubtotal() + getServiceFee() - getDiscount();
  }
}
