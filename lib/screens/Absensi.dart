import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Absensi extends StatefulWidget {
  const Absensi({super.key});

  @override
  State<Absensi> createState() => _AbsensiState();
}

class _AbsensiState extends State<Absensi> {
  int _selectedIndex = 1; // Tab "Absensi" aktif

  // ─── Data Kosong (Akan diisi nanti) ──────────────────────────
  final List<Map<String, dynamic>> listAbsensi = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── HEADER ───
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 20),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/base.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Absensi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── DAFTAR KARTU ABSENSI ───
            Expanded(
              child: listAbsensi.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_edu,
                            color: Colors.white.withOpacity(0.2),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada absensi.\nSilakan buat kelas dan absen terlebih dahulu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: listAbsensi.length,
                itemBuilder: (context, index) {
                  return _buildAbsensiCard(listAbsensi[index]);
                },
              ),
            ),
          ],
        ),
      ),
      // ─── FAB TAMBAH ABSENSI ──────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAbsensiModal(context);
        },
        backgroundColor: const Color(0xFF1C3393),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── MODAL TAMBAH ABSENSI (PLACEHOLDER) ────────────────────────────────────
  void _showAddAbsensiModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFF1C3393), width: 2),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Absensi Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Informasi Placeholder
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Form pembuatan absensi akan ditambahkan di sini pada tahap selanjutnya. Kita perlu menyiapkan logika pemilihan Kelas dan Tanggal terlebih dahulu.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C3393),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tutup Sementara',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── WIDGET: CARD ABSENSI ───
  Widget _buildAbsensiCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF09102E),
            Color(0xFF1C3394),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C3393).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar / Logo Kelas
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF3D5AFE).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Color(0xFF666688),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          // Info Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tanggal
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    data['tanggal'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Nama Sekolah
                Text(
                  data['sekolah'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                // Nama Kelas
                Text(
                  data['kelas'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Indikator Kehadiran
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIndicator(Icons.check_circle_rounded, Colors.green, '${data['hadir']} Hadir'),
                    _buildIndicator(Icons.cancel_rounded, Colors.redAccent, '${data['alfa']} Alfa'),
                    _buildIndicator(Icons.info_rounded, Colors.orangeAccent, '${data['izin']} Izin'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ─── BOTTOM NAVBAR ──────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final List<_NavItem> items = [
      const _NavItem(svgPath: 'assets/icons/Home.svg', label: 'Beranda'),
      const _NavItem(svgPath: 'assets/icons/Calendar.svg', label: 'Absensi'),
      const _NavItem(svgPath: 'assets/icons/Paper.svg', label: 'Nilai'),
      const _NavItem(svgPath: 'assets/icons/Profile (2).svg', label: 'Profil'),
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
              color: Colors.white.withOpacity(0.08),
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
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    ));
  }
}

class _NavItem {
  final String svgPath;
  final String label;
  const _NavItem({
    required this.svgPath,
    required this.label,
  });
}