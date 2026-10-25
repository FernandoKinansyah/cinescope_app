// lib/services/movie_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie.dart';

class MovieService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  static Future<List<Movie>> getAllReleased() async {
    final data = await _supabase
        .from('movies')
        .select()
        .eq('status', 'released')
        .order('created_at', ascending: false);

    return (data as List).map((e) => _toMovie(e)).toList();
  }

  static Future<List<Movie>> getAll() async {
    final data = await _supabase
        .from('movies')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => _toMovie(e)).toList();
  }

  static Future<Movie?> getById(int id) async {
    final data = await _supabase
        .from('movies')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return _toMovie(data);
  }

  /// Ambil film + statistik review (jumlah + avg_rating real-time)
  static Future<List<Movie>> getAllWithStats() async {
    final moviesData = await _supabase
        .from('movies')
        .select()
        .order('created_at', ascending: false);

    final reviewsData = await _supabase
        .from('reviews')
        .select('movie_id, rating');

    final Map<int, List<int>> reviewsByMovie = {};
    for (final r in (reviewsData as List)) {
      final movieId = r['movie_id'] as int;
      final rating = (r['rating'] as num).toInt();
      reviewsByMovie.putIfAbsent(movieId, () => []).add(rating);
    }

    return (moviesData as List).map((e) {
      final movie = _toMovie(e);
      final ratings = reviewsByMovie[movie.id] ?? [];
      final count = ratings.length;
      final avg = count > 0
          ? ratings.reduce((a, b) => a + b) / count
          : 0.0;

      return movie.copyWith(
        reviewCount: count,
        avgRating: avg,
      );
    }).toList();
  }

  /// 🔥 Top Trending: film dengan skor tertinggi (max 3)
  static Future<List<Movie>> getTrending({int limit = 3}) async {
    final movies = await getAllWithStats();
    final released = movies.where((m) => m.status == 'released').toList();

    released.sort((a, b) {
      final aHasReviews = a.reviewCount > 0;
      final bHasReviews = b.reviewCount > 0;

      if (aHasReviews && !bHasReviews) return -1;
      if (!aHasReviews && bHasReviews) return 1;

      if (aHasReviews && bHasReviews) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;
      }

      return b.avgRating.compareTo(a.avgRating);
    });

    return released.take(limit).toList();
  }

  /// 🔥 Daftar Film: SEMUA film released, urut terbaru
  static Future<List<Movie>> getRecommended({int skip = 0}) async {
    final movies = await getAllWithStats();
    final released = movies.where((m) => m.status == 'released').toList();

    // Urut by created_at terbaru di kiri
    released.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return released;
  }

  /// 🔥 Coming Soon
  static Future<List<Movie>> getComingSoon() async {
    final data = await _supabase
        .from('movies')
        .select()
        .eq('status', 'coming_soon')
        .order('created_at', ascending: false);

    return (data as List).map((e) => _toMovie(e)).toList();
  }

  static Movie _toMovie(Map<String, dynamic> e) {
    return Movie(
      id: e['id'] as int,
      webId: e['web_id'] as String? ?? '',
      title: e['title'] as String? ?? '',
      genre: e['genre'] as String? ?? '',
      poster: e['poster'] as String?,
      status: e['status'] as String? ?? 'released',
      avgRating: (e['avg_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: 0,
      likeCount: 0,
      releaseYear: e['release_year'] as int?,
      duration: e['duration'] as String?,
      synopsis: e['synopsis'] as String?,
      director: e['director'] as String?,
      cast: e['cast_list'] as String?,
      trailerUrl: e['trailer_url'] as String?,
      movieUrl: e['movie_url'] as String?,
      createdAt: e['created_at'] != null
          ? DateTime.tryParse(e['created_at'] as String)
          : null,
    );
  }
}