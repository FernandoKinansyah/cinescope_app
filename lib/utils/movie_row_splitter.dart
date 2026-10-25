// lib/utils/movie_row_splitter.dart

import '../models/movie.dart';

class MovieRowSplitter {
  /// Split list film jadi beberapa baris sesuai aturan:
  /// - ≤ 15 → 1 baris
  /// - 16-20 → baris 1 = 10, baris 2 = sisa
  /// - ≥ 21 → baris 1 = 15, baris 2 = 15, ... (kelipatan 15)
  static List<List<Movie>> split(List<Movie> movies) {
    final total = movies.length;

    // ≤ 15 → 1 baris
    if (total <= 15) {
      return [movies];
    }

    // 16-20 → baris 1 = 10, baris 2 = sisa
    if (total <= 20) {
      return [
        movies.sublist(0, 10),
        movies.sublist(10),
      ];
    }

    // ≥ 21 → 15 per baris
    final rows = <List<Movie>>[];
    int i = 0;
    while (i < total) {
      final end = (i + 15 > total) ? total : i + 15;
      rows.add(movies.sublist(i, end));
      i = end;
    }
    return rows;
  }
}