import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../data/app_data.dart';

import 'download_stub.dart'
    if (dart.library.html) 'download_web.dart'
    if (dart.library.io) 'download_io.dart';

/// Enum rentang waktu export
enum ExportPeriod { minggu1, bulan1, bulan6 }

extension ExportPeriodExt on ExportPeriod {
  String get label {
    switch (this) {
      case ExportPeriod.minggu1:
        return '1 Minggu';
      case ExportPeriod.bulan1:
        return '1 Bulan';
      case ExportPeriod.bulan6:
        return '6 Bulan';
    }
  }

  DateTime get cutoffDate {
    final now = DateTime.now();
    switch (this) {
      case ExportPeriod.minggu1:
        return now.subtract(const Duration(days: 7));
      case ExportPeriod.bulan1:
        return now.subtract(const Duration(days: 30));
      case ExportPeriod.bulan6:
        return now.subtract(const Duration(days: 180));
    }
  }
}

// ── Warna helper ─────────────────────────────────────────────────────────────
ExcelColor get _pinkHeader => ExcelColor.fromHexString('FFB8B8');
ExcelColor get _pinkAlt => ExcelColor.fromHexString('FFD6D6');
ExcelColor get _white => ExcelColor.fromHexString('FFFFFF');
ExcelColor get _darkText => ExcelColor.fromHexString('000000');

// ── Style helper ─────────────────────────────────────────────────────────────
CellStyle _headerStyle({bool bold = true, ExcelColor? bg}) => CellStyle(
      bold: bold,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: bg ?? _pinkHeader,
      fontColorHex: _darkText,
      textWrapping: TextWrapping.WrapText,
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );

CellStyle _dataStyle({ExcelColor? bg}) => CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: bg ?? _white,
      fontColorHex: _darkText,
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );

CellStyle _nameStyle({ExcelColor? bg}) => CellStyle(
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: bg ?? _white,
      fontColorHex: _darkText,
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );

// ── Setter sel ───────────────────────────────────────────────────────────────
void _setCell(Sheet sheet, int row, int col, dynamic value, CellStyle style) {
  final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
  if (value is int) {
    cell.value = IntCellValue(value);
  } else if (value is double) {
    cell.value = DoubleCellValue(value);
  } else {
    cell.value = TextCellValue(value?.toString() ?? '');
  }
  cell.cellStyle = style;
}

