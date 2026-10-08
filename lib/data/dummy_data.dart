import '../models/article.dart';
import '../models/movie.dart';

class DummyData {
  static final List<Movie> movies = [
    Movie(
      id: 1,
      webId: 'SORE_AADC_3',
      title: 'Sore (Ada Apa Dengan Cinta? 3)',
      genre: 'Drama, Romantis',
      status: 'released',
      avgRating: 4.5,
      reviewCount: 3,
      likeCount: 34,
      releaseYear: 2025,
      duration: '2h 0m',
      director: 'Riri Riza',
      cast: 'Dian Sastro, Nicholas Saputra',
      synopsis:
          'Kisah dua orang yang bertemu di senja dan harus memilih antara mimpi dan cinta.',
      trailerUrl: 'https://www.youtube.com/watch?v=example-sore',
      movieUrl: 'https://www.youtube.com/watch?v=example-sore-full',
      reviews: [
        Review(id: 1, rating: 5, text: 'Filmnya menyentuh banget, aktingnya natural!',
            reviewerName: 'Andi', createdAt: DateTime(2024, 6, 10, 20, 30)),
        Review(id: 2, rating: 4, text: 'Ceritanya sederhana tapi mengena.',
            reviewerName: 'Sinta', createdAt: DateTime(2024, 6, 12, 14, 15)),
        Review(id: 3, rating: 4, text: 'Sinematografinya bagus.',
            reviewerName: 'Budi', createdAt: DateTime(2024, 6, 15, 9, 0)),
      ],
    ),
    Movie(
      id: 2,
      webId: 'MOVIE_2',
      title: 'Petaka Gunung Gede',
      genre: 'Thriller, Misteri',
      status: 'released',
      avgRating: 4.2,
      reviewCount: 2,
      likeCount: 27,
      releaseYear: 2024,
      duration: '1h 45m',
      director: 'Unknown',
      cast: 'Unknown',
      synopsis:
          'Pendakian yang berubah menjadi teror saat rombongan tersesat di jalur terlarang.',
      trailerUrl: 'https://www.youtube.com/watch?v=example-petaka',
      movieUrl: 'https://www.youtube.com/watch?v=example-petaka-full',
      reviews: [
        Review(id: 4, rating: 5, text: 'Sangat menegangkan, jumpscare-nya pas!',
            reviewerName: 'Rian', createdAt: DateTime(2024, 7, 1, 19, 0)),
        Review(id: 5, rating: 3, text: 'Lumayan, tapi endingnya agak dipaksa.',
            reviewerName: 'Maya', createdAt: DateTime(2024, 7, 3, 21, 45)),
      ],
    ),
    Movie(
      id: 3,
      webId: 'DILAN_1990',
      title: 'Dilan 1990',
      genre: 'Drama, Romantis',
      status: 'released',
      avgRating: 4.8,
      reviewCount: 3,
      likeCount: 51,
      releaseYear: 2018,
      duration: '1h 50m',
      director: 'Fajar Bustomi',
      cast: 'Iqbaal Ramadhan, Vanesha Prescilla',
      synopsis:
          'Kisah cinta SMA di Bandung tahun 90-an antara Dilan dan Milea.',
      trailerUrl: 'https://www.youtube.com/watch?v=example-dilan',
      movieUrl: 'https://www.youtube.com/watch?v=example-dilan-full',
      reviews: [
        Review(id: 6, rating: 5, text: 'Nostalgia banget! Bikin baper.',
            reviewerName: 'Dewi', createdAt: DateTime(2024, 5, 20, 18, 0)),
        Review(id: 7, rating: 5, text: 'Dilan-nya ikonik.',
            reviewerName: 'Fajar', createdAt: DateTime(2024, 5, 22, 20, 30)),
        Review(id: 8, rating: 4, text: 'Bagus, tapi buku lebih detail.',
            reviewerName: 'Nina', createdAt: DateTime(2024, 5, 25, 11, 15)),
      ],
    ),
    Movie(
      id: 4,
      webId: 'REST_AREA',
      title: 'Rest Area',
      genre: 'Horor, Thriller',
      status: 'released',
      avgRating: 3.9,
      reviewCount: 2,
      likeCount: 15,
      releaseYear: 2023,
      duration: '1h 35m',
      director: 'Unknown',
      cast: 'Unknown',
      synopsis: 'Teror di rest area tengah malam yang tidak ada di peta.',
      trailerUrl: 'https://www.youtube.com/watch?v=example-restarea',
      movieUrl: 'https://www.youtube.com/watch?v=example-restarea-full',
      reviews: [
        Review(id: 9, rating: 4, text: 'Atmosfernya mencekam.',
            reviewerName: 'Yoga', createdAt: DateTime(2024, 8, 1, 22, 0)),
        Review(id: 10, rating: 3, text: 'Biasa aja, standar horor Indonesia.',
            reviewerName: 'Lia', createdAt: DateTime(2024, 8, 5, 19, 30)),
      ],
    ),
    Movie(
      id: 5,
      webId: 'TUKAR_TAKDIR',
      title: 'Tukar Takdir',
      genre: 'Drama, Fantasi',
      status: 'released',
      avgRating: 4.1,
      reviewCount: 2,
      likeCount: 18,
      releaseYear: 2024,
      duration: '1h 45m',
      director: 'Unknown',
      cast: 'Unknown',
      synopsis: 'Dua orang bertukar nasib setelah kecelakaan misterius.',
      trailerUrl: 'https://www.youtube.com/watch?v=example-tukartakdir',
      movieUrl: 'https://www.youtube.com/watch?v=example-tukartakdir-full',
      reviews: [
        Review(id: 11, rating: 4, text: 'Plot twist-nya menarik.',
            reviewerName: 'Hendra', createdAt: DateTime(2024, 9, 10, 15, 0)),
        Review(id: 12, rating: 4, text: 'Akting pemain utamanya mantap.',
            reviewerName: 'Sari', createdAt: DateTime(2024, 9, 12, 17, 20)),
      ],
    ),
    Movie(
      id: 6,
      webId: 'RANGGA_CINTA',
      title: 'Ada Apa Dengan Cinta? (Rangga & Cinta)',
      genre: 'Drama, Romantis',
      status: 'released',
      avgRating: 4.6,
      reviewCount: 3,
      likeCount: 42,
      releaseYear: 2002,
      duration: '1h 52m',
      director: 'Rudy Soedjarwo',
      cast: 'Dian Sastrowardoyo, Nicholas Saputra',
      synopsis:
          'Kisah cinta dua anak SMA yang diiringi puisi dan mimpi.',
      trailerUrl: 'https://www.youtube.com/watch?v=example-aadc',
      movieUrl: 'https://www.youtube.com/watch?v=example-aadc-full',
      reviews: [
        Review(id: 13, rating: 5, text: 'Soundtrack-nya juara!',
            reviewerName: 'Ayu', createdAt: DateTime(2024, 10, 1, 20, 0)),
        Review(id: 14, rating: 5, text: 'Chemistry pemainnya dapet banget.',
            reviewerName: 'Rizky', createdAt: DateTime(2024, 10, 3, 21, 15)),
        Review(id: 15, rating: 4, text: 'Bagus untuk genre klasik lokal.',
            reviewerName: 'Tika', createdAt: DateTime(2024, 10, 5, 13, 45)),
      ],
    ),
    Movie(
      id: 7,
      webId: 'COMING_SOON_1',
      title: 'Film Baru 2025',
      genre: 'Action',
      status: 'coming_soon',
      avgRating: 0,
      reviewCount: 0,
      likeCount: 0,
      releaseDate: DateTime(2025, 12, 25),
    ),
  ];

