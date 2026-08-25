import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../data/app_data.dart';

class Absensi extends StatefulWidget {
  const Absensi({super.key});

  @override
  State<Absensi> createState() => _AbsensiState();
}

class _AbsensiState extends State<Absensi> {
  int _selectedIndex = 1; // Tab "Absensi" aktif

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppData(),
      builder: (context, _) {
        final listAbsensi = AppData().getSortedAbsensi();

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

            // ─── GRAFIK BULAN INI ───
            _buildBulanIniChart(listAbsensi),

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
                            'Belum ada absensi bulan ini.\nSilakan buat kelas dan absen terlebih dahulu.',
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: listAbsensi.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/DetailRiwayatAbsensi', arguments: listAbsensi[index]);
                          },
                          child: _buildAbsensiCard(listAbsensi[index]),
                        );
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
      },
    );
  }

  // ─── MODAL TAMBAH ABSENSI ────────────────────────────────────────────────
  void _showAddAbsensiModal(BuildContext context) {
    String? selectedKelasId;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final kelasku = AppData().kelasList;

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
                      'Pilih Kelas & Tanggal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Dropdown Kelas
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Kelas',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF554DE7)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.3),
                      ),
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.white),
                      value: selectedKelasId,
                      items: kelasku.map((k) {
                        return DropdownMenuItem(
                          value: k.id,
                          child: Text(k.nama),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateModal(() {
                          selectedKelasId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Pilih Tanggal
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateModal(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const Icon(Icons.calendar_month_outlined, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Tombol Lanjut
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedKelasId != null) {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/FormAbsensi', arguments: {
                              'kelasId': selectedKelasId,
                              'tanggal': selectedDate,
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Silakan pilih kelas terlebih dahulu!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C3393),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Mulai Absensi',
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
      },
    );
  }

  // ─── WIDGET: GRAFIK BULAN INI ───
  Widget _buildBulanIniChart(List<AbsensiRecord> records) {
    // Filter hanya bulan ini
    final now = DateTime.now();
    final thisMonthRecords = records.where((r) => r.tanggal.month == now.month && r.tanggal.year == now.year).toList();

    int totalHadir = 0;
    int totalAlfa = 0;
    int totalIzin = 0;

    for (var r in thisMonthRecords) {
      totalHadir += r.countHadir;
      totalAlfa += r.countAlfa;
      totalIzin += r.countIzin;
    }

    final total = totalHadir + totalAlfa + totalIzin;
    final wHadir = total == 0 ? 0.0 : (totalHadir / total);
    final wAlfa = total == 0 ? 0.0 : (totalAlfa / total);
    final wIzin = total == 0 ? 0.0 : (totalIzin / total);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3D5AFE).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistik ${DateFormat('MMMM yyyy', 'id_ID').format(now)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.bar_chart, color: Color(0xFF554DE7)),
            ],
          ),
          const SizedBox(height: 20),
          // Horizontal Segmented Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 20,
              width: double.infinity,
              child: total == 0 
                ? Container(color: Colors.white.withOpacity(0.1))
                : Row(
                    children: [
                      if (wHadir > 0) Expanded(flex: (wHadir * 100).toInt(), child: Container(color: Colors.green)),
                      if (wAlfa > 0) Expanded(flex: (wAlfa * 100).toInt(), child: Container(color: Colors.redAccent)),
                      if (wIzin > 0) Expanded(flex: (wIzin * 100).toInt(), child: Container(color: Colors.orangeAccent)),
                    ],
                  ),
            ),
          ),
          const SizedBox(height: 16),
          // Legends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegend(Colors.green, 'Hadir', totalHadir),
              _buildLegend(Colors.redAccent, 'Alfa', totalAlfa),
              _buildLegend(Colors.orangeAccent, 'Izin/Sakit', totalIzin),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  // ─── WIDGET: CARD ABSENSI ───
  Widget _buildAbsensiCard(AbsensiRecord data) {
    final namaKelas = AppData().getNamaKelas(data.kelasId);
    final sekolahId = AppData().getSekolahIdByKelas(data.kelasId);
    final sekolah = AppData().sekolahList.firstWhere((s) => s.id == sekolahId);

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
          // Gambar / Logo Sekolah
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF3D5AFE).withOpacity(0.3),
              ),
              image: (sekolah.imageUrl != null && sekolah.imageUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: FileImage(File(sekolah.imageUrl!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (sekolah.imageUrl == null || sekolah.imageUrl!.isEmpty)
                ? const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF666688),
                    size: 32,
                  )
                : null,
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
                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(data.tanggal),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Nama Sekolah
                Text(
                  sekolah.nama,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                // Nama Kelas
                Text(
                  namaKelas,
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
                    _buildIndicator(Icons.check_circle_rounded, Colors.green, '${data.countHadir} Hadir'),
                    _buildIndicator(Icons.cancel_rounded, Colors.redAccent, '${data.countAlfa} Alfa'),
                    _buildIndicator(Icons.info_rounded, Colors.orangeAccent, '${data.countIzin} Izin'),
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
                    } else if (i == 2) {
                      Navigator.pushReplacementNamed(context, '/Nilai');
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