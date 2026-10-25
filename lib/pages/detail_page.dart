import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/review_service.dart';
import '../services/watchlist_service.dart';
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
  final _scrollController = ScrollController();
  final _reviewsKey = GlobalKey();

  Movie? _movie;
  List<Review> _reviews = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isInWatchlist = false;
  bool _isTogglingWatchlist = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isLoggedIn =>
      Supabase.instance.client.auth.currentUser != null;

  String get _username {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return '';
    return user.userMetadata?['username'] as String? ??
        user.email?.split('@').first ??
        'User';
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final movie = await MovieService.getById(widget.movieId);
      final reviews = await ReviewService.getByMovie(widget.movieId);
      bool inWatchlist = false;
      if (_isLoggedIn) {
        inWatchlist = await WatchlistService.isInMyWatchlist(widget.movieId);
      }
      setState(() {
        _movie = movie;
        _reviews = reviews;
        _isInWatchlist = inWatchlist;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat: $e';
        _isLoading = false;
      });
    }
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  /// 🔥 Auto-scroll smooth ke section "Semua Ulasan"
  Future<void> _scrollToReviews() async {
    final context = _reviewsKey.currentContext;
    if (context == null) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      alignment: 0.05,
    );
  }

  Future<void> _toggleWatchlist() async {
    if (!_isLoggedIn) {
      _showSnack('Anda harus login untuk menyimpan ke daftar tonton!');
      return;
    }
    setState(() => _isTogglingWatchlist = true);
    try {
      final added = await WatchlistService.toggle(widget.movieId);
      if (!mounted) return;
      setState(() {
        _isInWatchlist = added;
        _isTogglingWatchlist = false;
      });
      _showSnack(added
          ? '✅ Ditambahkan ke Daftar Tonton'
          : '❌ Dihapus dari Daftar Tonton');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTogglingWatchlist = false);
      _showSnack('Gagal: $e');
    }
  }

  Future<void> _submitReview() async {
    if (!_isLoggedIn) {
      _showSnack('Anda harus login untuk memberi ulasan!');
      return;
    }
    if (_selectedRating < 1) {
      _showSnack('Harap berikan rating bintang!');
      return;
    }

    setState(() => _isSubmitting = true);

    final err = await ReviewService.addReview(
      movieId: widget.movieId,
      rating: _selectedRating,
      reviewText: _reviewCtrl.text.trim(),
      userName: _username,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (err != null) {
      _showSnack(err);
      return;
    }

    _reviewCtrl.clear();
    setState(() => _selectedRating = 0);
    _showSnack('✅ Ulasan berhasil ditambahkan!');
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.navbarBg,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_error != null || _movie == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.navbarBg,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error ?? 'Film tidak ditemukan',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final movie = _movie!;
    final totalReviews = _reviews.length;
    final avgRating = totalReviews > 0
        ? _reviews.fold<int>(0, (s, r) => s + r.rating) / totalReviews
        : 0.0;

    final isLoggedIn = _isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detail Film',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER ===
              _movieHeader(
                  movie, totalReviews, avgRating, isLoggedIn),
              const SizedBox(height: 24),

              // === FORM REVIEW ===
              if (isLoggedIn) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: _reviewForm(),
                ),
                const SizedBox(height: 28),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF444444)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.accent, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Login untuk bisa memberi ulasan dan rating film',
                          style: TextStyle(color: AppColors.textLight),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // === SEMUA ULASAN (target auto-scroll) ===
              Container(
                key: _reviewsKey,
                child: Row(
                  children: [
                    const Icon(Icons.verified_user,
                        color: AppColors.star, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Semua Ulasan ($totalReviews)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(height: 2, color: AppColors.star),
              const SizedBox(height: 20),

              if (totalReviews > 0)
                ..._reviews.map((r) => ReviewItem(review: r))
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

  // ==========================================
  // HEADER
  // ==========================================
  Widget _movieHeader(
      Movie movie, int totalReviews, double avgRating, bool isLoggedIn) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        final poster = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: movie.poster != null && movie.poster!.isNotEmpty
              ? Image.network(
                  movie.poster!,
                  width: 180,
                  height: 270,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _posterPlaceholder(),
                )
              : _posterPlaceholder(),
        );

        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.title,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
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

            const SizedBox(height: 16),

            // === TOMBOL AKSI ===
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Tonton Trailer
                _actionButton(
                  icon: Icons.play_circle,
                  label: 'Trailer',
                  color: const Color(0xFF9B59B6),
                  onTap: () => _openUrl(
                    movie.trailerUrl,
                    fallbackMsg: 'Trailer belum tersedia',
                  ),
                ),

                // Tonton Film (login)
                if (isLoggedIn)
                  _actionButton(
                    icon: Icons.movie,
                    label: 'Tonton Film',
                    color: AppColors.accent,
                    onTap: () => _openUrl(
                      movie.movieUrl,
                      fallbackMsg: 'Film belum tersedia',
                    ),
                  ),

                // Daftar Tonton (login)
                if (isLoggedIn)
                  _actionButton(
                    icon: _isInWatchlist
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    label: _isInWatchlist
                        ? 'Tersimpan'
                        : 'Daftar Tonton',
                    color: _isInWatchlist
                        ? const Color(0xFF27AE60)
                        : const Color(0xFF333333),
                    loading: _isTogglingWatchlist,
                    onTap: _isTogglingWatchlist ? null : _toggleWatchlist,
                  ),

                // 🔥 LIHAT SEMUA ULASAN — auto scroll smooth
                _actionButton(
                  icon: Icons.visibility,
                  label: 'Lihat Semua Ulasan',
                  color: const Color(0xFF2ECC71),
                  onTap: _scrollToReviews,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // === RATING BOXES ===
            Row(
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
          ],
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              poster,
              const SizedBox(width: 24),
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

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _reviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 20),
        const Text('Rating Anda (1-5 Bintang)',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (i) {
            final starVal = i + 1;
            return GestureDetector(
              onTap: () => setState(() => _selectedRating = starVal),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.star,
                  size: 40,
                  color: starVal <= _selectedRating
                      ? AppColors.star
                      : const Color(0xFF444444),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        const Text('Ulasan Anda',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const SizedBox(height: 10),
        TextField(
          controller: _reviewCtrl,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tuliskan ulasan Anda tentang film ini...',
            hintStyle: const TextStyle(color: AppColors.textGray),
            filled: true,
            fillColor: const Color(0xFF2D2D2D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF444444)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF444444)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitReview,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_isSubmitting ? 'Mengirim...' : 'Kirim Ulasan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: 180,
      height: 270,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF333333), Color(0xFF555555)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.movie, color: Color(0xFF888888), size: 56),
      ),
    );
  }

  Widget _ratingBox(String score, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score,
            style: const TextStyle(
              color: AppColors.star,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFFAAAAAA), fontSize: 12),
          ),
        ],
      ),
    );
  }
}