  static List<Article> articles = [
    Article(
      title: 'Oppenheimer: Film Epik tentang Sang Bapak Bom Atom',
      imageUrl:
          'https://static1.srcdn.com/wordpress/wp-content/uploads/2023/05/oppenheimer-poster.jpg',
      excerpt:
          'Disutradarai oleh Christopher Nolan, film ini menyoroti konflik moral dan ilmiah di balik penciptaan bom atom.',
    ),
    Article(
      title: 'Black Panther: Warisan Budaya dan Kekuatan Sinematik',
      imageUrl:
          'https://image.tmdb.org/t/p/w780/sv1xJUazXeYqALzczSZ3O6nkH75.jpg',
      excerpt:
          'Sekuel Wakanda Forever bukan sekadar aksi superhero, tetapi juga penghormatan emosional pada Chadwick Boseman.',
    ),
    Article(
      title: 'Inside Out 2: Petualangan Emosi yang Semakin Dalam',
      imageUrl:
          'https://tse3.mm.bing.net/th/id/OIP.epjFJueo-VyGiI7iM_P7OQHaLG',
      excerpt:
          'Pixar kembali menghadirkan kisah penuh makna dengan memperkenalkan emosi baru seperti Cemas dan Iri.',
    ),
  ];

  static List<Movie> get trending {
    final released = movies.where((m) => m.status == 'released').toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return released.take(3).toList();
  }

  static List<Movie> get recommended {
    final released = movies.where((m) => m.status == 'released').toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return released.skip(3).toList();
  }

  static List<Movie> get comingSoon =>
      movies.where((m) => m.status == 'coming_soon').toList();

  static List<Movie> get allReleased =>
      movies.where((m) => m.status == 'released').toList();

  static Movie? getById(int id) {
    try {
      return movies.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}