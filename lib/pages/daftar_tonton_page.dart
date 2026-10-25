import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/watchlist_service.dart';
import '../theme/app_theme.dart';
import 'detail_page.dart';

class DaftarTontonPage extends StatefulWidget {
  const DaftarTontonPage({super.key});

  @override
  State<DaftarTontonPage> createState() => _DaftarTontonPageState();
}

class _DaftarTontonPageState extends State<DaftarTontonPage> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final movies = await WatchlistService.getMyMovies();
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _remove(Movie m) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Hapus dari Daftar Tonton?',
            style: TextStyle(color: Colors.white)),
        content: Text('"${m.title}" akan dihapus dari daftar tonton Anda.',
            style: const TextStyle(color: AppColors.textLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await WatchlistService.remove(m.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Film dihapus dari daftar tonton')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Daftar Tonton Saya',
            style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _error != null
              ? _errorView()
              : _movies.isEmpty
                  ? _emptyState()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.accent,
                      child: _listView(),
                    ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.accent, size: 64),
            const SizedBox(height: 20),
            Text(_error ?? 'Error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border,
                size: 96, color: AppColors.accent),
            const SizedBox(height: 24),
            const Text(
              'Daftar Tonton Kosong',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Anda belum menambahkan film apapun.\nBuka detail film dan klik "Daftar Tonton".',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movies.length,
      itemBuilder: (context, i) => _card(_movies[i]),
    );
  }

  Widget _card(Movie movie) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Poster
          SizedBox(
            width: 110,
            height: 165,
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
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.bookmark,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.local_offer,
                          color: AppColors.star, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          movie.genre,
                          style: const TextStyle(
                              color: AppColors.textGray, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.releaseYear ?? '-'} • ${movie.duration ?? '-'}',
                    style: const TextStyle(
                        color: AppColors.textGray, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.star, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.avgRating.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                            color: AppColors.star,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailPage(movieId: movie.id)),
                          ).then((_) => _loadData()),
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Detail',
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                                color: Color(0xFF555555)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _remove(movie),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Hapus',
                              style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF333333),
      child: const Center(
        child: Text('🎬', style: TextStyle(fontSize: 36)),
      ),
    );
  }
}