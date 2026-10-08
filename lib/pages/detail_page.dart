import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/auth_store.dart';
import '../data/dummy_data.dart';
import '../data/review_store.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';
import '../widgets/review_item.dart';

class DetailPage extends StatefulWidget {
  final int movieId;
  const DetailPage({super.key, required this.movieId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _selectedRating = 0;
  final _reviewCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ReviewStore.notifier.addListener(_onChange);
    AuthStore.currentUser.addListener(_onChange);
  }

  @override
  void dispose() {
    ReviewStore.notifier.removeListener(_onChange);
    AuthStore.currentUser.removeListener(_onChange);
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  Future<void> _openUrl(String? url, {String? fallbackMsg}) async {
    if (url == null || url.isEmpty) {
      _showSnack(fallbackMsg ?? 'Link belum tersedia');
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Tidak bisa membuka link');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _submitReview(Movie movie) {
    final user = AuthStore.currentUser.value;
    if (user == null) {
      _showSnack('Anda harus login untuk memberi ulasan!');
      return;
    }
    if (_selectedRating < 1) {
      _showSnack('Harap berikan rating bintang!');
      return;
    }
    if (ReviewStore.hasReviewed(movie.id, user.username)) {
      _showSnack('Anda sudah memberi ulasan untuk film ini!');
      return;
    }

    ReviewStore.addReview(
      movieId: movie.id,
      rating: _selectedRating,
      text: _reviewCtrl.text.trim(),
      username: user.username,
    );

    setState(() {
      _selectedRating = 0;
      _reviewCtrl.clear();
    });

    _showSnack('✅ Ulasan berhasil ditambahkan!');
  }

  @override
  Widget build(BuildContext context) {
    final movie = DummyData.getById(widget.movieId);

    if (movie == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.navbarBg,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('❌ Film tidak ditemukan!',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      );
    }

    final userReviews = ReviewStore.getByMovie(movie.id);
    final allReviews = [...userReviews, ...movie.reviews];

    final totalReviews = allReviews.length;
    final avgRating = totalReviews > 0
        ? allReviews.fold<int>(0, (s, r) => s + r.rating) / totalReviews
        : 0.0;

    final isLoggedIn = AuthStore.currentUser.value != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Ulasan - ${movie.title}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x80000000), blurRadius: 20),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Movie Header ===
              _movieHeader(movie, totalReviews, avgRating),
              const SizedBox(height: 16),

              // === TOMBOL AKSI ===
              // Guest : Tonton Trailer saja
              // User  : Tonton Trailer + Tonton Film
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // Tonton Trailer (semua user)
                  ElevatedButton.icon(
                    onPressed: () => _openUrl(
                      movie.trailerUrl,
                      fallbackMsg: 'Trailer belum tersedia',
                    ),
                    icon: const Icon(Icons.play_circle),
                    label: const Text('Tonton Trailer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B59B6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                    ),
                  ),
                  // Tonton Film (hanya user login)
                  if (isLoggedIn)
                    ElevatedButton.icon(
                      onPressed: () => _openUrl(
                        movie.movieUrl,
                        fallbackMsg: 'Film belum tersedia',
                      ),
                      icon: const Icon(Icons.movie),
                      label: const Text('Tonton Film'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 28),

              // === FORM REVIEW ===
              const Row(
                children: [
                  Icon(Icons.edit, color: AppColors.accent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Berikan Ulasan dan Rating Anda',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: isLoggedIn
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rating (1-5 Bintang)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (i) {
                              final starVal = i + 1;
                              return GestureDetector(
                                onTap: () => setState(
                                    () => _selectedRating = starVal),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.star,
                                    size: 36,
                                    color: starVal <= _selectedRating
                                        ? AppColors.star
                                        : const Color(0xFF444444),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          const Text('Ulasan Anda',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _reviewCtrl,
                            maxLines: 4,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText:
                                  'Tuliskan ulasan Anda tentang film ini...',
                              hintStyle: const TextStyle(
                                  color: AppColors.textGray),
                              filled: true,
                              fillColor: const Color(0xFF2D2D2D),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                    color: Color(0xFF444444)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                    color: Color(0xFF444444)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                    color: AppColors.accent),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _submitReview(movie),
                              icon: const Icon(Icons.send),
                              label: const Text('Kirim Ulasan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Anda harus login untuk memberikan review',
                            style: TextStyle(color: AppColors.textLight),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 28),

              // === ULASAN SAYA (list) ===
              const Row(
                children: [
                  Icon(Icons.verified_user,
                      color: AppColors.star, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Ulasan Saya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 2, color: AppColors.star),
              const SizedBox(height: 20),

              if (totalReviews > 0)
                ...allReviews.map((r) => ReviewItem(review: r))
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Belum ada ulasan untuk film ini. Jadilah yang pertama!',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _movieHeader(Movie movie, int totalReviews, double avgRating) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;

        final poster = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: movie.poster != null
              ? Image.network(
                  movie.poster!,
                  width: 150,
                  height: 225,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 150,
                  height: 225,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF333333), Color(0xFF555555)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.movie,
                        color: Color(0xFF888888), size: 48),
                  ),
                ),
        );

        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.title,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${movie.releaseYear ?? '-'} • ${movie.genre} • ${movie.duration ?? '-'}',
              style: const TextStyle(
                  color: AppColors.textLight, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Sutradara: ${movie.director ?? '-'} • Pemain: ${movie.cast ?? '-'}',
              style: const TextStyle(
                  color: AppColors.textGray, fontSize: 13),
            ),
            if (movie.synopsis != null && movie.synopsis!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                movie.synopsis!,
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF333333))),
              ),
              child: Row(
                children: [
                  _ratingBox(
                    totalReviews > 0
                        ? '${avgRating.toStringAsFixed(1)}/5'
                        : '0.0/5',
                    'Rata-Rata',
                  ),
                  const SizedBox(width: 12),
                  _ratingBox('$totalReviews', 'Total Ulasan'),
                ],
              ),
            ),
          ],
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              poster,
              const SizedBox(width: 20),
              Expanded(child: info),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: poster),
            const SizedBox(height: 20),
            info,
          ],
        );
      },
    );
  }

  Widget _ratingBox(String score, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score,
            style: const TextStyle(
              color: AppColors.star,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFFAAAAAA), fontSize: 11),
          ),
        ],
      ),
    );
  }
}