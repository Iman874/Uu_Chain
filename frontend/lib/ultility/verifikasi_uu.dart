// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:web3dart/crypto.dart' as web3crypto;

import '../service/block_chain_service.dart';
import '../config.dart';

// Helper: encode data sesuai Solidity packed format
Uint8List solidityPacked(String judul, String isi, int mulai, int akhir) {
  final bytesBuilder = BytesBuilder();
  bytesBuilder.add(utf8.encode(judul));
  bytesBuilder.add(utf8.encode(isi));
  bytesBuilder.add(_encodeUint256Minimal(BigInt.from(mulai)));
  bytesBuilder.add(_encodeUint256Minimal(BigInt.from(akhir)));
  return bytesBuilder.toBytes();
}

// Helper: encode uint256 ke minimal bytes big endian (tanpa padding 32 bytes)
Uint8List _encodeUint256Minimal(BigInt value) {
  if (value == BigInt.zero) return Uint8List.fromList([0]);
  var bytes = <int>[];
  var n = value;
  while (n > BigInt.zero) {
    bytes.insert(0, (n & BigInt.from(0xff)).toInt());
    n = n >> 8;
  }
  return Uint8List.fromList(bytes);
}

String normalizeText(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

// Fungsi hashUU: sama persis dengan home_page_admin.dart
String hashUU(String judul, String isi, int mulai, int akhir) {
  final bytesBuilder = BytesBuilder();
  bytesBuilder.add(utf8.encode(normalizeText(judul)));
  bytesBuilder.add(utf8.encode(normalizeText(isi)));
  bytesBuilder.add(_encodeUint256Minimal(BigInt.from(mulai)));
  bytesBuilder.add(_encodeUint256Minimal(BigInt.from(akhir)));
  final bytes = bytesBuilder.toBytes();
  final hashBytes = web3crypto.keccak256(Uint8List.fromList(bytes));
  return hashBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

Future<void> verifikasiUU(BuildContext context) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null) {
      _showErrorDialog(context, 'Verifikasi Gagal', 'File tidak dipilih.');
      return;
    }

    Uint8List? pdfBytes;
    if (kIsWeb || result.files.single.path == null) {
      pdfBytes = result.files.single.bytes;
    } else {
      pdfBytes = await File(result.files.single.path!).readAsBytes();
    }

    if (pdfBytes == null) {
      debugPrint('Gagal membaca file PDF.');
      _showErrorDialog(context, 'Verifikasi Gagal', 'File tidak dapat dibaca.');
      return;
    }

    // Ekstrak dan bersihkan teks dari PDF
    String rawText = await extractTextFromPdfBytes(pdfBytes);
    String text = cleanExtractedText(rawText);
    debugPrint('=== TEKS DARI PDF ===\n$text\n====================');

    // Ekstraksi field dengan RegExp
    RegExp hash_uuReg = RegExp(r'HashUU:\s*([a-fA-F0-9]+)');
    RegExp judulReg = RegExp(r'Judul UU:\s*(.*?)Isi UU:', dotAll: true);
    RegExp isiReg = RegExp(r'Isi UU:\s*(.*?)Tanggal Berlaku:', dotAll: true);
    RegExp tglMulaiReg = RegExp(r'Tanggal Berlaku:\s*([0-9\- :T.]+)');
    RegExp tglAkhirReg = RegExp(r'Tanggal Berakhir:\s*([0-9\- :T.]+)');

    String? hash_uu = hash_uuReg.firstMatch(text)?.group(1);
    String? judul = judulReg.firstMatch(text)?.group(1)?.trim();
    String? isi = isiReg.firstMatch(text)?.group(1)?.trim();
    String? tglMulaiStr = tglMulaiReg.firstMatch(text)?.group(1)?.trim();
    String? tglAkhirStr = tglAkhirReg.firstMatch(text)?.group(1)?.trim();

    if ([hash_uu, judul, isi, tglMulaiStr, tglAkhirStr].contains(null)) {
      debugPrint('Data tidak lengkap:');
      _showErrorDialog(
        context,
        'Verifikasi Gagal',
        'Data pada PDF tidak lengkap (HashUU, Judul, Isi, Tanggal Berlaku, Tanggal Berakhir).',
      );
      return;
    }

    // Perbaiki parsing tanggal agar benar-benar sama dengan admin (gunakan detik sejak epoch UTC)
    DateTime? tglMulaiDt;
    DateTime? tglAkhirDt;
    int? tglMulai;
    int? tglAkhir;
    try {
      String fixDate(String? dateStr) {
        if (dateStr == null) return '';
        dateStr = dateStr.replaceAll(RegExp(r'\s+'), ' ').trim();
        dateStr = dateStr.replaceAll(RegExp(r'\s*-\s*'), '-');
        dateStr = dateStr.replaceFirst(' ', 'T');
        final match = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}').firstMatch(dateStr);
        return match?.group(0) ?? '';
      }

      String tglMulaiFixed = fixDate(tglMulaiStr);
      String tglAkhirFixed = fixDate(tglAkhirStr);

      debugPrint('Tanggal Mulai: $tglMulaiFixed');
      debugPrint('Tanggal Akhir: $tglAkhirFixed');

      // Penting: parse sebagai UTC agar hasil detik epoch sama dengan admin
      tglMulaiDt = DateTime.parse(tglMulaiFixed).toUtc();
      tglAkhirDt = DateTime.parse(tglAkhirFixed).toUtc();

      debugPrint('Parsed Tanggal Mulai: $tglMulaiDt');
      debugPrint('Parsed Tanggal Akhir: $tglAkhirDt');

    } catch (_) {
      tglMulaiDt = null;
      tglAkhirDt = null;
    }
    if (tglMulaiDt == null || tglAkhirDt == null) {
      _showErrorDialog(
        context,
        'Verifikasi Gagal',
        'Format tanggal tidak valid. Pastikan tanggal pada PDF sesuai format ISO (contoh: 2024-01-21T12:39:25) atau gunakan format "yyyy-MM-dd HH:mm:ss".',
      );
      return;
    }
    tglMulai = tglMulaiDt.millisecondsSinceEpoch ~/ 1000;
    tglAkhir = tglAkhirDt.millisecondsSinceEpoch ~/ 1000;

    // Hash-kan data sesuai smart contract & home_page_admin.dart
    final txHashLocal = hashUU(judul!, isi!, tglMulai, tglAkhir);
    debugPrint('=============== VERIFIKASI UU ===============');
    debugPrint('Judul: $judul');
    debugPrint('Isi: $isi');
    debugPrint('Tanggal Mulai: $tglMulaiDt');
    debugPrint('Tanggal Akhir: $tglAkhirDt');
    debugPrint('Tanggal Mulai: $tglMulai');
    debugPrint('Tanggal Akhir: $tglAkhir');
    debugPrint('HashUU: $hash_uu');
    debugPrint('Hash Lokal: $txHashLocal');
    debugPrint('==============================================');

    // Cek ke blockchain
    final blockchainService = await BlockchainService.create(
      rpcUrl: rpcUrl,
      abi: abi,
      contractAddress: contractAddress,
    );

    final uuList = await blockchainService.ambilSemuaUU();
    final uu = uuList.firstWhere(
      (item) =>
          (item['hash_uu']?.toString().toLowerCase() == hash_uu.toString().toLowerCase()) ||
          (item['txHash']?.toString().toLowerCase() == txHashLocal.toString().toLowerCase()),
      orElse: () => {},
    );

    bool valid = false;
    String? txHashBlockchain;
    if (uu.isNotEmpty) {
      txHashBlockchain = uu['txHash']?.toString().toLowerCase();

      // HashUU di smart contract = txHash, jadi bandingkan HashUU dengan hash lokal
      valid = (hash_uu.toString().toLowerCase() == uu['hash_uu']?.toString().toLowerCase()) &&
              (txHashLocal.toString().toLowerCase() == txHashBlockchain);
    }

    // Hasil verifikasi
    _showErrorDialog(
      context,
      valid ? 'UU ASLI' : 'UU TIDAK VALID',
      uu.isEmpty
          ? 'HashUU tidak cocok dengan data blockchain.'
          : valid
              ? 'Dokumen terverifikasi.\nHashUU: $hash_uu\nTxHash: $txHashBlockchain'
              : 'Hash tidak cocok!\nHashUU: $hash_uu\nHash lokal: $txHashLocal\nHash blockchain/HashUU: $txHashBlockchain',
    );
  } catch (e) {
    _showErrorDialog(context, 'Terjadi Error', 'Kesalahan saat verifikasi: $e');
  }
}

void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ],
    ),
  );
}

String keccak256(List<int> input) {
  final hashBytes = web3crypto.keccak256(Uint8List.fromList(input));
  return hashBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

Future<String> extractTextFromPdfBytes(Uint8List bytes) async {
  final PdfDocument document = PdfDocument(inputBytes: bytes);
  String allText = '';
  for (int i = 0; i < document.pages.count; i++) {
    final pageText = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
    allText += pageText;
  }
  document.dispose();
  return allText;
}

String cleanExtractedText(String rawText) {
  return rawText.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
