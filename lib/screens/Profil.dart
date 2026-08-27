import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/app_data.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});
  @override
  ProfilState createState() => ProfilState();
}

class ProfilState extends State<Profil> {
  final int _selectedIndex = 3; // Tab Profil aktif

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────
            _buildHeader(),

            // ── CONTENT ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF3D5AFE).withValues(alpha: 0.15),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      // ── Setelan Awal Absensi ──
                      ListenableBuilder(
                        listenable: AppData(),
                        builder: (context, _) {
                          final current = AppData().defaultAbsensiStatus;
                          return _buildMenuItem(
                            icon: Icons.checklist_rtl_outlined,
                            title: 'Setelan Awal Absensi',
                            subtitle: current,
                            onTap: () {
                              final next = current == 'Hadir' ? 'Alfa' : 'Hadir';
                              AppData().setDefaultAbsensiStatus(next);
                            },
                          );
                        },
                      ),
                      _buildDivider(),

                      // ── Statistik Nilai ──
                      _buildStatistikNilai(),
                      _buildDivider(),

                      // ── Tema ──
                      _buildMenuItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Tema',
                        subtitle: 'Gelap',
                        onTap: () {
                          // TODO: Implementasi ganti tema
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Versi Aplikasi ──
                      Text(
                        '1.0',
                        style: TextStyle(
                          color: const Color(0xFFAC9F9F),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── BOTTOM NAV ──────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/base.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Overlay gelap
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            // Judul
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    'Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MENU ITEM ─────────────────────────────────────────────────────────────
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFC0B6B6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.6),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  // ── STATISTIK NILAI ──────────────────────────────────────────────────────
  Widget _buildStatistikNilai() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistik Nilai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nilai default:\n'
                  '• Nilai A: Nilai lebih dari 90\n'
                  '• Nilai B: Nilai lebih dari 80 dan ≤ 90\n'
                  '• Nilai C: Nilai ≥ 60 dan ≤ 80\n'
                  '• Nilai D: Nilai kurang dari 60\n'
                  'Jika nilai tidak sesuai bisa diubah',
                  style: const TextStyle(
                    color: Color(0xFFC0B6B6),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.bar_chart_outlined,
            color: Colors.white.withValues(alpha: 0.6),
            size: 26,
          ),
        ],
      ),
    );
  }

  // ── DIVIDER ────────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 1,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(svgPath: 'assets/icons/Home.svg', label: 'Beranda'),
      _NavItem(svgPath: 'assets/icons/Calendar.svg', label: 'Absensi'),
      _NavItem(svgPath: 'assets/icons/Paper.svg', label: 'Nilai'),
      _NavItem(svgPath: 'assets/icons/Profile (2).svg', label: 'Profil'),
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final isActive = _selectedIndex == i;
                final color = isActive
                    ? const Color(0xFF554DE7)
                    : const Color(0xFF888888);
                return GestureDetector(
                  onTap: () {
                    if (_selectedIndex == i) return;
                    if (i == 0) {
                      Navigator.pushReplacementNamed(context, '/HomeSekolah');
                    } else if (i == 1) {
                      Navigator.pushReplacementNamed(context, '/Absensi');
                    } else if (i == 2) {
                      Navigator.pushReplacementNamed(context, '/Nilai');
                    } else if (i == 3) {
                      Navigator.pushReplacementNamed(context, '/Profil');
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        items[i].svgPath,
                        width: 26,
                        height: 26,
                        colorFilter:
                            ColorFilter.mode(color, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String svgPath;
  final String label;
  const _NavItem({required this.svgPath, required this.label});
}