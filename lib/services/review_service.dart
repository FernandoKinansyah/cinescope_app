// lib/services/review_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie.dart';

class ReviewService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Ambil semua review untuk film tertentu
  static Future<List<Review>> getByMovie(int movieId) async {
    final data = await _supabase
        .from('reviews')
        .select()
        .eq('movie_id', movieId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => _toReview(e)).toList();
  }

  /// Tambah review baru (boleh berkali-kali)
  /// Return null kalau sukses, atau pesan error
  static Future<String?> addReview({
    required int movieId,
    required int rating,
    required String reviewText,
    required String userName,
  }) async {
    if (rating < 1 || rating > 5) {
      return 'Rating harus antara 1-5 bintang!';
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      return 'Anda harus login untuk memberi ulasan!';
    }

    try {
      await _supabase.from('reviews').insert({
        'movie_id': movieId,
        'user_id': user.id,
        'rating': rating,
        'review_text': reviewText.isEmpty ? null : reviewText,
        'user_name': userName,
      });

      // Update avg_rating di tabel movies
      await _updateMovieAvgRating(movieId);

      return null;
    } catch (e) {
      return 'Gagal menyimpan ulasan: $e';
    }
  }

  /// Hitung ulang rata-rata rating film
  static Future<void> _updateMovieAvgRating(int movieId) async {
    final data = await _supabase
        .from('reviews')
        .select('rating')
        .eq('movie_id', movieId);

    final list = data as List;
    if (list.isEmpty) return;

    final total = list.fold<int>(
        0, (s, e) => s + ((e['rating'] as num).toInt()));
    final avg = total / list.length;

    await _supabase
        .from('movies')
        .update({'avg_rating': avg}).eq('id', movieId);
  }

  /// Convert dari Supabase (Map) ke model Review
  static Review _toReview(Map<String, dynamic> e) {
    return Review(
      id: e['id'] as int,
      rating: (e['rating'] as num).toInt(),
      text: e['review_text'] as String? ?? '',
      reviewerName: e['user_name'] as String? ?? 'Anonim',
      createdAt: DateTime.tryParse(e['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}