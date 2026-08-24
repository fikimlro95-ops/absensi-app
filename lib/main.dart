import 'package:flutter/material.dart';
import 'screens/HomeSekolah.dart';
import 'screens/HomeKelas.dart';
import 'screens/Absensi.dart';

void main() {
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
        }
        return MaterialPageRoute(builder: (_) => const HomeSekolah());
      },
    );
  }
}