import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import '../models/user.dart';

class BlockchainService {
  final Web3Client _client;
  final DeployedContract _contract;
  // ignore: unused_field
  final EthereumAddress _contractAddress;

  final ContractFunction _buatUU;
  final ContractFunction _getUU;
  // ignore: unused_field
  final ContractFunction _jumlahUU;
  final ContractFunction _getSemuaUU;

  BlockchainService._(
    this._client,
    this._contract,
    this._contractAddress,
    this._buatUU,
    this._getUU,
    this._jumlahUU,
    this._getSemuaUU,
  );

  static Future<BlockchainService> create({
    required String rpcUrl,
    required String abi,
    required String contractAddress,
  }) async {
    final client = Web3Client(rpcUrl, Client());
    final EthereumAddress address = EthereumAddress.fromHex(contractAddress);
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, 'UuChain'),
      address,
    );

    return BlockchainService._(
      client,
      contract,
      address,
      contract.function('buatUU'),
      contract.function('getUU'),
      contract.function('jumlahUU'),
      contract.function('getSemuaUU'),
    );
  }

  // Fungsi untuk convert HashUU string ke Uint8List 32 bytes (bytes32)
  Uint8List hash_uuToBytes32(String hexStr) {
    // Pastikan panjangnya 64 karakter (32 byte hex)
    if (hexStr.length != 64) {
      throw FormatException("HashUU hash harus 64 karakter hex");
    }
    final bytes = <int>[];
    for (int i = 0; i < 64; i += 2) {
      final byte = int.parse(hexStr.substring(i, i + 2), radix: 16);
      bytes.add(byte);
    }
    return Uint8List.fromList(bytes);
  }


  Future<Map<String, dynamic>> tambahUU({
  required User user,
  required String hash_uu,
  required String judul,
  required String isi,
  required int tanggalMulai,
  required int tanggalBerakhir,
  required int tanggalMulaiMs,
  required int tanggalBerakhirMs,
}) async {
  final credentials = EthPrivateKey.fromHex(user.privateKey);

  final txHash = await _client.sendTransaction(
    credentials,
    Transaction.callContract(
      contract: _contract,
      function: _buatUU,
      parameters: [
        hash_uuToBytes32(hash_uu), // 
        judul,
        isi,
        BigInt.from(tanggalMulaiMs),
        BigInt.from(tanggalBerakhirMs),
      ],
    ),
    chainId: 31337,
  );

  // Ambil data terakhir
  final uuList = await ambilSemuaUU();
  final uuBaru = uuList.isNotEmpty ? uuList.last : null;

  return {
    'hash_uu': uuBaru?['hash_uu'] ?? '',
    'judul': uuBaru?['judul'] ?? judul,
    'isi': uuBaru?['isi'] ?? isi,
    'tanggalMulai': uuBaru?['tanggalMulai'],
    'tanggalBerakhir': uuBaru?['tanggalBerakhir'],
    'txHash': uuBaru?['txHash'] ?? '',
    'txHashEth': txHash,
  };
}


  Future<Map<String, dynamic>> ambilUU(int index) async {
    final result = await _client.call(
      contract: _contract,
      function: _getUU,
      params: [BigInt.from(index)],
    );

    // result[0] = hash_uu (bytes32)
    // result[1] = judul
    // result[2] = isi
    // result[3] = tanggalMulai
    // result[4] = tanggalBerakhir
    // result[5] = pembuat
    // result[6] = txHash (bytes32)
    final Uint8List hash_uuBytes = result[0] as Uint8List;
    final String hash_uuHex = bytesToHex(hash_uuBytes);
    final Uint8List txHashBytes = result[6] as Uint8List;
    final String txHashHex = bytesToHex(txHashBytes);

    return {
      'hash_uu': hash_uuHex,
      'judul': result[1] as String,
      'isi': result[2] as String,
      'tanggalMulai': (result[3] as BigInt).toInt(),
      'tanggalBerakhir': (result[4] as BigInt).toInt(),
      'pembuat': result[5] as EthereumAddress,
      'txHash': txHashHex,
    };
  }

  Future<List<Map<String, dynamic>>> ambilSemuaUU() async {
    final result = await _client.call(
      contract: _contract,
      function: _getSemuaUU,
      params: [],
    );

    // result[0] = hash_uu list (List<Uint8List>)
    // result[1] = judul list (List<String>)
    // result[2] = isi list (List<String>)
    // result[3] = tanggalMulai list (List<BigInt>)
    // result[4] = tanggalBerakhir list (List<BigInt>)
    // result[5] = pembuat list (List<EthereumAddress>)
    // result[6] = txHash list (List<Uint8List>)

    List<Uint8List> hash_uuList = (result[0] as List).cast<Uint8List>();
    List<String> judulList = List<String>.from(result[1]);
    List<String> isiList = List<String>.from(result[2]);
    List<int> mulaiList = (result[3] as List).map((e) => (e as BigInt).toInt()).toList();
    List<int> berakhirList = (result[4] as List).map((e) => (e as BigInt).toInt()).toList();
    List<EthereumAddress> pembuatList = List<EthereumAddress>.from(result[5]);
    List<Uint8List> txHashList = (result[6] as List).cast<Uint8List>();

    List<Map<String, dynamic>> uuList = [];
    for (int i = 0; i < judulList.length; i++) {
      uuList.add({
        'hash_uu': bytesToHex(hash_uuList[i]),
        'judul': judulList[i],
        'isi': isiList[i],
        'tanggalMulai': mulaiList[i],
        'tanggalBerakhir': berakhirList[i],
        'pembuat': pembuatList[i],
        'txHash': bytesToHex(txHashList[i]),
      });
    }

    return uuList;
  }

  // Helper konversi bytes ke hex string
  String bytesToHex(Uint8List bytes) {
    final StringBuffer buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  
}
