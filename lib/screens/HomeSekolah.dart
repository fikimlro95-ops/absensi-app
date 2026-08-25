import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../data/app_data.dart';

class HomeSekolah extends StatefulWidget {
  const HomeSekolah({super.key});
  @override
  HomeSekolahState createState() => HomeSekolahState();
}

class HomeSekolahState extends State<HomeSekolah> {
  int _selectedIndex = 0;

  // ─── Path gambar header (asset lokal) ─────────────────────────────────
  final String? headerImageUrl = 'assets/base.png';

  // Data dihapus karena kita pakai AppData()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER ────────────────────────────────────────────
            _buildHeader(),

            // ─── CONTENT ───────────────────────────────────────────
            ListenableBuilder(
              listenable: AppData(),
              builder: (context, _) {
                final listSekolah = AppData().sekolahList;
                
                if (listSekolah.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada Sekolah',
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
                      children: listSekolah.map((sekolah) {
                        // Hitung jumlah kelas yang nyambung ke sekolah ini
                        final countKelas = AppData().kelasList.where((k) => k.sekolahId == sekolah.id).length;
                        return _buildSekolahCard(
                          id: sekolah.id,
                          nama: sekolah.nama,
                          kelas: countKelas.toString(),
                          imageUrl: sekolah.imageUrl,
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // ─── FAB ─────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSekolahModal(context);
        },
        backgroundColor: const Color(0xFF1C3393),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // ─── BOTTOM NAV ──────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── HEADER WIDGET ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipRRect(
      // Radius hanya di sudut bawah kiri & kanan
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
            // Overlay gelap supaya teks tetap terbaca
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

            // Isi header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ikon settings di kanan atas
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
                      // "Sekolah" = halaman aktif → ada garis bawah
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Sekolah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 80),
                      // "Kelas" = klik untuk ke HomeKelas (tanpa garis)
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/HomeKelas'),
                        child: Text(
                          'Kelas',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
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

  // ─── CARD SEKOLAH ──────────────────────────────────────────────────────────
  Widget _buildSekolahCard({required String id, required String nama, required String kelas, String? imageUrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(-1, 1),
          colors: [
            Color(0xFF08102D),
            Color(0xFF1C3393),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C3393).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        // Border biru
        border: Border.all(
          color: const Color(0xFF3D5AFE).withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          print('Buka sekolah: $nama');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ─ Logo kiri ─
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3D5AFE).withOpacity(0.3),
                    width: 1,
                  ),
                  image: (imageUrl != null && imageUrl.isNotEmpty)
                      ? DecorationImage(
                          image: FileImage(File(imageUrl)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF666688),
                        size: 36,
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // ─ Info sekolah tengah ─
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        color: Color(0xFFC0BCBC),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kelas : $kelas',
                      style: const TextStyle(
                        color: Color(0xFFC0BCBC),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // ─ Ikon kanan (Hapus) ─
              GestureDetector(
                onTap: () {
                  _showDeleteConfirmSekolah(context, id, nama);
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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
      ),
    );
  }

  // ─── BOTTOM NAV ─────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    // ─── Daftar item navbar dengan SVG lokal ───────────────────────────
    // Ganti nama file SVG di sini sesuai file kamu
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

  // ─── MODAL TAMBAH SEKOLAH ──────────────────────────────────────────────────
  void _showAddSekolahModal(BuildContext context) {
    final TextEditingController namaController = TextEditingController();
    String? selectedImagePath;

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
                    const Text(
                      'Tambah Sekolah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Input Nama
                    TextField(
                      controller: namaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama Sekolah',
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
                    // Input Image lewat Picker
                    InkWell(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setStateModal(() {
                            selectedImagePath = image.path;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          image: selectedImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(selectedImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedImagePath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: Colors.white.withOpacity(0.5), size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pilih Gambar dari Galeri',
                                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (namaController.text.trim().isNotEmpty) {
                            AppData().addSekolah(
                              namaController.text,
                              selectedImagePath,
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
  void _showDeleteConfirmSekolah(BuildContext context, String id, String nama) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Hapus Sekolah?', style: TextStyle(color: Colors.white)),
          content: Text(
            'Apakah kamu yakin ingin menghapus "$nama"? Semua kelas di sekolah ini juga akan terhapus.',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                AppData().deleteSekolah(id);
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
