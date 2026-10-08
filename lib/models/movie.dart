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
  final String title;
  final String genre;
  final String? poster;
  final String status;
  final DateTime? releaseDate;
  final double avgRating;
  final int reviewCount;
  final int likeCount;

  // Detail
  final int? releaseYear;
  final String? duration;
  final String? synopsis;
  final String? director;
  final String? cast;
  final String? trailerUrl;   // link trailer (semua user)
  final String? movieUrl;     // link film lengkap (khusus user login)
  final List<Review> reviews;

  final String webId;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    this.poster,
    required this.status,
    this.releaseDate,
    required this.avgRating,
    required this.reviewCount,
    required this.likeCount,
    this.releaseYear,
    this.duration,
    this.synopsis,
    this.director,
    this.cast,
    this.trailerUrl,
    this.movieUrl,
    this.reviews = const [],
    this.webId = '',
  });

  double get score => (reviewCount * 2 + likeCount) * avgRating;
}