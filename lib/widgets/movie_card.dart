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
            // Poster (aspect ratio 2:3)
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  movie.poster != null
                      ? Image.network(movie.poster!, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFF666666),
                          child: const Center(
                            child: Text('🎬', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                  if (badgeText != null)
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.genre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (movie.status == 'released') ...[
                    Row(
                      children: [
                        const Icon(Icons.comment,
                            size: 13, color: AppColors.commentBlue),
                        const SizedBox(width: 4),
                        Text('${movie.reviewCount} komentar',
                            style: const TextStyle(
                                color: AppColors.commentBlue, fontSize: 11)),
                        const SizedBox(width: 10),
                        const Icon(Icons.favorite,
                            size: 13, color: AppColors.likeRed),
                        const SizedBox(width: 4),
                        Text('${movie.likeCount} like',
                            style: const TextStyle(
                                color: AppColors.likeRed, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: AppColors.star),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.avgRating.toStringAsFixed(1)}/5.0',
                          style: const TextStyle(
                            color: AppColors.star,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      movie.releaseDate != null
                          ? '📅 Rilis ${_formatTanggal(movie.releaseDate!)}'
                          : '⏳ Segera Hadir',
                      style: const TextStyle(
                          color: AppColors.textGray, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTanggal(DateTime d) {
    const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                   'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${bulan[d.month]} ${d.year}';
  }
}