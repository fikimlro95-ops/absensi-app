import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Simpan file Excel (.xlsx) ke temp dir lalu share (Android / iOS / Desktop)
Future<void> downloadBytes(List<int> bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles(
    [
      XFile(
        file.path,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      )
    ],
    subject: fileName,
  );
}
