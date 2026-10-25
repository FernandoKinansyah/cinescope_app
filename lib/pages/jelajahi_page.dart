import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../theme/app_theme.dart';
import '../utils/movie_row_splitter.dart';
import 'detail_page.dart';

class JelajahiPage extends StatefulWidget {
  const JelajahiPage({super.key});

  @override
  State<JelajahiPage> createState() => _JelajahiPageState();
}

class _JelajahiPageState extends State<JelajahiPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _genreFilter;
  int? _yearFilter;
  String? _sortBy;

  List<Movie> _allMovies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final movies = await MovieService.getAllWithStats();
      setState(() {
        _allMovies = movies.where((m) => m.status == 'released').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat: $e';
        _isLoading = false;
      });
    }
  }

  List<Movie> get _filtered {
    var list = List<Movie>.from(_allMovies);

    if (_query.isNotEmpty) {
      list = list
          .where((m) =>
              m.title.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    if (_genreFilter != null) {
      list = list.where((m) => m.genre.contains(_genreFilter!)).toList();
    }
    if (_yearFilter != null) {
      list = list.where((m) => m.releaseYear == _yearFilter).toList();
    }
    if (_sortBy == 'rating') {
      list.sort((a, b) => b.avgRating.compareTo(a.avgRating));
    } else if (_sortBy == 'newest') {
      list.sort((a, b) =>
          (b.releaseYear ?? 0).compareTo(a.releaseYear ?? 0));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final genres = _allMovies
        .expand((m) => m.genre.split(',').map((g) => g.trim()))
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final years = _allMovies
        .map((m) => m.releaseYear)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Jelajahi Film',
            style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _error != null
              ? _errorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Jelajahi Semua Film',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Menampilkan ${_filtered.length} film',
                          style: const TextStyle(
                              color: AppColors.textGray, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari film...',
                          hintStyle:
                              const TextStyle(color: AppColors.textGray),
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.accent),
                          filled: true,
                          fillColor: AppColors.cardBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFF444444)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFF444444)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.accent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _dropdown<String>(
                              hint: 'Semua Genre',
                              value: _genreFilter,
                              items: genres
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _genreFilter = v),
                            ),
                            const SizedBox(width: 10),
                            _dropdown<int>(
                              hint: 'Semua Tahun',
                              value: _yearFilter,
                              items: years
                                  .map((y) => DropdownMenuItem(
                                        value: y,
                                        child: Text('$y',
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _yearFilter = v),
                            ),
                            const SizedBox(width: 10),
                            _dropdown<String>(
                              hint: 'Urutkan',
                              value: _sortBy,
                              items: const [
                                DropdownMenuItem(
                                  value: 'rating',
                                  child: Text('Rating Tertinggi',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                DropdownMenuItem(
                                  value: 'newest',
                                  child: Text('Terbaru',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                              onChanged: (v) => setState(() => _sortBy = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Movies
                      if (_filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
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
                        _responsiveMovies(_filtered),
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
            Text(_error ?? 'Error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadMovies,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF444444)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint,
              style: const TextStyle(
                  color: AppColors.textGray, fontSize: 13)),
          dropdownColor: AppColors.cardBg,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
          onChanged: onChanged,
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text(hint,
                  style: const TextStyle(
                      color: AppColors.textGray, fontSize: 13)),
            ),
            ...items,
          ],
        ),
      ),
    );
  }

  /// AUTO: HP = horizontal scroll, Desktop = grid 3 kolom
  Widget _responsiveMovies(List<Movie> movies) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          final rows = MovieRowSplitter.split(movies);
          return Column(
            children: rows.map((rowMovies) {
              final startIndex = movies.indexOf(rowMovies.first);
              return SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: rowMovies.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    return SizedBox(
                      width: 160,
                      child: _buildCard(rowMovies[i]),
                    );
                  },
                ),
              );
            }).toList(),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.52,
          ),
          itemBuilder: (context, i) => _buildCard(movies[i]),
        );
      },
    );
  }

  Widget _buildCard(Movie m) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(movieId: m.id)),
      ).then((_) => _loadMovies()),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: m.poster != null && m.poster!.isNotEmpty
                  ? Image.network(
                      m.poster!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${m.genre} | ${m.releaseYear ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textGray, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.star, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${m.avgRating.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          color: AppColors.star,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF667EEA),
      child: const Center(
        child: Text('🎬', style: TextStyle(fontSize: 48)),
      ),
    );
  }
}