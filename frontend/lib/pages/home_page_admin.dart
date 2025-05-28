import 'package:flutter/material.dart';
import '../models/user.dart';
import '../service/block_chain_service.dart';
import '../config.dart';
import '../ultility/download_pdf.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web3dart/crypto.dart' as web3crypto;
import 'package:flutter/foundation.dart';

class HomeAdminScreen extends StatefulWidget {
  final User user;

  const HomeAdminScreen({super.key, required this.user});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  DateTime? _tanggalBerlaku;
  DateTime? _tanggalKadaluarsa;

  final List<Map<String, dynamic>> _daftarUU = [];

  bool _isLoading = false;
  bool _isBlockchainReady = false;
  late BlockchainService _blockchainService;

  @override
  void initState() {
    super.initState();
    _initBlockchainService();
  }

  Future<void> _initBlockchainService() async {
    _blockchainService = await BlockchainService.create(
      rpcUrl: rpcUrl,
      abi: abi,
      contractAddress: contractAddress,
    );

    setState(() {
      _isBlockchainReady = true;
    });

    await _loadDaftarUU();
  }

  // Helper: normalisasi string (hapus whitespace berlebih)
  String normalizeText(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

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

  // Fungsi hash sesuai kontrak & verifikasi_uu.dart
  
   

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

  Future<void> _submitForm() async {
    if (!_isBlockchainReady) {
      _showSnackBar('Blockchain service belum siap, mohon tunggu sebentar');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalBerlaku == null || _tanggalKadaluarsa == null) {
      _showSnackBar('Tanggal berlaku dan kadaluarsa harus dipilih');
      return;
    }
    if (_tanggalKadaluarsa!.isBefore(_tanggalBerlaku!)) {
      _showSnackBar('Tanggal kadaluarsa tidak boleh sebelum tanggal berlaku');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simpan tanggal dalam milidetik (agar tidak kehilangan presisi saat dikonversi kembali)
      final tanggalMulaiMs = _tanggalBerlaku!.millisecondsSinceEpoch;
      final tanggalBerakhirMs = _tanggalKadaluarsa!.millisecondsSinceEpoch;
      // Untuk hash dan blockchain, gunakan detik (~/ 1000)
      final tanggalMulai = tanggalMulaiMs ~/ 1000;
      final tanggalBerakhir = tanggalBerakhirMs ~/ 1000;

      debugPrint('Judul: ${_judulController.text}');
      debugPrint('Isi: ${_isiController.text}');
      debugPrint('Tanggal Mulai: $tanggalMulai');
      debugPrint('Tanggal Berakhir: $tanggalBerakhir');

      // Gunakan hash yang sama dengan kontrak dan verifikasi_uu.dart
      // ignore: non_constant_identifier_names
      final hash_uuHash = hashUU(
        _judulController.text,
        _isiController.text,
        tanggalMulai,
        tanggalBerakhir,
      );

      final uuBaru = await _blockchainService.tambahUU(
        user: widget.user,
        hash_uu: hash_uuHash,
        judul: _judulController.text,
        isi: _isiController.text,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        tanggalMulaiMs: tanggalMulaiMs,
        tanggalBerakhirMs: tanggalBerakhirMs,
      );

      if (kDebugMode) {
        print('============== Debug Info ==============');
        print('Judul UU: ${_judulController.text}');
        print('Isi UU: ${_isiController.text}');
        print('Tanggal Berlaku: ${_tanggalBerlaku?.toIso8601String()}');
        print('Tanggal Kadaluarsa: ${_tanggalKadaluarsa?.toIso8601String()}');
        print('HashUU: $hash_uuHash');
        print('========================================');
      }

      setState(() {
        _daftarUU.add({
          'hash_uu': uuBaru['hash_uu'] ?? '',
          'judul': uuBaru['judul'] ?? '',
          'isi': uuBaru['isi'] ?? '',
          // Gunakan milidetik agar DateTime.fromMillisecondsSinceEpoch() benar
          'tanggalMulai': _tanggalBerlaku!.millisecondsSinceEpoch,
          'tanggalBerakhir': _tanggalKadaluarsa!.millisecondsSinceEpoch,
          'txHash':uuBaru['txHash'] ?? '',
        });
        _judulController.clear();
        _isiController.clear();
        _tanggalBerlaku = null;
        _tanggalKadaluarsa = null;
      });

      _showSnackBar('UU berhasil dibuat hash_uu: $hash_uuHash');
    } catch (e) {
      _showSnackBar('Gagal membuat UU: $e');
      debugPrint('Error saat membuat UU: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(BuildContext context, bool isBerlaku) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        if (isBerlaku) {
          _tanggalBerlaku = selected;
        } else {
          _tanggalKadaluarsa = selected;
        }
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadDaftarUU() async {
    try {
      final List<Map<String, dynamic>> daftar = await _blockchainService.ambilSemuaUU();
      setState(() {
        _daftarUU.clear();
        _daftarUU.addAll(daftar);
      });
    } catch (e) {
      _showSnackBar('Gagal memuat data UU: $e');
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('UuChain - ${widget.user.name}'),
      centerTitle: true,
      elevation: 4,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buat UU Baru',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    labelText: 'Judul UU',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Judul tidak boleh kosong' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _isiController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Isi UU',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Isi tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tanggalBerlaku == null
                            ? 'Tanggal Berlaku: -'
                            : 'Berlaku: ${_tanggalBerlaku!.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _pickDate(context, true),
                      icon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                      label: const Text(
                        'Pilih Tanggal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tanggalKadaluarsa == null
                            ? 'Tanggal Kadaluarsa: -'
                            : 'Kadaluarsa: ${_tanggalKadaluarsa!.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _pickDate(context, false),
                      icon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                      label: const Text(
                        'Pilih Tanggal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: (_isBlockchainReady && !_isLoading)
                            ? _submitForm
                            : null,
                        child: Text(
                          _isBlockchainReady ? 'Buat UU' : 'Loading blockchain...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_daftarUU.isNotEmpty) ...[
            Text(
              'Daftar UU',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ..._daftarUU.map(
              (uu) => Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      uu['judul'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HashUU: ${uu['hash_uu']}'),
                          const SizedBox(height: 4),
                          Text(
                            'Tanggal Berlaku: ${DateTime.fromMillisecondsSinceEpoch(uu['tanggalMulai']).toLocal().toString().split(' ')[0]}',
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tanggal Kadaluarsa: ${DateTime.fromMillisecondsSinceEpoch(uu['tanggalBerakhir']).toLocal().toString().split(' ')[0]}',
                          ),
                        ],
                      ),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      onPressed: () {
                        if (uu['tanggalMulai'] != null &&
                            uu['tanggalBerakhir'] != null) {
                          generateAndDownloadPDF(
                            context: context,
                            judul: uu['judul'] ?? '',
                            isi: uu['isi'] ?? '',
                            tanggalMulai:
                                DateTime.fromMillisecondsSinceEpoch(uu['tanggalMulai']),
                            tanggalBerakhir:
                                DateTime.fromMillisecondsSinceEpoch(uu['tanggalBerakhir']),
                            hash_uu: uu['hash_uu'] ?? '',
                          );
                        } else {
                          _showSnackBar('Tanggal tidak lengkap untuk download PDF.');
                        }
                      },
                      child: const Text(
                        'Download PDF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    ),
    );
  }

}
