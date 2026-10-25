import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/supabase_auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/movie_row_splitter.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_title.dart';
import '../widgets/hero_section.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import 'detail_page.dart';
import 'user_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<Movie> _trending = [];
  List<Movie> _daftarFilm = [];
  List<Movie> _comingSoon = [];
  List<Movie> _allMovies = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = SupabaseAuthService.currentUser.value;
      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserHomePage()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        MovieService.getTrending(limit: 3),
        MovieService.getRecommended(),
        MovieService.getComingSoon(),
        MovieService.getAllWithStats(),
      ]);

      setState(() {
        _trending = results[0] as List<Movie>;
        _daftarFilm = results[1] as List<Movie>; // sekarang SEMUA released
        _comingSoon = results[2] as List<Movie>;
        _allMovies = results[3] as List<Movie>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat film: $e';
        _isLoading = false;
      });
    }
  }

  List<Movie> get _filtered {
    if (_query.isEmpty) return [];
    return _allMovies
        .where((m) =>
            m.title.toLowerCase().contains(_query.toLowerCase()) ||
            m.genre.toLowerCase().contains(_query.toLowerCase()))
        .toList();
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
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseAuthService.currentUser.value;
    if (user != null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final isSearching = _query.isNotEmpty;

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
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.accent,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      )
                    : _error != null
                        ? _errorView()
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth: 1400),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (!isSearching) const HeroSection(),
                                    if (isSearching)
                                      _searchView()
                                    else
                                      _normalView(),
                                    const AppFooter(),
                                  ],
                                ),
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
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
            Text(
              _error ?? 'Error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchView() {
    final results = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.accent, size: 22),
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
            'Ditemukan ${results.length} film',
            style: const TextStyle(
                color: AppColors.textGray, fontSize: 13),
          ),
        ),
        if (results.isEmpty)
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
                          color: AppColors.textGray, fontSize: 14)),
                ],
              ),
            ),
          )
        else
          _responsiveMovies(results),
      ],
    );
  }

  Widget _normalView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === Top Trending ===
        if (_trending.isNotEmpty) ...[
          const SectionTitle(
              icon: Icons.local_fire_department,
              title: 'Top 3 Film Trending'),
          _singleRow(_trending, isTrending: true),
        ],

        // === Daftar Film (SEMUA released, urut terbaru) ===
        if (_daftarFilm.isNotEmpty) ...[
          const SectionTitle(icon: Icons.list, title: 'Daftar Film'),
          _multiRows(_daftarFilm),
        ],

        // === Coming Soon ===
        if (_comingSoon.isNotEmpty) ...[
          const SectionTitle(
              icon: Icons.calendar_month, title: 'Coming Soon!'),
          _multiRows(_comingSoon, isComingSoon: true),
        ],
      ],
    );
  }

  Widget _singleRow(List<Movie> movies,
      {bool isTrending = false, bool isComingSoon = false}) {
    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          return SizedBox(
            width: 180,
            child: _buildCard(movies[i], i,
                isTrending: isTrending, isComingSoon: isComingSoon),
          );
        },
      ),
    );
  }

  Widget _multiRows(List<Movie> movies,
      {bool isTrending = false, bool isComingSoon = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 900) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: movies.length,
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.5,
              ),
              itemBuilder: (context, i) => _buildCard(
                movies[i], i,
                isTrending: isTrending,
                isComingSoon: isComingSoon,
              ),
            ),
          );
        }

        final rows = MovieRowSplitter.split(movies);
        return Column(
          children: rows.map((rowMovies) {
            final startIndex = movies.indexOf(rowMovies.first);
            return SizedBox(
              height: 340,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: rowMovies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final globalIndex = startIndex + i;
                  return SizedBox(
                    width: 160,
                    child: _buildCard(
                      rowMovies[i], globalIndex,
                      isTrending: isTrending,
                      isComingSoon: isComingSoon,
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _responsiveMovies(List<Movie> movies) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 900) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: movies.length,
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.5,
              ),
              itemBuilder: (context, i) => _buildCard(movies[i], i),
            ),
          );
        }

        return SizedBox(
          height: 340,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) => SizedBox(
              width: 160,
              child: _buildCard(movies[i], i),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(Movie m, int i,
      {bool isTrending = false, bool isComingSoon = false}) {
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

    return MovieCard(
      movie: m,
      badgeText: badge,
      badgeColor: badgeColor,
      onTap: isComingSoon
          ? () => _showComingSoonDialog(context, m)
          : () => _openDetail(m),
    );
  }
}