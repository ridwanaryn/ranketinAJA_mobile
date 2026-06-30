import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/review_model.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../viewmodels/court_viewmodel.dart';

/// Opens a star-rating dialog for [booking]. If [existing] is provided,
/// the dialog pre-fills with that review. Returns true on successful submit.
///
/// On success this also re-fetches the explore court list (so avg_rating
/// updates everywhere) and the reviews for the currently selected court.
Future<bool> showRatingDialog(
  BuildContext context, {
  required BookingModel booking,
  ReviewModel? existing,
  String? courtName,
}) async {
  int stars = existing?.rating.round() ?? 5;
  final commentController =
      TextEditingController(text: existing?.review ?? '');

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setStateDialog) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.star, color: AppColors.tertiary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            existing == null
                                ? 'Rate this court'
                                : 'Edit your review',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            courtName ??
                                booking.courtName ??
                                'Court #${booking.fieldId}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StarRatingInput(
                  value: stars,
                  onChanged: (n) => setStateDialog(() => stars = n),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _ratingLabel(stars),
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Comment (optional)',
                    hintText: 'Share your experience...',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppColors.outline.withOpacity(0.2)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.send, size: 16),
                      label: Text(existing == null ? 'Submit' : 'Update'),
                      onPressed: () => Navigator.pop(dialogContext, true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  if (ok != true) {
    commentController.dispose();
    return false;
  }
  if (!context.mounted) {
    commentController.dispose();
    return false;
  }

  final bookingVM = context.read<BookingViewModel>();
  final courtVM = context.read<CourtViewModel>();
  final messenger = ScaffoldMessenger.of(context);

  final success = await bookingVM.submitReview(
    booking: booking,
    rating: stars.toDouble(),
    review: commentController.text.trim().isEmpty
        ? null
        : commentController.text.trim(),
  );
  commentController.dispose();

  if (success) {
    // ignore: unawaited_futures
    courtVM.loadCourts();
    // ignore: unawaited_futures
    courtVM.loadReviewsForSelected();
  }

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        success
            ? 'Terima kasih atas review-mu!'
            : bookingVM.error ?? 'Gagal mengirim review',
      ),
      backgroundColor: success ? AppColors.secondary : AppColors.error,
    ),
  );
  return success;
}

String _ratingLabel(int stars) {
  switch (stars) {
    case 1:
      return 'Terrible';
    case 2:
      return 'Poor';
    case 3:
      return 'Okay';
    case 4:
      return 'Good';
    case 5:
      return 'Excellent';
    default:
      return '';
  }
}
