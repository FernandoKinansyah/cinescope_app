// lib/models/movie.dart

class Review {
  final int id;
  final int rating;
  final String text;
  final String reviewerName;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.rating,
    required this.text,
    required this.reviewerName,
    required this.createdAt,
  });
}

class Movie {
  final int id;
  final String webId;
  final String title;
  final String genre;
  final String? poster;
  final String status;
  final DateTime? releaseDate;
  final double avgRating;
  final int reviewCount;
  final int likeCount;

  final int? releaseYear;
  final String? duration;
  final String? synopsis;
  final String? director;
  final String? cast;
  final String? trailerUrl;
  final String? movieUrl;
  final DateTime? createdAt;
  final List<Review> reviews;

  Movie({
    required this.id,
    this.webId = '',
    required this.title,
    required this.genre,
    this.poster,
    required this.status,
    this.releaseDate,
    this.avgRating = 0.0,
    this.reviewCount = 0,
    this.likeCount = 0,
    this.releaseYear,
    this.duration,
    this.synopsis,
    this.director,
    this.cast,
    this.trailerUrl,
    this.movieUrl,
    this.createdAt,
    this.reviews = const [],
  });

  double get score => reviewCount * avgRating;

  Movie copyWith({
    int? id,
    String? webId,
    String? title,
    String? genre,
    String? poster,
    String? status,
    DateTime? releaseDate,
    double? avgRating,
    int? reviewCount,
    int? likeCount,
    int? releaseYear,
    String? duration,
    String? synopsis,
    String? director,
    String? cast,
    String? trailerUrl,
    String? movieUrl,
    DateTime? createdAt,
    List<Review>? reviews,
  }) {
    return Movie(
      id: id ?? this.id,
      webId: webId ?? this.webId,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      poster: poster ?? this.poster,
      status: status ?? this.status,
      releaseDate: releaseDate ?? this.releaseDate,
      avgRating: avgRating ?? this.avgRating,
      reviewCount: reviewCount ?? this.reviewCount,
      likeCount: likeCount ?? this.likeCount,
      releaseYear: releaseYear ?? this.releaseYear,
      duration: duration ?? this.duration,
      synopsis: synopsis ?? this.synopsis,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      movieUrl: movieUrl ?? this.movieUrl,
      createdAt: createdAt ?? this.createdAt,
      reviews: reviews ?? this.reviews,
    );
  }
}