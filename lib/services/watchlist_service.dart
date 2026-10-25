// lib/services/watchlist_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie.dart';

class WatchlistService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Ambil daftar tonton user yang login (set of movie_id)
  static Future<Set<int>> getMyMovieIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};

    final data = await _supabase
        .from('watchlists')
        .select('movie_id')
        .eq('user_id', user.id);

    return (data as List)
        .map((e) => (e['movie_id'] as num).toInt())
        .toSet();
  }

  /// Ambil film yang ada di daftar tonton user
  static Future<List<Movie>> getMyMovies() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final data = await _supabase
        .from('watchlists')
        .select('movie_id, movies(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (data as List).map((e) {
      final movieMap = e['movies'] as Map<String, dynamic>;
      return _toMovie(movieMap);
    }).toList();
  }

  /// Cek apakah film ada di daftar tonton user
  static Future<bool> isInMyWatchlist(int movieId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final data = await _supabase
        .from('watchlists')
        .select('id')
        .eq('user_id', user.id)
        .eq('movie_id', movieId)
        .maybeSingle();

    return data != null;
  }

  /// Toggle: tambah kalau belum ada, hapus kalau sudah ada
  /// Return true kalau sekarang TERSIMPAN, false kalau DIHAPUS
  static Future<bool> toggle(int movieId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Anda harus login');
    }

    final exists = await isInMyWatchlist(movieId);

    if (exists) {
      await _supabase
          .from('watchlists')
          .delete()
          .eq('user_id', user.id)
          .eq('movie_id', movieId);
      return false;
    } else {
      await _supabase.from('watchlists').insert({
        'user_id': user.id,
        'movie_id': movieId,
      });
      return true;
    }
  }

  /// Hapus dari daftar tonton
  static Future<void> remove(int movieId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('watchlists')
        .delete()
        .eq('user_id', user.id)
        .eq('movie_id', movieId);
  }

  /// Convert dari Supabase (Map) ke model Movie
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
      reviews: const [],
    );
  }
}