import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';
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
  String? _sortBy; // 'rating' | 'newest'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Movie> get _filtered {
    var list = DummyData.allReleased;
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
      list = List.from(list)
        ..sort((a, b) => b.avgRating.compareTo(a.avgRating));
    } else if (_sortBy == 'newest') {
      list = List.from(list)
        ..sort((a, b) =>
            (b.releaseYear ?? 0).compareTo(a.releaseYear ?? 0));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final genres = DummyData.allReleased
        .expand((m) => m.genre.split(',').map((g) => g.trim()))
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final years = DummyData.allReleased
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
      body: SingleChildScrollView(
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
                hintStyle: const TextStyle(color: AppColors.textGray),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.accent),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF444444)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF444444)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent),
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

            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filtered.length,
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.55,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, i) {
                final m = _filtered[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailPage(movieId: m.id)),
                  ),
                  child: _movieGridCard(m),
                );
              },
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
          icon: const Icon(Icons.arrow_drop_down,
              color: AppColors.accent),
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

  Widget _movieGridCard(Movie m) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: m.poster != null
                ? Image.network(m.poster!, fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFF667EEA),
                    child: const Center(
                      child: Text('🎬', style: TextStyle(fontSize: 40)),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${m.genre} | ${m.releaseYear ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textGray, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.star, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${m.avgRating.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}