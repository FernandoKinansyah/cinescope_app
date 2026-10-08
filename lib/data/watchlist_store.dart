import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import 'auth_store.dart';

class WatchlistStore {
  /// Map: email → list movieId
  static final Map<String, List<int>> _data = {};
  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  static String get _key =>
      AuthStore.currentUser.value?.email ?? 'guest@cinescope.com';

  static List<int> get ids => List.from(_data[_key] ?? []);

  static bool contains(int movieId) => ids.contains(movieId);

  static void toggle(int movieId) {
    final list = _data.putIfAbsent(_key, () => []);
    if (list.contains(movieId)) {
      list.remove(movieId);
    } else {
      list.add(movieId);
    }
    notifier.value++;
  }

  static void remove(int movieId) {
    _data[_key]?.remove(movieId);
    notifier.value++;
  }

  static List<Movie> get movies {
    return ids
        .map((id) => _allMovies.firstWhere((m) => m.id == id,
            orElse: () => Movie(
                  id: id,
                  title: 'Film #$id',
                  genre: '-',
                  status: 'released',
                  avgRating: 0,
                  reviewCount: 0,
                  likeCount: 0,
                )))
        .toList();
  }

  static List<Movie> _allMovies = [];
  static void setMovies(List<Movie> m) => _allMovies = m;
}