class ExportHelper {
  // ──────────────────────────────────────────────────────────────────────────
  // EXPORT ABSENSI
  // Format: REKAP ABSENSI SISWA sesuai template
  // Kolom: No | Nama Siswa | [Bulan1: S, I, A] | [Bulan2: S, I, A] | ...
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> exportAbsensi({
    required String kelasId,
    required ExportPeriod period,
  }) async {
    final namaKelas = AppData().getNamaKelas(kelasId);
    final cutoff = period.cutoffDate;

    final records = AppData()
        .absensiList
        .where((r) => r.kelasId == kelasId && r.tanggal.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    if (records.isEmpty) {
      throw Exception(
          'Tidak ada data absensi untuk periode ${period.label}.\nPastikan absensi sudah dibuat dalam rentang ini.');
    }

    final siswas = AppData().getSiswaByKelas(kelasId);

    // Kumpulkan bulan-bulan unik yang ada di records (berurutan)
    final monthKeys = <String>{}; // "yyyy-MM"
    for (final r in records) {
      monthKeys.add(DateFormat('yyyy-MM').format(r.tanggal));
    }
    final sortedMonths = monthKeys.toList()..sort();

    // Untuk setiap siswa, hitung S/I/A per bulan
    // monthSIA[siswaId][monthKey] = {'S': x, 'I': x, 'A': x}
    final Map<String, Map<String, Map<String, int>>> monthSIA = {};
    for (final s in siswas) {
      monthSIA[s.id] = {};
      for (final mk in sortedMonths) {
        monthSIA[s.id]![mk] = {'S': 0, 'I': 0, 'A': 0};
      }
    }
    for (final r in records) {
      final mk = DateFormat('yyyy-MM').format(r.tanggal);
      for (final s in siswas) {
        final status = r.statusKehadiran[s.id];
        if (status == 'Sakit') {
          monthSIA[s.id]![mk]!['S'] = (monthSIA[s.id]![mk]!['S'] ?? 0) + 1;
        } else if (status == 'Izin') {
          monthSIA[s.id]![mk]!['I'] = (monthSIA[s.id]![mk]!['I'] ?? 0) + 1;
        } else if (status == 'Alfa') {
          monthSIA[s.id]![mk]!['A'] = (monthSIA[s.id]![mk]!['A'] ?? 0) + 1;
        }
      }
    }

    final excel = Excel.createExcel();
    final sheetName = 'Rekap Absensi';
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);
    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');

    // ── Baris 0: Judul ──
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 1 + sortedMonths.length * 3, rowIndex: 0),
    );
    _setCell(sheet, 0, 0, 'REKAP ABSENSI SISWA - $namaKelas (${period.label})',
        CellStyle(
          bold: true,
          fontSize: 14,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          fontColorHex: _darkText,
        ));
    sheet.setRowHeight(0, 28);

    // ── Baris 1: Header utama (No | Nama Siswa | Bulan1 | Bulan2 | ...) ──
    // No
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
    );
    _setCell(sheet, 1, 0, 'No', _headerStyle());

    // Nama Siswa
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2),
    );
    _setCell(sheet, 1, 1, 'Nama Siswa', _headerStyle());

    // Kolom bulan
    for (int mi = 0; mi < sortedMonths.length; mi++) {
      final colStart = 2 + mi * 3;
      final monthLabel = DateFormat('MMMM', 'id_ID')
          .format(DateTime.parse('${sortedMonths[mi]}-01'));

      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: colStart, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: colStart + 2, rowIndex: 1),
      );
      _setCell(sheet, 1, colStart, monthLabel, _headerStyle());

      // Sub-header S, I, A
      _setCell(sheet, 2, colStart, 'S', _headerStyle(bg: _pinkAlt));
      _setCell(sheet, 2, colStart + 1, 'I', _headerStyle(bg: _pinkAlt));
      _setCell(sheet, 2, colStart + 2, 'A', _headerStyle(bg: _pinkAlt));
    }
    sheet.setRowHeight(1, 22);
    sheet.setRowHeight(2, 22);

    // ── Baris 3+: Data siswa ──
    for (int si = 0; si < siswas.length; si++) {
      final siswa = siswas[si];
      final rowIdx = 3 + si;
      final bg = si % 2 == 0 ? _white : ExcelColor.fromHexString('FFF5F5');

      _setCell(sheet, rowIdx, 0, si + 1, _dataStyle(bg: bg));
      _setCell(sheet, rowIdx, 1, siswa.nama, _nameStyle(bg: bg));

      for (int mi = 0; mi < sortedMonths.length; mi++) {
        final mk = sortedMonths[mi];
        final sia = monthSIA[siswa.id]![mk]!;
        final colStart = 2 + mi * 3;
        _setCell(sheet, rowIdx, colStart, sia['S']!, _dataStyle(bg: bg));
        _setCell(sheet, rowIdx, colStart + 1, sia['I']!, _dataStyle(bg: bg));
        _setCell(sheet, rowIdx, colStart + 2, sia['A']!, _dataStyle(bg: bg));
      }
      sheet.setRowHeight(rowIdx, 20);
    }

    // ── Lebar kolom ──
    sheet.setColumnWidth(0, 6);   // No
    sheet.setColumnWidth(1, 28);  // Nama Siswa
    for (int mi = 0; mi < sortedMonths.length; mi++) {
      sheet.setColumnWidth(2 + mi * 3, 6);
      sheet.setColumnWidth(2 + mi * 3 + 1, 6);
      sheet.setColumnWidth(2 + mi * 3 + 2, 6);
    }

    final bytes = excel.encode()!;
    final fileName =
        'RekapAbsensi_${namaKelas.replaceAll(' ', '_')}_${period.label.replaceAll(' ', '')}.xlsx';
    await downloadBytes(bytes, fileName);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // EXPORT NILAI
  // Format: REKAP NILAI SISWA
  // Kolom: No | Nama Siswa | NIS | Tugas1 (tgl) | Tugas2 (tgl) | ... | Rata-rata
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> exportNilai({
    required String kelasId,
    required ExportPeriod period,
  }) async {
    final namaKelas = AppData().getNamaKelas(kelasId);
    final cutoff = period.cutoffDate;

    final tugasList = AppData()
        .tugasList
        .where((t) => t.kelasId == kelasId && t.tanggal.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    if (tugasList.isEmpty) {
      throw Exception(
          'Tidak ada data nilai untuk periode ${period.label}.\nPastikan tugas sudah dibuat dalam rentang ini.');
    }

    final siswas = AppData().getSiswaByKelas(kelasId);

    final excel = Excel.createExcel();
    final sheetName = 'Rekap Nilai';
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);
    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');

    final totalCols = 3 + tugasList.length + 1; // No+Nama+NIS+tugas...+Rata2

    // ── Baris 0: Judul ──
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: totalCols - 1, rowIndex: 0),
    );
    _setCell(sheet, 0, 0, 'REKAP NILAI SISWA - $namaKelas (${period.label})',
        CellStyle(
          bold: true,
          fontSize: 14,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          fontColorHex: _darkText,
        ));
    sheet.setRowHeight(0, 28);

    // ── Baris 1: Header ──
    _setCell(sheet, 1, 0, 'No', _headerStyle());
    _setCell(sheet, 1, 1, 'Nama Siswa', _headerStyle());
    _setCell(sheet, 1, 2, 'NIS', _headerStyle());

    for (int ti = 0; ti < tugasList.length; ti++) {
      final t = tugasList[ti];
      final label =
          '${t.namaTugas}\n(${DateFormat('dd/MM/yy').format(t.tanggal)})';
      _setCell(sheet, 1, 3 + ti, label, _headerStyle());
    }
    _setCell(sheet, 1, 3 + tugasList.length, 'Rata-rata', _headerStyle());
    sheet.setRowHeight(1, 36);

    // ── Baris 2+: Data siswa ──
    for (int si = 0; si < siswas.length; si++) {
      final siswa = siswas[si];
      final rowIdx = 2 + si;
      final bg = si % 2 == 0 ? _white : ExcelColor.fromHexString('FFF5F5');

      _setCell(sheet, rowIdx, 0, si + 1, _dataStyle(bg: bg));
      _setCell(sheet, rowIdx, 1, siswa.nama, _nameStyle(bg: bg));
      _setCell(sheet, rowIdx, 2, siswa.nis, _dataStyle(bg: bg));

      double total = 0;
      int count = 0;
      for (int ti = 0; ti < tugasList.length; ti++) {
        final nilaiStr = tugasList[ti].nilaiSiswa[siswa.id] ?? '';
        final nilaiNum = double.tryParse(nilaiStr);
        if (nilaiNum != null) {
          _setCell(sheet, rowIdx, 3 + ti, nilaiNum, _dataStyle(bg: bg));
          total += nilaiNum;
          count++;
        } else {
          _setCell(sheet, rowIdx, 3 + ti, nilaiStr.isEmpty ? '-' : nilaiStr,
              _dataStyle(bg: bg));
        }
      }
      final rataStr = count > 0 ? (total / count).toStringAsFixed(1) : '-';
      _setCell(sheet, rowIdx, 3 + tugasList.length, rataStr,
          _dataStyle(bg: bg));
      sheet.setRowHeight(rowIdx, 20);
    }

    // ── Lebar kolom ──
    sheet.setColumnWidth(0, 6);
    sheet.setColumnWidth(1, 28);
    sheet.setColumnWidth(2, 14);
    for (int ti = 0; ti < tugasList.length; ti++) {
      sheet.setColumnWidth(3 + ti, 16);
    }
    sheet.setColumnWidth(3 + tugasList.length, 12);

    final bytes = excel.encode()!;
    final fileName =
        'RekapNilai_${namaKelas.replaceAll(' ', '_')}_${period.label.replaceAll(' ', '')}.xlsx';
    await downloadBytes(bytes, fileName);
  }
}
