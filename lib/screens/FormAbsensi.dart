import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_data.dart';

class FormAbsensi extends StatefulWidget {
  final String kelasId;
  final DateTime tanggal;

  const FormAbsensi({super.key, required this.kelasId, required this.tanggal});

  @override
  State<FormAbsensi> createState() => _FormAbsensiState();
}

class _FormAbsensiState extends State<FormAbsensi> {
  late Kelas _kelas;
  late Sekolah _sekolah;
  late List<Siswa> _siswaList;
  
  // State untuk menyimpan pilihan absen tiap siswa
  // Key: siswaId, Value: 'Hadir', 'Alfa', 'Izin', 'Sakit'
  final Map<String, String> _absensiState = {};

  @override
  void initState() {
    super.initState();
    _kelas = AppData().kelasList.firstWhere((k) => k.id == widget.kelasId);
    _sekolah = AppData().sekolahList.firstWhere((s) => s.id == _kelas.sekolahId);
    _siswaList = AppData().getSiswaByKelas(widget.kelasId);
    
    // Set default ke Hadir untuk semua siswa
    for (var siswa in _siswaList) {
      _absensiState[siswa.id] = 'Hadir';
    }
  }

  void _simpanAbsensi() {
    AppData().saveAbsensi(widget.kelasId, widget.tanggal, _absensiState);
    Navigator.pop(context); // Kembali ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Form Absensi', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _simpanAbsensi,
            child: const Text(
              'SIMPAN',
              style: TextStyle(color: Color(0xFF554DE7), fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── INFO HEADER ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1A1A2E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(widget.tanggal),
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _sekolah.nama,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                Text(
                  _kelas.nama,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // ─── DAFTAR SISWA ───
          Expanded(
            child: _siswaList.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada siswa di kelas ini.\nTambahkan siswa terlebih dahulu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _siswaList.length,
                    itemBuilder: (context, index) {
                      final siswa = _siswaList[index];
                      final status = _absensiState[siswa.id]!;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              siswa.nama,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'NIS: ${siswa.nis}',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            // Segmented Button Custom
                            Row(
                              children: [
                                _buildStatusButton(siswa.id, 'Hadir', Colors.green),
                                const SizedBox(width: 8),
                                _buildStatusButton(siswa.id, 'Alfa', Colors.redAccent),
                                const SizedBox(width: 8),
                                _buildStatusButton(siswa.id, 'Izin', Colors.orangeAccent),
                                const SizedBox(width: 8),
                                _buildStatusButton(siswa.id, 'Sakit', Colors.blueAccent),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String siswaId, String status, Color color) {
    final isSelected = _absensiState[siswaId] == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _absensiState[siswaId] = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            status,
            style: TextStyle(
              color: isSelected ? color : Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
