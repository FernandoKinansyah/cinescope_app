// lib/services/article_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';

class ArticleService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Ambil semua artikel
  static Future<List<Article>> getAll() async {
    final data = await _supabase
        .from('articles')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => _toArticle(e)).toList();
  }

  /// Ambil artikel by ID
  static Future<Article?> getById(int id) async {
    final data = await _supabase
        .from('articles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return _toArticle(data);
  }

  /// Convert dari Supabase (Map) ke model Article
  static Article _toArticle(Map<String, dynamic> e) {
    return Article(
      id: e['id'] as int,
      title: e['title'] as String? ?? '',
      imageUrl: e['image_url'] as String? ?? '',
      excerpt: e['excerpt'] as String? ?? '',
      content: e['content'] as String? ?? '',
    );
  }
}