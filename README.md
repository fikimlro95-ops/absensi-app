# Aplikasi Absensi & Penilaian Siswa

Aplikasi manajemen kelas berbasis Flutter yang memudahkan pengajar untuk mengelola absensi harian, nilai tugas, hingga rekapitulasi data siswa dengan fitur ekspor otomatis ke Excel. Aplikasi dirancang sepenuhnya berjalan secara offline sehingga cepat dan tidak membutuhkan koneksi internet.

##  Fitur Utama

### 1. Manajemen Institusi & Siswa
* **Data Sekolah**: Tambah, edit, dan hapus data sekolah.
* **Data Kelas**: Kelola daftar kelas untuk setiap sekolah.
* **Data Siswa**: Tambahkan siswa ke dalam setiap kelas secara spesifik (Nama dan NIS).

### 2. Absensi Harian
* **Input Kehadiran**: Catat kehadiran siswa setiap harinya dengan status: *Hadir*, *Sakit*, *Izin*, atau *Alfa*.
* **Default Status Pintar**: Tentukan status bawaan (misal otomatis Hadir atau otomatis Alfa) via menu Profil untuk mempercepat proses absensi.
* **Riwayat Absensi**: Lihat detail absensi yang telah berlalu, lengkap dengan tanggal dan ringkasan kehadiran.

### 3. Penilaian (Grades)
* **Manajemen Tugas**: Buat daftar tugas / ujian baru berdasarkan tanggal.
* **Input Nilai**: Masukkan nilai angka untuk setiap siswa. Nilai akan otomatis dikonversi secara visual menjadi Nilai Huruf berdasarkan statistik default (A: >90, B: 81-90, C: 60-80, D: <60).

### 4. Ekspor ke Excel (.xlsx)
Cetak laporan rekapitulasi kapan saja secara langsung dari dalam aplikasi:
* **Ekspor Absensi**: Menghasilkan file Excel rekap kehadiran siswa bulanan dengan rincian (S, I, A).
* **Ekspor Nilai**: Menghasilkan file Excel rekap nilai semua tugas beserta rata-rata per siswa.
* **Filter Waktu**: Pilih rentang data yang akan diekspor (1 Minggu, 1 Bulan, atau 6 Bulan Terakhir).
* **Cross-Platform**: Proses ekspor terintegrasi lancar, baik berjalan di Android/iOS (memunculkan *Share Sheet*) maupun di Web Browser (mengunduh otomatis file `.xlsx`).

### 5. UI/UX Modern & Gelap (Dark Mode)
Desain antarmuka aplikasi berfokus pada pengalaman pengguna yang elegan dan nyaman di mata (Tema Gelap / Dark Mode default), dilengkapi visual interaktif dan navigasi yang intuitif.

---

##  Cara Penggunaan

### Memulai Aplikasi
1. Saat pertama kali membuka aplikasi, masuk ke menu **Beranda**.
2. Klik tombol **Tambah Sekolah** dan masukkan nama sekolah.
3. Klik sekolah yang baru dibuat, lalu klik **Tambah Kelas** di dalam sekolah tersebut.

### Memasukkan Data Siswa
1. Buka kelas yang telah dibuat.
2. Navigasi ke tab **Daftar Siswa** di halaman Detail Kelas.
3. Klik tombol tambah `(+)` untuk mendaftarkan nama dan NIS siswa.

### Melakukan Absensi
1. Buka menu **Absensi** pada *bottom navigation bar* atau tombol **Tambah Absensi** di halaman Kelas.
2. Klik **Buat Absensi** dan pilih tanggal.
3. Tandai kehadiran masing-masing siswa (Hadir/Alfa/Izin/Sakit).
4. Klik **SIMPAN**.

### Memasukkan Nilai
1. Buka menu **Nilai** pada *bottom navigation bar*.
2. Pilih kelas, lalu klik **Buat Tugas/Ujian Baru**.
3. Masukkan nama tugas (misal: "Ujian Tengah Semester") dan tanggal.
4. Masukkan nilai siswa pada daftar, lalu klik **SIMPAN**.

### Ekspor Data (Laporan)
1. Buka halaman **Kelas** (tab Detail Kelas).
2. Terdapat tombol **Export Absensi** dan **Export Nilai** di bagian atas.
3. Klik salah satu tombol tersebut, lalu pilih rentang waktu (contoh: 1 Bulan).
4. File `.xlsx` akan di-generate dan kamu bisa langsung menyimpannya ke memori HP, Google Drive, atau membagikannya via WhatsApp/Email.

### Mengubah Default Absensi
1. Buka menu **Profil**.
2. Klik pada pilihan **Setelan Awal Absensi**.
3. Pilih apakah semua siswa secara otomatis dianggap **Hadir** atau **Alfa** saat membuka form absensi baru.

---

## 🛠️ Teknologi yang Digunakan
* **Framework:** [Flutter](https://flutter.dev/) / Dart
* **State Management:** `ChangeNotifier` / `ListenableBuilder`
* **Local Storage:** `shared_preferences` (JSON encoding)
* **Ekspor Excel:** `excel`
* **File Sharing:** `share_plus` & `path_provider` (Android/iOS) + `dart:html` (Web)
* **Ikon Kustom:** `flutter_svg`, `flutter_launcher_icons`
