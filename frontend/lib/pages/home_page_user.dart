import 'package:flutter/material.dart';
import '../models/user.dart';
import '../ultility/download_pdf.dart';
import '../ultility/verifikasi_uu.dart';
import '../service/block_chain_service.dart';
import '../config.dart';


class HomeUserScreen extends StatefulWidget {
  final User user;

  const HomeUserScreen({super.key, required this.user});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  late BlockchainService _blockchainService;
  List<Map<String, dynamic>> uuList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initBlockchain();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _initBlockchain() async {
    _blockchainService = await BlockchainService.create(
      rpcUrl: rpcUrl,
      abi: abi,
      contractAddress: contractAddress,
    );
    await _loadUU();
  }

  Future<void> _loadUU() async {
    setState(() => _isLoading = true);
    try {
      final data = await _blockchainService.ambilSemuaUU();
      setState(() {
        uuList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data UU: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('UuChain - ${widget.user.name}'),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: uuList.isEmpty
                    ? const Center(child: Text('Belum ada UU.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: uuList.length,
                        itemBuilder: (context, index) {
                          final uu = uuList[index];
                          return Card(
                            color: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ListTile(
                                title: Text(
                                  uu['judul'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text('HashUU: ${uu['hash_uu'] ?? ''}'),
                                    Text(
                                      'Tanggal Berlaku: ${uu['tanggalMulai'] != null ? DateTime.fromMillisecondsSinceEpoch(uu['tanggalMulai']).toLocal().toString().split(' ')[0] : '-'}',
                                    ),
                                    Text(
                                      'Tanggal Kadaluarsa: ${uu['tanggalBerakhir'] != null ? DateTime.fromMillisecondsSinceEpoch(uu['tanggalBerakhir']).toLocal().toString().split(' ')[0] : '-'}',
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                  ),
                                  onPressed: () {
                                    if (uu['tanggalMulai'] != null && uu['tanggalBerakhir'] != null) {
                                      generateAndDownloadPDF(
                                        context: context,
                                        judul: uu['judul'] ?? '',
                                        isi: uu['isi'] ?? '',
                                        tanggalMulai: DateTime.fromMillisecondsSinceEpoch(uu['tanggalMulai']),
                                        tanggalBerakhir: DateTime.fromMillisecondsSinceEpoch(uu['tanggalBerakhir']),
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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      verifikasiUU(context);
                    },
                    icon: const Icon(Icons.verified),
                    label: const Text('Verifikasi UU'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
  );
}

}
