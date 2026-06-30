import '../datasources/review_remote_datasource.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final ReviewRemoteDataSource _remote;
  ReviewRepository({ReviewRemoteDataSource? remote})
      : _remote = remote ?? ReviewRemoteDataSource();

  Future<List<ReviewModel>> getReviewsForUser(int userId) async {
    final rows = await _remote.fetchReviewsForUser(userId);
    return rows.map(ReviewModel.fromMap).toList();
  }

  Future<List<ReviewModel>> getReviewsForField(int fieldId) async {
    final rows = await _remote.fetchReviewsForField(fieldId);
    return rows.map(ReviewModel.fromMap).toList();
  }

  Future<ReviewModel?> getReviewForBooking(int bookingId) async {
    final row = await _remote.fetchReviewForBooking(bookingId);
    if (row == null) return null;
    return ReviewModel.fromMap(row);
  }

  Future<ReviewModel> submitReview({
    required int bookingId,
    required int userId,
    required int fieldId,
    required double rating,
    String? review,
  }) async {
    final row = await _remote.upsertReview(
      bookingId: bookingId,
      userId: userId,
      fieldId: fieldId,
      rating: rating,
      review: review,
    );
    return ReviewModel.fromMap(row);
  }
}
