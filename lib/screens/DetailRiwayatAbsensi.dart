import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_data.dart';

class DetailRiwayatAbsensi extends StatelessWidget {
  final AbsensiRecord record;

  const DetailRiwayatAbsensi({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final kelas = AppData().kelasList.firstWhere((k) => k.id == record.kelasId);
    final sekolah = AppData().sekolahList.firstWhere((s) => s.id == kelas.sekolahId);
    final siswaList = AppData().getSiswaByKelas(kelas.id);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Detail Absensi', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(record.tanggal),
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  sekolah.nama,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                Text(
                  kelas.nama,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Summary ringkas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryBadge('${record.countHadir} Hadir', Colors.green),
                    _buildSummaryBadge('${record.countAlfa} Alfa', Colors.redAccent),
                    _buildSummaryBadge('${record.countIzin} Izin/Sakit', Colors.orangeAccent),
                  ],
                ),
              ],
            ),
          ),

          // ─── DAFTAR SISWA & STATUS ───
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: siswaList.length,
              itemBuilder: (context, index) {
                final siswa = siswaList[index];
                final status = record.statusKehadiran[siswa.id] ?? 'Tidak Diketahui';
                
                Color statusColor;
                if (status == 'Hadir') statusColor = Colors.green;
                else if (status == 'Alfa') statusColor = Colors.redAccent;
                else if (status == 'Izin' || status == 'Sakit') statusColor = Colors.orangeAccent;
                else statusColor = Colors.grey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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

  Widget _buildSummaryBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
