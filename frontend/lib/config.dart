const String rpcUrl = "http://127.0.0.1:8545"; // Ganti sesuai node Hardhat/Ganache
String contractAddress = "0x4826533B4897376654Bb4d4AD88B7faFD0C98528".toLowerCase();// Ganti dengan alamat kontrak yang sesuai

const String abi = '''
[
  {
    "inputs": [
      { "internalType": "bytes32", "name": "hash_uu", "type": "bytes32" },
      { "internalType": "string", "name": "_judul", "type": "string" },
      { "internalType": "string", "name": "_isi", "type": "string" },
      { "internalType": "uint256", "name": "_tanggalMulai", "type": "uint256" },
      { "internalType": "uint256", "name": "_tanggalBerakhir", "type": "uint256" }
    ],
    "name": "buatUU",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "_index", "type": "uint256" }],
    "name": "getUU",
    "outputs": [
      { "internalType": "bytes32", "name": "hash_uu", "type": "bytes32" },
      { "internalType": "string", "name": "judul", "type": "string" },
      { "internalType": "string", "name": "isi", "type": "string" },
      { "internalType": "uint256", "name": "tanggalMulai", "type": "uint256" },
      { "internalType": "uint256", "name": "tanggalBerakhir", "type": "uint256" },
      { "internalType": "address", "name": "pembuat", "type": "address" },
      { "internalType": "bytes32", "name": "txHash", "type": "bytes32" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "jumlahUU",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "internalType": "bytes32", "name": "hash_uu", "type": "bytes32" },
      { "indexed": false, "internalType": "string", "name": "judul", "type": "string" },
      { "indexed": true, "internalType": "address", "name": "pembuat", "type": "address" },
      { "indexed": false, "internalType": "bytes32", "name": "txHash", "type": "bytes32" }
    ],
    "name": "UUDibuat",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "getSemuaUU",
    "outputs": [
      { "internalType": "bytes32[]", "name": "hash_uuList", "type": "bytes32[]" },
      { "internalType": "string[]", "name": "judulList", "type": "string[]" },
      { "internalType": "string[]", "name": "isiList", "type": "string[]" },
      { "internalType": "uint256[]", "name": "mulaiList", "type": "uint256[]" },
      { "internalType": "uint256[]", "name": "berakhirList", "type": "uint256[]" },
      { "internalType": "address[]", "name": "pembuatList", "type": "address[]" },
      { "internalType": "bytes32[]", "name": "txHashList", "type": "bytes32[]" }
    ],
    "stateMutability": "view",
    "type": "function"
  }
]
''';
