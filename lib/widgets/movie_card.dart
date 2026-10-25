import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final String? badgeText;
  final Color badgeColor;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.badgeText,
    this.badgeColor = AppColors.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === POSTER (aspect 2:3) ===
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  movie.poster != null && movie.poster!.isNotEmpty
                      ? Image.network(
                          movie.poster!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                  if (badgeText != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // === INFO ===
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          movie.genre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    if (movie.status == 'released') ...[
                      Row(
                        children: [
                          const Icon(Icons.comment,
                              size: 10, color: AppColors.commentBlue),
                          const SizedBox(width: 2),
                          Text(
                            '${movie.reviewCount}',
                            style: const TextStyle(
                                color: AppColors.commentBlue,
                                fontSize: 9),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.favorite,
                              size: 10, color: AppColors.likeRed),
                          const SizedBox(width: 2),
                          Text(
                            '${movie.likeCount}',
                            style: const TextStyle(
                                color: AppColors.likeRed, fontSize: 9),
                          ),
                          const Spacer(),
                          const Icon(Icons.star,
                              size: 11, color: AppColors.star),
                          const SizedBox(width: 2),
                          Text(
                            movie.avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.star,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        movie.releaseDate != null
                            ? '📅 ${_formatTanggal(movie.releaseDate!)}'
                            : '⏳ Segera',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textGray, fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF666666),
      child: const Center(
        child: Text('🎬', style: TextStyle(fontSize: 32)),
      ),
    );
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${bulan[d.month]} ${d.year}';
  }
}