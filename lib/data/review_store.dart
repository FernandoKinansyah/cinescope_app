import 'package:flutter/foundation.dart';
import '../models/movie.dart';

class ReviewStore {
  /// Map: movieId → list review yang ditambahkan user
  static final Map<int, List<Review>> _userReviews = {};
  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  /// Cek user sudah review film ini atau belum (per username)
  static bool hasReviewed(int movieId, String username) {
    final list = _userReviews[movieId] ?? [];
    return list.any((r) => r.reviewerName == username);
  }

  static void addReview({
    required int movieId,
    required int rating,
    required String text,
    required String username,
  }) {
    final list = _userReviews.putIfAbsent(movieId, () => []);
    list.insert(
      0,
      Review(
        id: DateTime.now().millisecondsSinceEpoch,
        rating: rating,
        text: text,
        reviewerName: username,
        createdAt: DateTime.now(),
      ),
    );
    notifier.value++;
  }

  static List<Review> getByMovie(int movieId) {
    return List.from(_userReviews[movieId] ?? []);
  }
}