import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../data/watchlist_store.dart';
import '../theme/app_theme.dart';
import 'detail_page.dart';

class DaftarTontonPage extends StatefulWidget {
  const DaftarTontonPage({super.key});

  @override
  State<DaftarTontonPage> createState() => _DaftarTontonPageState();
}

class _DaftarTontonPageState extends State<DaftarTontonPage> {
  @override
  void initState() {
    super.initState();
    WatchlistStore.setMovies(DummyData.movies);
    WatchlistStore.notifier.addListener(_onChange);
  }

  @override
  void dispose() {
    WatchlistStore.notifier.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = WatchlistStore.movies;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Daftar Tonton Saya',
            style: TextStyle(color: Colors.white)),
      ),
      body: list.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) => _card(list[i]),
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
            const Icon(Icons.movie_filter,
                size: 80, color: AppColors.accent),
            const SizedBox(height: 20),
            const Text('Daftar Tonton Kosong',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Anda belum menambahkan film apapun ke daftar tonton.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(movie) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Poster
          SizedBox(
            width: 100,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                movie.poster != null
                    ? Image.network(movie.poster!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF333333),
                        child: const Center(
                          child: Text('🎬',
                              style: TextStyle(fontSize: 36)),
                        ),
                      ),
                const Positioned(
                  top: 6, right: 6,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.favorite,
                        color: Colors.white, size: 14),
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
                  Text(movie.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
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
                              color: AppColors.textGray, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
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
                          ),
                          icon: const Icon(Icons.info_outline,
                              size: 14),
                          label: const Text('Detail',
                              style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                                color: Color(0xFF555555)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            WatchlistStore.remove(movie.id);
                          },
                          icon: const Icon(Icons.delete, size: 14),
                          label: const Text('Hapus',
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8),
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
}