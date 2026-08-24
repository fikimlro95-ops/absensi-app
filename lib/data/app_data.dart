import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model untuk Siswa
class Siswa {
  final String id;
  final String kelasId;
  final String nama;
  final String nis;

  Siswa({
    required this.id,
    required this.kelasId,
    required this.nama,
    required this.nis,
  });
}

// Model untuk Riwayat Absensi
class AbsensiRecord {
  final String id;
  final String kelasId;
  final DateTime tanggal;
  // Key: id siswa, Value: status ('Hadir', 'Alfa', 'Izin', 'Sakit')
  final Map<String, String> statusKehadiran;

  AbsensiRecord({
    required this.id,
    required this.kelasId,
    required this.tanggal,
    required this.statusKehadiran,
  });

  int get countHadir => statusKehadiran.values.where((v) => v == 'Hadir').length;
  int get countAlfa => statusKehadiran.values.where((v) => v == 'Alfa').length;
  int get countIzin => statusKehadiran.values.where((v) => v == 'Izin' || v == 'Sakit').length;
}

// Model untuk Sekolah
class Sekolah {
  final String id;
  final String nama;
  final String? imageUrl; // Bisa URL web atau string lokal, jika null pakai gradient

  Sekolah({
    required this.id,
    required this.nama,
    this.imageUrl,
  });
}

// Model untuk Kelas
class Kelas {
  final String id;
  final String sekolahId;
  final String nama;
  final String deskripsi;
  final int jumlahSiswa;

  Kelas({
    required this.id,
    required this.sekolahId,
    required this.nama,
    required this.deskripsi,
    this.jumlahSiswa = 0,
  });
}

// Global State Management
class AppData extends ChangeNotifier {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  // Daftar Data
  final List<Sekolah> _sekolahList = [];
  final List<Kelas> _kelasList = [];
  final List<Siswa> _siswaList = [];
  final List<AbsensiRecord> _absensiList = [];

  // Getter
  List<Sekolah> get sekolahList => _sekolahList;
  List<Kelas> get kelasList => _kelasList;
  List<Siswa> get siswaList => _siswaList;
  List<AbsensiRecord> get absensiList => _absensiList;

  // Mengambil siswa berdasarkan kelas
  List<Siswa> getSiswaByKelas(String kelasId) {
    return _siswaList.where((s) => s.kelasId == kelasId).toList();
  }

  // Mengambil daftar absensi, diurutkan dari yang terbaru
  List<AbsensiRecord> getSortedAbsensi() {
    final sorted = List<AbsensiRecord>.from(_absensiList);
    sorted.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return sorted;
  }

  String getNamaKelas(String kelasId) {
    try {
      return _kelasList.firstWhere((k) => k.id == kelasId).nama;
    } catch (e) {
      return 'Kelas Tidak Diketahui';
    }
  }

  String getSekolahIdByKelas(String kelasId) {
    try {
      return _kelasList.firstWhere((k) => k.id == kelasId).sekolahId;
    } catch (e) {
      return '';
    }
  }

  // Mendapatkan nama sekolah berdasarkan ID (untuk ditampilkan di card kelas)
  String getNamaSekolah(String sekolahId) {
    try {
      return _sekolahList.firstWhere((s) => s.id == sekolahId).nama;
    } catch (e) {
      return 'Sekolah Tidak Diketahui';
    }
  }

  // Aksi Menambah Sekolah
  void addSekolah(String nama, String? imageUrl) {
    final newSekolah = Sekolah(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: nama,
      imageUrl: (imageUrl != null && imageUrl.trim().isNotEmpty) ? imageUrl.trim() : null,
    );
    _sekolahList.add(newSekolah);
    notifyListeners();
  }

  // Aksi Menambah Kelas
  void addKelas(String sekolahId, String nama, String deskripsi) {
    final newKelas = Kelas(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sekolahId: sekolahId,
      nama: nama,
      deskripsi: deskripsi,
      jumlahSiswa: 0, // Default 0
    );
    _kelasList.add(newKelas);
    notifyListeners();
  }

  // Aksi Menghapus Sekolah
  void deleteSekolah(String id) {
    // Hapus sekolah
    _sekolahList.removeWhere((s) => s.id == id);
    // Hapus juga semua kelas yang terkait dengan sekolah ini
    _kelasList.removeWhere((k) => k.sekolahId == id);
    notifyListeners();
  }

  // Aksi Menghapus Kelas
  void deleteKelas(String id) {
    _kelasList.removeWhere((k) => k.id == id);
    _siswaList.removeWhere((s) => s.kelasId == id); // hapus siswa di kelas ini
    _absensiList.removeWhere((a) => a.kelasId == id); // hapus absensi di kelas ini
    notifyListeners();
  }

  // Aksi Menambah Siswa
  void addSiswa(String kelasId, String nama, String nis) {
    final newSiswa = Siswa(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      kelasId: kelasId,
      nama: nama,
      nis: nis,
    );
    _siswaList.add(newSiswa);
    // Update jumlahSiswa di Kelas
    final kelasIndex = _kelasList.indexWhere((k) => k.id == kelasId);
    if (kelasIndex != -1) {
      final k = _kelasList[kelasIndex];
      _kelasList[kelasIndex] = Kelas(
        id: k.id,
        sekolahId: k.sekolahId,
        nama: k.nama,
        deskripsi: k.deskripsi,
        jumlahSiswa: k.jumlahSiswa + 1,
      );
    }
    notifyListeners();
  }

  // Aksi Menghapus Siswa
  void deleteSiswa(String id) {
    final siswa = _siswaList.firstWhere((s) => s.id == id);
    _siswaList.removeWhere((s) => s.id == id);
    
    // Kurangi jumlahSiswa di Kelas
    final kelasIndex = _kelasList.indexWhere((k) => k.id == siswa.kelasId);
    if (kelasIndex != -1) {
      final k = _kelasList[kelasIndex];
      _kelasList[kelasIndex] = Kelas(
        id: k.id,
        sekolahId: k.sekolahId,
        nama: k.nama,
        deskripsi: k.deskripsi,
        jumlahSiswa: k.jumlahSiswa - 1,
      );
    }
    notifyListeners();
  }

  // Aksi Menyimpan Absensi
  void saveAbsensi(String kelasId, DateTime tanggal, Map<String, String> statusKehadiran) {
    final record = AbsensiRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      kelasId: kelasId,
      tanggal: tanggal,
      statusKehadiran: statusKehadiran,
    );
    _absensiList.add(record);
    notifyListeners();
  }
}
