// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

/// Download file Excel (.xlsx) langsung via browser (Web platform)
Future<void> downloadBytes(List<int> bytes, String fileName) async {
  final uint8 = Uint8List.fromList(bytes);
  final blob = html.Blob(
    [uint8],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  // Tunda revoke agar download sempat dimulai
  Future.delayed(const Duration(seconds: 2), () {
    html.Url.revokeObjectUrl(url);
  });
}
