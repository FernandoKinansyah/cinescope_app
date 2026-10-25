import 'package:flutter/material.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

class ArtikelDetailPage extends StatelessWidget {
  final Article article;
  const ArtikelDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Artikel',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar cover
            if (article.imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF333333),
                    child: const Center(
                      child: Icon(Icons.image,
                          color: Color(0xFF666666), size: 48),
                    ),
                  ),
                ),
              ),

            // Konten
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF333333)),
                  const SizedBox(height: 16),

                  // Excerpt (lead)
                  if (article.excerpt.isNotEmpty)
                    Text(
                      article.excerpt,
                      style: const TextStyle(
                        color: Color(0xFFDDDDDD),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Content
                  if (article.content.isNotEmpty)
                    Text(
                      article.content,
                      style: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 15,
                        height: 1.8,
                      ),
                    )
                  else
                    const Text(
                      '(Isi artikel belum tersedia)',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}