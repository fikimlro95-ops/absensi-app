import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/app_data.dart';
import '../data/export_helper.dart';

class HomeKelas extends StatefulWidget {
  const HomeKelas({super.key});
  @override
  HomeKelasState createState() => HomeKelasState();
}

class HomeKelasState extends State<HomeKelas> {
  int _selectedIndex = 0; // Tab "Beranda" aktif di halaman ini

  // ─── Path gambar header (asset lokal) ─────────────────────────────────
  final String? headerImageUrl = 'assets/base.png';

  // Data kelas dihapus, kita pakai AppData()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER ───────────────────────────────────────────────
            _buildHeader(),

            // ─── CONTENT ──────────────────────────────────────────────
            ListenableBuilder(
              listenable: AppData(),
              builder: (context, _) {
                final listKelas = AppData().kelasList;
                
                if (listKelas.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.meeting_room_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada Kelas',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Klik tombol + di bawah untuk menambah',
                            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      children: listKelas.map((k) {
                        return _buildKelasCard({
                          'id': k.id,
                          'sekolah': AppData().getNamaSekolah(k.sekolahId),
                          'kelas': k.nama,
                          'siswa': k.jumlahSiswa,
                          'deskripsi': k.deskripsi,
                        });
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // ─── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddKelasModal(context);
        },
        backgroundColor: const Color(0xFF1C3393),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // ─── BOTTOM NAV ───────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          // Jika headerImageUrl diisi → tampil gambar asset, jika null → gradient
          image: headerImageUrl != null
              ? DecorationImage(
                  image: AssetImage(headerImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: headerImageUrl == null
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF08102D),
                    Color(0xFF1C3393),
                  ],
                )
              : null,
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
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Settings icon
                  Align(
                    alignment: Alignment.topRight,
                    child: SvgPicture.asset(
                      'assets/icons/Setting (1).svg',
                      width: 28,
                      height: 28,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.9),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Judul "Sekolah" | "Kelas"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // "Sekolah" = klik untuk kembali (tanpa garis)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Sekolah',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 80),
                      // "Kelas" = halaman aktif → ada garis bawah
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Kelas',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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

  // ─── CARD KELAS ──────────────────────────────────────────────────────────
  Widget _buildKelasCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail kelas (kelola siswa)
        Navigator.pushNamed(context, '/DetailKelas', arguments: data['id']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0A0A0A),
        border: Border.all(
          color: const Color(0xFF3D5AFE).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C3393).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Badge nama sekolah (header card) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF08102D),
                  Color(0xFF1C3393),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['sekolah'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (data['id'] != null) {
                      _showDeleteConfirmKelas(context, data['id'], data['kelas']);
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                // Nama kelas + jumlah siswa
                Row(
                  children: [
                    Text(
                      data['kelas'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.people_outline,
                      color: Color(0xFF888888),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SISWA : ${data['siswa']}',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Deskripsi
                Text(
                  data['deskripsi'],
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Tombol aksi
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Export Absensi',
                        icon: Icons.file_download_outlined,
                        onTap: () => _showExportModal(
                          context: context,
                          kelasId: data['id'],
                          namaKelas: data['kelas'],
                          type: 'absensi',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Export Nilai',
                        icon: Icons.grade_outlined,
                        onTap: () => _showExportModal(
                          context: context,
                          kelasId: data['id'],
                          namaKelas: data['kelas'],
                          type: 'nilai',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  // ─── TOMBOL AKSI ─────────────────────────────────────────────────────────
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E30B8),
              Color(0xFF061552),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ─────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    // ─── Ganti nama file SVG di sini sesuai file kamu ──────────────────
    final List<_NavItem> items = [
      _NavItem(svgPath: 'assets/icons/Home.svg',         label: 'Beranda'),
      _NavItem(svgPath: 'assets/icons/Calendar.svg',     label: 'Absensi'),
      _NavItem(svgPath: 'assets/icons/Paper.svg',        label: 'Nilai'),
      _NavItem(svgPath: 'assets/icons/Profile (2).svg',  label: 'Profil'),
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

  // ─── MODAL EXPORT ──────────────────────────────────────────────────────────
  void _showExportModal({
    required BuildContext context,
    required String kelasId,
    required String namaKelas,
    required String type,
  }) {
    final periods = ExportPeriod.values;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
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
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF08102D), Color(0xFF1C3393)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      type == 'absensi'
                          ? Icons.file_download_outlined
                          : Icons.grade_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export ${type == 'absensi' ? 'Absensi' : 'Nilai'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        namaKelas,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih rentang waktu data yang akan diekspor:',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.65), fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...periods.map((period) => _buildPeriodOption(
                    ctx: ctx,
                    period: period,
                    kelasId: kelasId,
                    type: type,
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodOption({
    required BuildContext ctx,
    required ExportPeriod period,
    required String kelasId,
    required String type,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(ctx);
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('Menyiapkan export ${period.label}...'),
              ],
            ),
            backgroundColor: const Color(0xFF1C3393),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        try {
          if (type == 'absensi') {
            await ExportHelper.exportAbsensi(kelasId: kelasId, period: period);
          } else {
            await ExportHelper.exportNilai(kelasId: kelasId, period: period);
          }
          scaffold.hideCurrentSnackBar();
          scaffold.showSnackBar(
            SnackBar(
              content: Text('Export ${period.label} berhasil! 🎉'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        } catch (e) {
          scaffold.hideCurrentSnackBar();
          scaffold.showSnackBar(
            SnackBar(
              content: Text('Gagal export: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF3D5AFE).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF08102D), Color(0xFF1C3393)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  _periodIcon(period),
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _periodDesc(period),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  IconData _periodIcon(ExportPeriod p) {
    switch (p) {
      case ExportPeriod.minggu1:
        return Icons.view_week_outlined;
      case ExportPeriod.bulan1:
        return Icons.calendar_month_outlined;
      case ExportPeriod.bulan6:
        return Icons.date_range_outlined;
    }
  }

  String _periodDesc(ExportPeriod p) {
    switch (p) {
      case ExportPeriod.minggu1:
        return 'Data 7 hari terakhir';
      case ExportPeriod.bulan1:
        return 'Data 30 hari terakhir';
      case ExportPeriod.bulan6:
        return 'Data 180 hari terakhir';
    }
  }


  // ─── MODAL TAMBAH KELAS ──────────────────────────────────────────────────
  void _showAddKelasModal(BuildContext context) {
    // Jika belum ada sekolah, minta user buat sekolah dulu
    if (AppData().sekolahList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tambah Sekolah terlebih dahulu!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final TextEditingController namaController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String? selectedSekolahId = AppData().sekolahList.first.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Supaya modal bisa didorong oleh keyboard
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder( // Butuh StatefulBuilder agar dropdown bisa direbuild di dalam modal
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
                    const Text(
                      'Tambah Kelas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Dropdown Pilih Sekolah
                    DropdownButtonFormField<String>(
                      value: selectedSekolahId,
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Pilih Sekolah',
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
                      items: AppData().sekolahList.map((sekolah) {
                        return DropdownMenuItem(
                          value: sekolah.id,
                          child: Text(sekolah.nama),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateModal(() {
                          selectedSekolahId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Nama Kelas
                    TextField(
                      controller: namaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama Kelas',
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
                    ),
                    const SizedBox(height: 16),

                    // Input Deskripsi
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Kelas',
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
                    ),
                    const SizedBox(height: 32),
                    
                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (namaController.text.trim().isNotEmpty && selectedSekolahId != null) {
                            AppData().addKelas(
                              selectedSekolahId!,
                              namaController.text,
                              descController.text,
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C3393),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
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

  // ─── MODAL KONFIRMASI HAPUS ────────────────────────────────────────────────
  void _showDeleteConfirmKelas(BuildContext context, String id, String namaKelas) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Hapus Kelas?', style: TextStyle(color: Colors.white)),
          content: Text(
            'Apakah kamu yakin ingin menghapus kelas "$namaKelas"?',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                AppData().deleteKelas(id);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

}

// ─── HELPER ─────────────────────────────────────────────────────────────────
class _NavItem {
  final String svgPath; // path ke file SVG lokal
  final String label;
  const _NavItem({
    required this.svgPath,
    required this.label,
  });
}