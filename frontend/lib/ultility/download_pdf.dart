// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

// Import khusus fungsi download untuk web saja
import 'download_pdf_web.dart';  // Pastikan file ini ada dan berisi fungsi downloadPdfWeb

Future<void> generateAndDownloadPDF({
  required BuildContext context,
  required String judul,
  required String isi,
  required DateTime tanggalMulai,
  required DateTime tanggalBerakhir,
  required String hash_uu,
}) async {
  final pdf = pw.Document();

  // Buat QR code jadi image
  final qrValidationResult = QrValidator.validate(
    data: hash_uu,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
  );

  if (qrValidationResult.status != QrValidationStatus.valid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal membuat QR code')),
    );
    return;
  }

  final qrCode = qrValidationResult.qrCode!;
  final painter = QrPainter.withQr(
    qr: qrCode,
    dataModuleStyle: const QrDataModuleStyle(
      color: Color(0xFF000000),
      dataModuleShape: QrDataModuleShape.square,
    ),
    gapless: true,
  );

  final image = await painter.toImage(200);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final qrBytes = byteData!.buffer.asUint8List();

  final qrImage = pw.MemoryImage(qrBytes);

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        // Format tanggal agar sama persis dengan yang tampil di home_page_admin.dart
        String formatDate(DateTime dt) {
          // yyyy-MM-ddTHH:mm:ss (ISO tanpa zona)
          return "${dt.year.toString().padLeft(4, '0')}-"
                 "${dt.month.toString().padLeft(2, '0')}-"
                 "${dt.day.toString().padLeft(2, '0')}T"
                 "${dt.hour.toString().padLeft(2, '0')}:"
                 "${dt.minute.toString().padLeft(2, '0')}:"
                 "${dt.second.toString().padLeft(2, '0')}";
        }

        debugPrint('=============== GENERATE PDF ===============');
        debugPrint('Judul: $judul');
        debugPrint('Isi: $isi');
        debugPrint('Tanggal Mulai: ${tanggalMulai}');
        debugPrint('Tanggal Berakhir: ${tanggalBerakhir}');
        debugPrint('HashUU: $hash_uu');

        // Pastikan tanggalMulai dan tanggalBerakhir benar-benar DateTime (bukan int/milis)
        // ignore: unnecessary_type_check
        final DateTime mulai = tanggalMulai is DateTime
            ? tanggalMulai
            : DateTime.fromMillisecondsSinceEpoch(tanggalMulai as int);
        // ignore: unnecessary_type_check
        final DateTime akhir = tanggalBerakhir is DateTime
            ? tanggalBerakhir
            : DateTime.fromMillisecondsSinceEpoch(tanggalBerakhir as int);

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Judul UU:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(judul),
            pw.SizedBox(height: 10),
            pw.Text('Isi UU:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(isi),
            pw.SizedBox(height: 10),
            pw.Text('Tanggal Berlaku: ${formatDate(mulai)}'),
            pw.Text('Tanggal Berakhir: ${formatDate(akhir)}'),
            pw.SizedBox(height: 10),
            pw.Text('HashUU:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(hash_uu),
            pw.SizedBox(height: 20),
            pw.Text('QR Code HashUU:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Center(child: pw.Image(qrImage, width: 150, height: 150)),
          ],
        );
      },
    ),
  );

  final pdfBytes = await pdf.save();

  // Hanya jalankan untuk Web
  if (kIsWeb) {
    downloadPdfWeb(pdfBytes, 'UU_$hash_uu.pdf');
  } else {
    // Kalau kamu yakin cuma web, bisa hapus bagian ini atau kasih error
    throw UnsupportedError('Platform bukan web');
  }
}
