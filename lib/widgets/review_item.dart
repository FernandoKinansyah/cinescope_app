import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';

class ReviewItem extends StatelessWidget {
  final Review review;
  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(6),
        border: const Border(
          left: BorderSide(color: AppColors.accent, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars
          Row(
            children: List.generate(5, (i) {
              return Icon(
                Icons.star,
                size: 16,
                color: i < review.rating ? AppColors.star : const Color(0xFF444444),
              );
            }),
          ),
          const SizedBox(height: 10),
          // Text
          Text(
            review.text.isEmpty ? '(Tidak ada ulasan tertulis)' : review.text,
            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 14),
          ),
          const SizedBox(height: 10),
          // Reviewer info
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF555555), style: BorderStyle.solid),
              ),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Oleh: ${review.reviewerName} - ${dateFmt.format(review.createdAt)}',
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}