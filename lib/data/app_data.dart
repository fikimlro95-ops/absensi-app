import 'package:flutter/material.dart';

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

  // Getter
  List<Sekolah> get sekolahList => _sekolahList;
  List<Kelas> get kelasList => _kelasList;

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
    notifyListeners();
  }
}
