import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_title.dart';
import '../widgets/hero_section.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showComingSoonDialog(BuildContext ctx, Movie m) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Column(
          children: [
            Icon(Icons.event_busy, color: AppColors.accent, size: 48),
            SizedBox(height: 12),
            Text('Film Belum Dirilis',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
        content: const Text(
          'Maaf, film ini belum dirilis. Nantikan segera!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textLight),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Tutup',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openDetail(Movie m) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(movieId: m.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trending    = DummyData.trending;
    final recommended = DummyData.recommended;
    final comingSoon  = DummyData.comingSoon;

    final isSearching = _query.isNotEmpty;
    List<Movie> filteredAll = [];
    if (isSearching) {
      filteredAll = DummyData.movies.where((m) =>
          m.title.toLowerCase().contains(_query.toLowerCase()) ||
          m.genre.toLowerCase().contains(_query.toLowerCase())).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Navbar(
              searchCtrl: _searchCtrl,
              onSearch: (v) => setState(() => _query = v.trim()),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isSearching) const HeroSection(),

                    if (isSearching) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Row(
                          children: [
                            const Icon(Icons.search,
                                color: AppColors.accent, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hasil Pencarian: "$_query"',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          'Ditemukan ${filteredAll.length} film',
                          style: const TextStyle(
                              color: AppColors.textGray, fontSize: 13),
                        ),
                      ),
                      if (filteredAll.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.search_off,
                                    size: 80, color: Color(0xFF333333)),
                                SizedBox(height: 20),
                                Text('Tidak Ditemukan',
                                    style: TextStyle(
                                        color: AppColors.textGray,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('Coba kata kunci lain',
                                    style: TextStyle(
                                        color: AppColors.textGray,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        )
                      else
                        _horizontalRow(filteredAll),
                    ] else ...[
                      if (trending.isNotEmpty) ...[
                        const SectionTitle(
                            icon: Icons.local_fire_department,
                            title: 'Top 3 Film Trending'),
                        _horizontalRow(trending, isTrending: true),
                      ],
                      if (recommended.isNotEmpty) ...[
                        const SectionTitle(
                            icon: Icons.list, title: 'Daftar Film'),
                        _horizontalRow(recommended),
                      ],
                      if (comingSoon.isNotEmpty) ...[
                        const SectionTitle(
                            icon: Icons.calendar_month,
                            title: 'Coming Soon!'),
                        _horizontalRow(comingSoon, isComingSoon: true),
                      ],
                    ],

                    const AppFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizontalRow(List<Movie> movies,
      {bool isTrending = false, bool isComingSoon = false}) {
    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final m = movies[i];
          String? badge;
          Color badgeColor = AppColors.accent;

          if (isTrending) {
            badge = '🔥 Top ${i + 1}';
          } else if (isComingSoon) {
            badge = '🕐 Coming Soon';
            badgeColor = const Color(0xFF558B2F);
          } else {
            badge = '⭐ Daftar Film';
            badgeColor = const Color(0xFF0277BD);
          }

          return SizedBox(
            width: 180,
            child: MovieCard(
              movie: m,
              badgeText: badge,
              badgeColor: badgeColor,
              onTap: isComingSoon
                  ? () => _showComingSoonDialog(context, m)
                  : () => _openDetail(m),
            ),
          );
        },
      ),
    );
  }
}