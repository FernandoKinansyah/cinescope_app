import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../pages/jelajahi_page.dart';
import '../pages/daftar_tonton_page.dart';
import '../pages/artikel_page.dart';

class UserNavbar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final String username;
  final VoidCallback onLogout;

  const UserNavbar({
    super.key,
    required this.searchCtrl,
    required this.onSearch,
    required this.username,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navbarBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'CineScope',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: onSearch,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari film...',
                      hintStyle: const TextStyle(color: AppColors.textGray),
                      filled: true,
                      fillColor: AppColors.cardBg,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      suffixIcon: const Icon(Icons.search,
                          color: AppColors.accent, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(color: Color(0xFF333333)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(color: Color(0xFF333333)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _navItem(context, 'Jelajahi', Icons.explore, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const JelajahiPage()),
                  );
                }),
                _navItem(context, 'Daftar Tonton', Icons.bookmark, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DaftarTontonPage()),
                  );
                }),
                _navItem(context, 'Artikel', Icons.article, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ArtikelPage()),
                  );
                }),
                _navItem(context, 'Akun', Icons.person, () {
                  _showAccountMenu(context);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, IconData icon,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textLight, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  username,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF333333)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.accent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}