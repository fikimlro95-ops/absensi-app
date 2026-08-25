import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_data.dart';

class FormNilai extends StatefulWidget {
  final TugasRecord tugas;

  const FormNilai({super.key, required this.tugas});

  @override
  State<FormNilai> createState() => _FormNilaiState();
}

class _FormNilaiState extends State<FormNilai> {
  // Map: siswa.id -> TextEditingController
  final Map<String, TextEditingController> _controllers = {};
  List<Siswa> _siswaList = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _siswaList = AppData().getSiswaByKelas(widget.tugas.kelasId);
    // Pre-fill nilai yang sudah tersimpan
    for (final s in _siswaList) {
      _controllers[s.id] = TextEditingController(
        text: widget.tugas.nilaiSiswa[s.id] ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _simpanNilai() async {
    setState(() => _isSaving = true);
    final Map<String, String> nilaiMap = {};
    for (final s in _siswaList) {
      nilaiMap[s.id] = _controllers[s.id]?.text.trim() ?? '';
    }
    AppData().saveNilaiSiswa(widget.tugas.id, nilaiMap);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nilai berhasil disimpan!'),
          backgroundColor: Color(0xFF1C3393),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final namaKelas = AppData().getNamaKelas(widget.tugas.kelasId);
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/base.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tombol Kembali
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.tugas.namaTugas,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.class_outlined,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            namaKelas,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.calendar_today_outlined,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMM yyyy', 'id_ID')
                                .format(widget.tugas.tanggal),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      if (widget.tugas.deskripsi.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.tugas.deskripsi,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── BODY: DAFTAR SISWA ───────────────────────────────────────
            Expanded(
              child: _siswaList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64,
                              color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada siswa di kelas ini.',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: _siswaList.length,
                      itemBuilder: (context, index) {
                        final siswa = _siswaList[index];
                        return _buildSiswaRow(siswa, index + 1);
                      },
                    ),
            ),
          ],
        ),
      ),

      // ── TOMBOL SIMPAN ───────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border(
            top: BorderSide(
                color: Colors.white.withOpacity(0.08), width: 1),
          ),
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _simpanNilai,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined, color: Colors.white),
            label: Text(
              _isSaving ? 'Menyimpan...' : 'Simpan Nilai',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C3393),
              disabledBackgroundColor: const Color(0xFF1C3393).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiswaRow(Siswa siswa, int nomor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3D5AFE).withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Nomor Urut
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF08102D), Color(0xFF1C3393)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$nomor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nama & NIS Siswa
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswa.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'NIS: ${siswa.nis}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Input Nilai
          SizedBox(
            width: 90,
            child: TextField(
              controller: _controllers[siswa.id],
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '—',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 15,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color(0xFF554DE7).withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFF554DE7), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
