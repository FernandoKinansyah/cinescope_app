import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.navbarBg,
        border: Border(top: BorderSide(color: Color(0xFF333333))),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 32,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _section('CineScope',
                  'Platform review film terbaik untuk komunitas pencinta sinema Indonesia'),
              _linksSection('Tautan', [
                ('Tentang Kami', 'tentang kami.php'),
                ('Kebijakan Privasi', 'kebijakan privasi.php'),
                ('Syarat & Ketentuan', 'syarat & ketentuan.php'),
              ]),
              _socialSection(),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF333333)),
          const SizedBox(height: 12),
          const Text(
            '© 2024 CineScope. All rights reserved.',
            style: TextStyle(color: AppColors.textGray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String desc) {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _linksSection(String title, List<(String, String)> links) {
    return SizedBox(
      width: 250,
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...links.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () {},
                  child: Text(l.$1,
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 13)),
                ),
              )),
        ],
      ),
    );
  }

  Widget _socialSection() {
    return SizedBox(
      width: 250,
      child: Column(
        children: [
          const Text('Ikuti Kami',
              style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icon(Icons.alternate_email, 'https://x.com/piesekkn'),
              const SizedBox(width: 16),
              _icon(Icons.facebook,
                  'https://www.facebook.com/share/17aUUywEem/'),
              const SizedBox(width: 16),
              _icon(Icons.camera_alt,
                  'https://www.instagram.com/fernandokinansyah_'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) launchUrl(uri);
      },
      child: Icon(icon, color: AppColors.textLight, size: 24),
    );
  }
}