import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../data/app_data.dart';
import 'FormNilai.dart';

class Nilai extends StatefulWidget {
  const Nilai({super.key});

  @override
  NilaiState createState() => NilaiState();
}

class NilaiState extends State<Nilai> {
  int _selectedIndex = 2; // Tab "Nilai" aktif

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppData(),
      builder: (context, _) {
        final listTugas = AppData().getSortedTugas();

        return Scaffold(
          backgroundColor: const Color(0xFF111111),
          body: SafeArea(
            child: Column(
              children: [
                // ── HEADER ──────────────────────────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        left: 24, right: 24, top: 40, bottom: 24),
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
                          'Nilai',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Daftar tugas & nilai siswa',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── CONTENT ─────────────────────────────────────────────
                Expanded(
                  child: listTugas.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          itemCount: listTugas.length,
                          itemBuilder: (context, index) {
                            return _buildTugasCard(listTugas[index]);
                          },
                        ),
                ),
              ],
            ),
          ),

          // ── FAB ──────────────────────────────────────────────────────
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTugasModal(context),
            backgroundColor: const Color(0xFF1C3393),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),

          // ── BOTTOM NAV ───────────────────────────────────────────────
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // ── EMPTY STATE ────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Belum ada Tugas',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Klik tombol + untuk menambah tugas',
            style: TextStyle(
                color: Colors.white.withOpacity(0.3), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── CARD TUGAS ─────────────────────────────────────────────────────────
  Widget _buildTugasCard(TugasRecord tugas) {
    final namaKelas = AppData().getNamaKelas(tugas.kelasId);
    final jumlahSiswa =
        AppData().getSiswaByKelas(tugas.kelasId).length;
    final jumlahNilaiTerisi =
        tugas.nilaiSiswa.values.where((v) => v.trim().isNotEmpty).length;
    final sudahLengkap =
        jumlahSiswa > 0 && jumlahNilaiTerisi == jumlahSiswa;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormNilai(tugas: tugas),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF3D5AFE).withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C3393).withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card (gradient) ──
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF08102D), Color(0xFF1C3393)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(19),
                  topRight: Radius.circular(19),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nama kelas
                  Row(
                    children: [
                      const Icon(Icons.class_outlined,
                          color: Colors.white70, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        namaKelas,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Tombol Hapus
                  GestureDetector(
                    onTap: () =>
                        _showDeleteConfirm(context, tugas.id, tugas.namaTugas),
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 18),
                        SizedBox(width: 4),
                        Text('Hapus',
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body card ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Tugas
                  Text(
                    tugas.namaTugas,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (tugas.deskripsi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      tugas.deskripsi,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Info bawah: tanggal, jumlah siswa, status
                  Row(
                    children: [
                      // Tanggal
                      _buildChip(
                        Icons.calendar_today_outlined,
                        DateFormat('dd MMM yyyy', 'id_ID')
                            .format(tugas.tanggal),
                        const Color(0xFF554DE7).withOpacity(0.25),
                      ),
                      const SizedBox(width: 8),
                      // Jumlah nilai terisi / total
                      _buildChip(
                        Icons.grading_outlined,
                        '$jumlahNilaiTerisi/$jumlahSiswa Nilai',
                        sudahLengkap
                            ? Colors.green.withOpacity(0.25)
                            : Colors.orangeAccent.withOpacity(0.2),
                      ),
                      const Spacer(),
                      // Ikon panah
                      Icon(Icons.chevron_right,
                          color: Colors.white.withOpacity(0.4), size: 22),
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

  Widget _buildChip(IconData icon, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── MODAL TAMBAH TUGAS ─────────────────────────────────────────────────
  void _showAddTugasModal(BuildContext context) {
    if (AppData().kelasList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tambah Kelas terlebih dahulu!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String? selectedKelasId = AppData().kelasList.first.id;
    DateTime selectedDate = DateTime.now();
    final namaController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
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
                    // ── Judul ──
                    const Text(
                      'Tambah Tugas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Dropdown Kelas ──
                    DropdownButtonFormField<String>(
                      value: selectedKelasId,
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Pilih Kelas'),
                      items: AppData().kelasList.map((k) {
                        return DropdownMenuItem(
                            value: k.id, child: Text(k.nama));
                      }).toList(),
                      onChanged: (val) =>
                          setStateModal(() => selectedKelasId = val),
                    ),
                    const SizedBox(height: 16),

                    // ── Input Nama Tugas ──
                    TextField(
                      controller: namaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Nama Tugas'),
                    ),
                    const SizedBox(height: 16),

                    // ── Input Deskripsi ──
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: _inputDecoration('Deskripsi (opsional)'),
                    ),
                    const SizedBox(height: 16),

                    // ── Pilih Tanggal ──
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateModal(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMMM yyyy', 'id_ID')
                                  .format(selectedDate),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            const Icon(Icons.calendar_month_outlined,
                                color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Tombol Simpan ──
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (namaController.text.trim().isNotEmpty &&
                              selectedKelasId != null) {
                            AppData().addTugas(
                              selectedKelasId!,
                              selectedDate,
                              namaController.text.trim(),
                              descController.text.trim(),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Nama tugas dan kelas wajib diisi!'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C3393),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
    );
  }

  // ── MODAL HAPUS TUGAS ──────────────────────────────────────────────────
  void _showDeleteConfirm(
      BuildContext context, String id, String namaTugas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Hapus Tugas?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Hapus tugas "$namaTugas"? Semua nilai yang sudah diisi akan ikut terhapus.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              AppData().deleteTugas(id);
              Navigator.pop(context);
            },
            child: const Text('Hapus',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM NAV ─────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(svgPath: 'assets/icons/Home.svg', label: 'Beranda'),
      _NavItem(svgPath: 'assets/icons/Calendar.svg', label: 'Absensi'),
      _NavItem(svgPath: 'assets/icons/Paper.svg', label: 'Nilai'),
      _NavItem(
          svgPath: 'assets/icons/Profile (2).svg', label: 'Profil'),
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
                color: Colors.white.withOpacity(0.08), width: 1),
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
                      Navigator.pushReplacementNamed(
                          context, '/HomeSekolah');
                    } else if (i == 1) {
                      Navigator.pushReplacementNamed(
                          context, '/Absensi');
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