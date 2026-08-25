import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'kelasId': kelasId,
        'nama': nama,
        'nis': nis,
      };

  factory Siswa.fromJson(Map<String, dynamic> json) => Siswa(
        id: json['id'],
        kelasId: json['kelasId'],
        nama: json['nama'],
        nis: json['nis'],
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'kelasId': kelasId,
        'tanggal': tanggal.toIso8601String(),
        'statusKehadiran': statusKehadiran,
      };

  factory AbsensiRecord.fromJson(Map<String, dynamic> json) => AbsensiRecord(
        id: json['id'],
        kelasId: json['kelasId'],
        tanggal: DateTime.parse(json['tanggal']),
        statusKehadiran: Map<String, String>.from(json['statusKehadiran']),
      );
}

// Model untuk Tugas dan Nilai
class TugasRecord {
  final String id;
  final String kelasId;
  final DateTime tanggal;
  final String namaTugas;
  final String deskripsi;
  // Key: id siswa, Value: nilai (String, bebas diisi angka/huruf)
  final Map<String, String> nilaiSiswa;

  TugasRecord({
    required this.id,
    required this.kelasId,
    required this.tanggal,
    required this.namaTugas,
    this.deskripsi = '',
    Map<String, String>? nilaiSiswa,
  }) : nilaiSiswa = nilaiSiswa ?? {};

  TugasRecord copyWith({Map<String, String>? nilaiSiswa}) {
    return TugasRecord(
      id: id,
      kelasId: kelasId,
      tanggal: tanggal,
      namaTugas: namaTugas,
      deskripsi: deskripsi,
      nilaiSiswa: nilaiSiswa ?? this.nilaiSiswa,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kelasId': kelasId,
        'tanggal': tanggal.toIso8601String(),
        'namaTugas': namaTugas,
        'deskripsi': deskripsi,
        'nilaiSiswa': nilaiSiswa,
      };

  factory TugasRecord.fromJson(Map<String, dynamic> json) => TugasRecord(
        id: json['id'],
        kelasId: json['kelasId'],
        tanggal: DateTime.parse(json['tanggal']),
        namaTugas: json['namaTugas'],
        deskripsi: json['deskripsi'] ?? '',
        nilaiSiswa: json['nilaiSiswa'] != null
            ? Map<String, String>.from(json['nilaiSiswa'])
            : {},
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'imageUrl': imageUrl,
      };

  factory Sekolah.fromJson(Map<String, dynamic> json) => Sekolah(
        id: json['id'],
        nama: json['nama'],
        imageUrl: json['imageUrl'],
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'sekolahId': sekolahId,
        'nama': nama,
        'deskripsi': deskripsi,
        'jumlahSiswa': jumlahSiswa,
      };

  factory Kelas.fromJson(Map<String, dynamic> json) => Kelas(
        id: json['id'],
        sekolahId: json['sekolahId'],
        nama: json['nama'],
        deskripsi: json['deskripsi'],
        jumlahSiswa: json['jumlahSiswa'] ?? 0,
      );
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
  final List<TugasRecord> _tugasList = [];

  // Getter
  List<Sekolah> get sekolahList => _sekolahList;
  List<Kelas> get kelasList => _kelasList;
  List<Siswa> get siswaList => _siswaList;
  List<AbsensiRecord> get absensiList => _absensiList;
  List<TugasRecord> get tugasList => _tugasList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // ─── LOCAL STORAGE LOGIC ───
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final sekolahStr = prefs.getString('sekolahList');
    if (sekolahStr != null) {
      final List decoded = json.decode(sekolahStr);
      _sekolahList.clear();
      _sekolahList.addAll(decoded.map((e) => Sekolah.fromJson(e)).toList());
    }

    final kelasStr = prefs.getString('kelasList');
    if (kelasStr != null) {
      final List decoded = json.decode(kelasStr);
      _kelasList.clear();
      _kelasList.addAll(decoded.map((e) => Kelas.fromJson(e)).toList());
    }

    final siswaStr = prefs.getString('siswaList');
    if (siswaStr != null) {
      final List decoded = json.decode(siswaStr);
      _siswaList.clear();
      _siswaList.addAll(decoded.map((e) => Siswa.fromJson(e)).toList());
    }

    final absensiStr = prefs.getString('absensiList');
    if (absensiStr != null) {
      final List decoded = json.decode(absensiStr);
      _absensiList.clear();
      _absensiList.addAll(decoded.map((e) => AbsensiRecord.fromJson(e)).toList());
    }

    final tugasStr = prefs.getString('tugasList');
    if (tugasStr != null) {
      final List decoded = json.decode(tugasStr);
      _tugasList.clear();
      _tugasList.addAll(decoded.map((e) => TugasRecord.fromJson(e)).toList());
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sekolahList', json.encode(_sekolahList.map((e) => e.toJson()).toList()));
    await prefs.setString('kelasList', json.encode(_kelasList.map((e) => e.toJson()).toList()));
    await prefs.setString('siswaList', json.encode(_siswaList.map((e) => e.toJson()).toList()));
    await prefs.setString('absensiList', json.encode(_absensiList.map((e) => e.toJson()).toList()));
    await prefs.setString('tugasList', json.encode(_tugasList.map((e) => e.toJson()).toList()));
  }

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
    saveData();
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
    saveData();
    notifyListeners();
  }

  // Aksi Menghapus Sekolah
  void deleteSekolah(String id) {
    // Hapus sekolah
    _sekolahList.removeWhere((s) => s.id == id);
    // Hapus juga semua kelas yang terkait dengan sekolah ini
    _kelasList.removeWhere((k) => k.sekolahId == id);
    saveData();
    notifyListeners();
  }

  // Aksi Menghapus Kelas
  void deleteKelas(String id) {
    _kelasList.removeWhere((k) => k.id == id);
    _siswaList.removeWhere((s) => s.kelasId == id); // hapus siswa di kelas ini
    _absensiList.removeWhere((a) => a.kelasId == id); // hapus absensi di kelas ini
    saveData();
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
    saveData();
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
    saveData();
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
    saveData();
    notifyListeners();
  }

  // Aksi Menambah Tugas
  void addTugas(String kelasId, DateTime tanggal, String namaTugas, String deskripsi) {
    final record = TugasRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      kelasId: kelasId,
      tanggal: tanggal,
      namaTugas: namaTugas,
      deskripsi: deskripsi,
    );
    _tugasList.add(record);
    saveData();
    notifyListeners();
  }

  // Aksi Menyimpan Nilai Siswa pada suatu Tugas
  void saveNilaiSiswa(String tugasId, Map<String, String> nilaiSiswa) {
    final index = _tugasList.indexWhere((t) => t.id == tugasId);
    if (index != -1) {
      _tugasList[index] = _tugasList[index].copyWith(nilaiSiswa: nilaiSiswa);
      saveData();
      notifyListeners();
    }
  }

  // Aksi Menghapus Tugas
  void deleteTugas(String id) {
    _tugasList.removeWhere((t) => t.id == id);
    saveData();
    notifyListeners();
  }

  // Mendapatkan daftar tugas per kelas
  List<TugasRecord> getTugasByKelas(String kelasId) {
    return _tugasList.where((t) => t.kelasId == kelasId).toList()
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
  }

  // Mendapatkan semua tugas, diurutkan dari yang terbaru
  List<TugasRecord> getSortedTugas() {
    final sorted = List<TugasRecord>.from(_tugasList);
    sorted.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return sorted;
  }
}
