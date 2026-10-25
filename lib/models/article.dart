// lib/models/article.dart

class Article {
  final int id;
  final String title;
  final String imageUrl;
  final String excerpt;
  final String content;

  Article({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.excerpt,
    required this.content,
  });
}