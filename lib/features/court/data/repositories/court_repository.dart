import '../datasources/court_remote_datasource.dart';
import '../models/court_model.dart';

class CourtRepository {
  final CourtRemoteDataSource _remote;
  CourtRepository({CourtRemoteDataSource? remote})
      : _remote = remote ?? CourtRemoteDataSource();

  Future<List<CourtModel>> getCourts() async {
    final rows = await _remote.fetchCourts();
    return rows.map(CourtModel.fromMap).toList();
  }

  Future<List<CourtModel>> getCourtsByOwner(int ownerId) async {
    final rows = await _remote.fetchCourtsByOwner(ownerId);
    return rows.map(CourtModel.fromMap).toList();
  }

  Future<CourtModel> createCourt({
    required int ownerId,
    required String name,
    required String sportType,
    required double pricePerHour,
    required String location,
    required String description,
    required List<String> features,
    required bool isIndoor,
    int capacity = 4,
    String? imageUrl,
  }) async {
    final row = await _remote.createCourt(
      ownerId: ownerId,
      name: name,
      sportType: sportType,
      pricePerHour: pricePerHour,
      capacity: capacity,
      isIndoor: isIndoor,
      features: features,
      description: description,
      location: location,
      imageUrl: imageUrl,
    );
    return CourtModel.fromMap(row);
  }
}
