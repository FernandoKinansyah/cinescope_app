import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/dummy_data.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';

class AllReviewsPage extends StatefulWidget {
  final int movieId;
  const AllReviewsPage({super.key, required this.movieId});

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  int? _filterRating; // null = semua

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
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final reviews = _filterRating == null
        ? movie.reviews
        : movie.reviews.where((r) => r.rating == _filterRating).toList();

    final totalReviews = movie.reviews.length;
    final avg = totalReviews > 0
        ? movie.reviews.fold<int>(0, (s, r) => s + r.rating) / totalReviews
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Semua Ulasan',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
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
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: movie.poster != null
                        ? Image.network(movie.poster!,
                            width: 100, height: 150, fit: BoxFit.cover)
                        : Container(
                            width: 100, height: 150,
                            color: const Color(0xFF667EEA),
                            child: const Center(
                              child: Text('🎬',
                                  style: TextStyle(fontSize: 36)),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${movie.releaseYear ?? '-'} • ${movie.genre}',
                          style: const TextStyle(
                              color: AppColors.textLight, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _statBox('⭐ ${avg.toStringAsFixed(1)}/5',
                                'Rating Rata-rata'),
                            const SizedBox(width: 10),
                            _statBox('$totalReviews', 'Total Ulasan'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFF333333)),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  const Icon(Icons.comment,
                      color: AppColors.accent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Semua Ulasan Pengguna ($totalReviews)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterBtn('Semua', null),
                    for (int i = 5; i >= 1; i--) _filterBtn('⭐ $i', i),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reviews
              if (reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox,
                            size: 80, color: Color(0xFF444444)),
                        SizedBox(height: 20),
                        Text('Belum Ada Ulasan',
                            style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Jadilah yang pertama memberikan ulasan!',
                            style: TextStyle(
                                color: AppColors.textGray, fontSize: 14)),
                      ],
                    ),
                  ),
                )
              else
                ...reviews.map((r) => _reviewCard(r)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.star,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFAAAAAA), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _filterBtn(String label, int? rating) {
    final isActive = _filterRating == rating;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterRating = rating),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : const Color(0xFF333333),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppColors.accent
                  : const Color(0xFF444444),
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewCard(Review r) {
    final dateFmt = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: AppColors.accent, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.account_circle,
                        color: AppColors.textLight, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        r.reviewerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                dateFmt.format(r.createdAt),
                style: const TextStyle(
                    color: Color(0xFF888888), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                Icon(
                  Icons.star,
                  size: 18,
                  color: i <= r.rating
                      ? AppColors.star
                      : const Color(0xFF444444),
                ),
              const SizedBox(width: 10),
              Text(
                '${r.rating}/5',
                style: const TextStyle(
                  color: AppColors.star,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.text.isEmpty
                ? '(Pengguna hanya memberikan rating tanpa ulasan tertulis)'
                : r.text,
            style: TextStyle(
              color: r.text.isEmpty
                  ? const Color(0xFF666666)
                  : const Color(0xFFE0E0E0),
              fontStyle:
                  r.text.isEmpty ? FontStyle.italic : FontStyle.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}