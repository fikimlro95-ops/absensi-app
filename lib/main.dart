import 'package:flutter/material.dart';
import 'screens/HomeSekolah.dart';
import 'screens/HomeKelas.dart';
import 'screens/Absensi.dart';
import 'screens/DetailKelas.dart';
import 'screens/FormAbsensi.dart';
import 'screens/DetailRiwayatAbsensi.dart';
import 'screens/Nilai.dart';
import 'screens/FormNilai.dart';
import 'screens/Profil.dart';
import 'data/app_data.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await AppData().loadData(); // Memuat data dari local storage
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF111111),
        canvasColor: const Color(0xFF111111),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5AFE),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/HomeSekolah', // ← hanya satu initialRoute
      onGenerateRoute: (settings) {
        if (settings.name == '/HomeKelas') {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeKelas(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        } else if (settings.name == '/Absensi') {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Absensi(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        } else if (settings.name == '/HomeSekolah') {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeSekolah(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        } else if (settings.name == '/DetailKelas') {
          final kelasId = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => DetailKelas(kelasId: kelasId));
        } else if (settings.name == '/FormAbsensi') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => FormAbsensi(
              kelasId: args['kelasId'],
              tanggal: args['tanggal'],
            ),
          );
        } else if (settings.name == '/DetailRiwayatAbsensi') {
          final record = settings.arguments as AbsensiRecord;
          return MaterialPageRoute(
            builder: (_) => DetailRiwayatAbsensi(record: record),
          );
        } else if (settings.name == '/Nilai') {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Nilai(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        } else if (settings.name == '/FormNilai') {
          final tugas = settings.arguments as TugasRecord;
          return MaterialPageRoute(
            builder: (_) => FormNilai(tugas: tugas),
          );
        } else if (settings.name == '/Profil') {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Profil(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        }
        return MaterialPageRoute(builder: (_) => const HomeSekolah());
      },
    );
  }
}