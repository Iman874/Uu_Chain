# 🔗 Arsitektur Blockchain — Uu_Chain

Dokumen ini menjelaskan secara mendalam arsitektur blockchain yang digunakan pada proyek Uu_Chain,
mulai dari teknologi, instalasi, koneksi, hingga cara penggunaan.

---

## 📋 Daftar Isi

- [1. Overview Arsitektur](#1-overview-arsitektur)
- [2. Technology Stack Blockchain](#2-technology-stack-blockchain)
- [3. Arsitektur Smart Contract](#3-arsitektur-smart-contract)
- [4. Instalasi Blockchain Lokal (Hardhat)](#4-instalasi-blockchain-lokal-hardhat)
- [5. Koneksi Frontend ↔ Blockchain](#5-koneksi-frontend--blockchain)
- [6. Alur Data End-to-End](#6-alur-data-end-to-end)
- [7. Hashing & Verifikasi](#7-hashing--verifikasi)
- [8. Konfigurasi Jaringan](#8-konfigurasi-jaringan)
- [9. Deployment Flow](#9-deployment-flow)
- [10. Keamanan & Limitasi](#10-keamanan--limitasi)

---

## 1. Overview Arsitektur

```
┌────────────────────────────────────┐
│         Flutter Web (Chrome)       │
│   ┌──────────────────────────┐     │
│   │    BlockchainService     │     │
│   │  (web3dart + http client)│     │
│   └────────────┬─────────────┘     │
└────────────────┼───────────────────┘
                 │ JSON-RPC over HTTP
                 │ http://127.0.0.1:8545
                 ▼
┌────────────────────────────────────┐
│      Hardhat Local Node            │
│  ┌──────────────────────────────┐  │
│  │   Ethereum Virtual Machine   │  │
│  │  ┌────────────────────────┐  │  │
│  │  │  UuChain.sol Contract  │  │  │
│  │  │  (Solidity ^0.8.0)     │  │  │
│  │  └────────────────────────┘  │  │
│  └──────────────────────────────┘  │
│  Chain ID: 31337                   │
│  20 Pre-funded Accounts (10k ETH)  │
└────────────────────────────────────┘
```

**Prinsip Utama:**
- Blockchain berjalan **100% lokal** via Hardhat Node
- Komunikasi via **JSON-RPC** (standar Ethereum)
- Frontend langsung berkomunikasi ke node tanpa backend perantara
- Semua data UU bersifat **immutable** setelah dicatat di blockchain

---

## 2. Technology Stack Blockchain

### 2.1 Komponen Inti

| Layer | Teknologi | Versi | Fungsi |
|-------|-----------|-------|--------|
| **Blockchain Runtime** | Hardhat Node | ^2.24.1 | Simulasi jaringan Ethereum lokal |
| **Smart Contract** | Solidity | ^0.8.0 | Bahasa pemrograman kontrak |
| **Deployment** | Hardhat + Ethers.js | ^5.8.0 | Compile & deploy kontrak |
| **Testing Framework** | Waffle + Chai | ^4.0.10 / ^5.2.0 | Unit testing kontrak |
| **Client Library** | web3dart (Flutter) | ^2.6.1 | Interaksi frontend ↔ blockchain |
| **HTTP Transport** | http (Dart) | ^0.13.6 | Transport layer untuk JSON-RPC |
| **Hashing** | Keccak-256 | — | Integritas data UU |

### 2.2 Dependency Map (network/package.json)

```
hardhat (^2.24.1)
├── @nomiclabs/hardhat-waffle (^2.0.6)  ← Plugin testing
├── @nomiclabs/hardhat-ethers (^2.2.3)  ← Plugin ethers integration
├── ethereum-waffle (^4.0.10)           ← Smart contract testing
├── ethers (^5.8.0)                     ← Ethereum interaction library
└── chai (^5.2.0)                       ← Assertion library
```

### 2.3 Mengapa Hardhat?

| Kriteria | Hardhat | Ganache | Foundry |
|----------|---------|---------|---------|
| Setup | ✅ Sangat mudah | ✅ Mudah | ⚠️ Perlu Rust |
| Debugging | ✅ `console.log` di Solidity | ❌ Terbatas | ✅ Bagus |
| Ekosistem Plugin | ✅ Sangat luas | ❌ Minimal | ⚠️ Sedang |
| Pre-funded Accounts | ✅ 20 akun × 10K ETH | ✅ 10 akun | ✅ Ada |
| Cocok untuk edukasi | ✅ | ✅ | ⚠️ |

---

## 3. Arsitektur Smart Contract

### 3.1 Contract: `UuChain.sol`

**File:** `network/contracts/UuChain.sol`
**License:** MIT | **Solidity:** ^0.8.0

#### Data Structure

```solidity
struct UndangUndang {
    bytes32 hash_uu;          // Keccak-256 hash dari konten UU
    string  judul;            // Judul Undang-Undang
    string  isi;              // Isi lengkap UU
    uint256 tanggalMulai;     // Timestamp mulai berlaku (ms)
    uint256 tanggalBerakhir;  // Timestamp kedaluwarsa (ms)
    address pembuat;          // Alamat wallet pembuat (auto dari msg.sender)
    bytes32 txHash;           // Hash transaksi (= hash_uu)
}
```

#### Storage

```solidity
UndangUndang[] public daftarUU;  // Dynamic array — semua UU tersimpan di sini
```

#### Functions

| Function | Tipe | Parameter | Return | Deskripsi |
|----------|------|-----------|--------|-----------|
| `buatUU()` | Write | hash_uu, judul, isi, tanggalMulai, tanggalBerakhir | — | Membuat UU baru ke blockchain |
| `getUU(index)` | View (Read) | uint256 index | Semua field UU | Ambil 1 UU berdasarkan index |
| `getSemuaUU()` | View (Read) | — | Array semua field | Ambil seluruh UU sekaligus |
| `jumlahUU()` | View (Read) | — | uint256 | Total jumlah UU tercatat |

#### Event

```solidity
event UUDibuat(
    bytes32 hash_uu,
    string  judul,
    address indexed pembuat,  // indexed = bisa di-filter di log
    bytes32 txHash
);
```

### 3.2 Diagram Relasi

```
┌─────────────────────────────────────────┐
│           UuChain Contract              │
│                                         │
│  daftarUU[] ◄──── buatUU()   [WRITE]    │
│      │                                  │
│      ├──────► getUU(i)       [READ]     │
│      ├──────► getSemuaUU()   [READ]     │
│      └──────► jumlahUU()     [READ]     │
│                                         │
│  Event: UUDibuat ──► emitted on buatUU  │
└─────────────────────────────────────────┘
```

> **Catatan:** Fungsi `view` (READ) tidak memerlukan gas/biaya transaksi.
> Hanya `buatUU()` (WRITE) yang membutuhkan transaksi dan gas.

---

## 4. Instalasi Blockchain Lokal (Hardhat)

### 4.1 Prerequisites

```bash
# Pastikan Node.js v16+ terinstall
node -v    # Output: v16.x.x atau lebih tinggi
npm -v     # Output: v8.x.x atau lebih tinggi
```

### 4.2 Instalasi Dependensi

```bash
cd network
npm install
```

**Apa yang terjadi:**
1. npm membaca `package.json`
2. Download & install Hardhat + semua plugin
3. Membuat folder `node_modules/` dengan semua dependency
4. Generate `package-lock.json` (version lock)

### 4.3 Struktur Setelah Install

```
network/
├── contracts/
│   └── UuChain.sol          # Smart contract
├── scripts/
│   └── deploy.js            # Script deployment
├── hardhat.config.js        # Konfigurasi Hardhat
├── package.json             # Dependency list
├── package-lock.json        # Locked versions
├── node_modules/            # ← Dibuat setelah npm install
├── artifacts/               # ← Dibuat setelah compile
│   └── contracts/
│       └── UuChain.sol/
│           ├── UuChain.json     # ABI + Bytecode
│           └── UuChain.dbg.json # Debug info
└── cache/                   # ← Cache Hardhat
```

### 4.4 Menjalankan Node Lokal

```bash
cd network
npx hardhat node
```

**Output yang dihasilkan:**

```
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Accounts
========

Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

... (total 20 akun pre-funded)
```

**Yang terjadi di balik layar:**
1. Hardhat membuat **blockchain Ethereum virtual** di memori
2. Membuat **20 akun test** dengan masing-masing 10.000 ETH
3. Membuka **JSON-RPC server** di `http://127.0.0.1:8545`
4. Setiap transaksi langsung di-mine (tanpa menunggu)
5. **Data hilang** saat node dihentikan (in-memory only)

### 4.5 Konfigurasi Hardhat

**File:** `network/hardhat.config.js`

```javascript
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.0",          // Versi compiler Solidity
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",  // RPC endpoint
      chainId: 31337,                 // Chain ID Hardhat default
    }
  }
};
```

| Parameter | Nilai | Penjelasan |
|-----------|-------|------------|
| `solidity` | `"0.8.0"` | Versi compiler, harus match dengan `pragma` di .sol |
| `url` | `http://127.0.0.1:8545` | Alamat JSON-RPC server |
| `chainId` | `31337` | Identifier unik jaringan Hardhat |

---

## 5. Koneksi Frontend ↔ Blockchain

### 5.1 Arsitektur Koneksi

```
┌─────────────────────────────────────────────────────┐
│                   Flutter Web App                    │
│                                                     │
│  config.dart ─────────────────────────────────┐     │
│  ┌─────────────┐   ┌──────────────────────┐   │     │
│  │ rpcUrl       │   │ contractAddress      │   │     │
│  │ abi (JSON)   │   │ (dari deploy output) │   │     │
│  └──────┬──────┘   └──────────┬───────────┘   │     │
│         │                     │               │     │
│         ▼                     ▼               │     │
│  ┌──────────────────────────────────────┐     │     │
│  │       BlockchainService.create()     │     │     │
│  │                                      │     │     │
│  │  Web3Client ◄── rpcUrl + HTTP Client │     │     │
│  │  DeployedContract ◄── ABI + Address  │     │     │
│  │                                      │     │     │
│  │  Functions:                          │     │     │
│  │   _buatUU     ◄─ contract.function() │     │     │
│  │   _getUU      ◄─ contract.function() │     │     │
│  │   _jumlahUU   ◄─ contract.function() │     │     │
│  │   _getSemuaUU ◄─ contract.function() │     │     │
│  └──────────────────────────────────────┘     │     │
└───────────────────────┬─────────────────────────────┘
                        │
                        │  JSON-RPC (eth_call, eth_sendTransaction)
                        │  HTTP POST http://127.0.0.1:8545
                        ▼
              ┌───────────────────┐
              │   Hardhat Node    │
              │   UuChain.sol     │
              └───────────────────┘
```

### 5.2 Tiga Komponen Koneksi

#### A. RPC URL — Alamat node blockchain

```dart
// frontend/lib/config.dart
const String rpcUrl = "http://127.0.0.1:8545";
```

#### B. Contract Address — Lokasi smart contract di blockchain

```dart
// frontend/lib/config.dart  (WAJIB diupdate setiap deploy)
String contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3".toLowerCase();
```

#### C. ABI (Application Binary Interface) — "API spec" dari smart contract

```dart
// frontend/lib/config.dart
const String abi = '''
[
  { "name": "buatUU",      "type": "function", "stateMutability": "nonpayable", ... },
  { "name": "getUU",       "type": "function", "stateMutability": "view", ... },
  { "name": "jumlahUU",    "type": "function", "stateMutability": "view", ... },
  { "name": "getSemuaUU",  "type": "function", "stateMutability": "view", ... },
  { "name": "UUDibuat",    "type": "event", ... }
]
''';
```

### 5.3 Inisialisasi Service (di Flutter)

```dart
// BlockchainService.create() melakukan:
final client   = Web3Client(rpcUrl, Client());           // 1. Buat HTTP client ke node
final address  = EthereumAddress.fromHex(contractAddress); // 2. Parse alamat kontrak
final contract = DeployedContract(                        // 3. Load kontrak dari ABI
  ContractAbi.fromJson(abi, 'UuChain'), address
);
// 4. Bind semua fungsi kontrak
final _buatUU     = contract.function('buatUU');
final _getUU      = contract.function('getUU');
final _jumlahUU   = contract.function('jumlahUU');
final _getSemuaUU = contract.function('getSemuaUU');
```

### 5.4 Operasi READ vs WRITE

| Operasi | Metode | Gas? | Mengubah State? | Contoh |
|---------|--------|------|-----------------|--------|
| **READ** | `client.call()` | ❌ Gratis | Tidak | `getUU()`, `getSemuaUU()`, `jumlahUU()` |
| **WRITE** | `client.sendTransaction()` | ✅ Butuh gas | Ya | `buatUU()` |

```dart
// READ — Tidak perlu private key, gratis
final result = await _client.call(
  contract: _contract,
  function: _getSemuaUU,
  params: [],
);

// WRITE — Perlu private key untuk sign transaksi
final credentials = EthPrivateKey.fromHex(user.privateKey);
final txHash = await _client.sendTransaction(
  credentials,
  Transaction.callContract(
    contract: _contract,
    function: _buatUU,
    parameters: [hash_uu, judul, isi, tanggalMulai, tanggalBerakhir],
  ),
  chainId: 31337,  // WAJIB sesuai Hardhat
);
```

---

## 6. Alur Data End-to-End

### 6.1 Alur: Admin Membuat UU Baru

```
Admin Input (Flutter UI)
    │
    ▼
┌──────────────────────────────────┐
│ 1. Validasi form (judul, isi,   │
│    tanggalBerlaku, tanggalExpiry)│
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│ 2. Hitung hash_uu               │
│    = keccak256(                  │
│        judul + isi +             │
│        tanggalMulai(detik) +     │
│        tanggalBerakhir(detik)    │
│      )                          │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│ 3. Sign transaksi dengan        │
│    private key admin             │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│ 4. Kirim ke Hardhat Node        │
│    via JSON-RPC                  │
│    method: eth_sendTransaction   │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│ 5. EVM eksekusi buatUU()        │
│    - Push ke daftarUU[]          │
│    - Emit event UUDibuat         │
│    - Auto-mine block             │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│ 6. Return txHash ke Flutter     │
│    → Tampilkan di UI            │
└──────────────────────────────────┘
```

### 6.2 Alur: User Verifikasi UU via PDF

```
User Upload PDF
    │
    ▼
┌───────────────────────────────────┐
│ 1. Ekstrak teks dari PDF          │
│    (Syncfusion PDF parser)        │
│    → Parse: judul, isi, tanggal,  │
│      hash_uu via RegExp           │
└───────────────┬───────────────────┘
                ▼
┌───────────────────────────────────┐
│ 2. Hitung hash lokal              │
│    = keccak256(judul+isi+tgl)     │
└───────────────┬───────────────────┘
                ▼
┌───────────────────────────────────┐
│ 3. Ambil semua UU dari blockchain │
│    → getSemuaUU() [READ]          │
└───────────────┬───────────────────┘
                ▼
┌───────────────────────────────────┐
│ 4. Cocokkan hash_uu PDF          │
│    dengan hash di blockchain      │
│    DAN hash lokal = txHash        │
└───────────────┬───────────────────┘
                ▼
         ┌──────┴──────┐
         │             │
     COCOK          TIDAK
         │             │
    ✅ VALID      ❌ INVALID
```

---

## 7. Hashing & Verifikasi

### 7.1 Algoritma Hash

Proyek ini menggunakan **Keccak-256** (hash native Ethereum) untuk membuat sidik jari unik dari setiap UU.

```
hash_uu = keccak256(
    normalize(judul)           ← UTF-8 encoded
  + normalize(isi)             ← UTF-8 encoded
  + encode_uint256(tglMulai)   ← Big-endian minimal bytes
  + encode_uint256(tglBerakhir)← Big-endian minimal bytes
)
```

### 7.2 Kenapa Keccak-256?

- Native di Ethereum (tersedia via opcode `SHA3`)
- Collision-resistant: hampir mustahil 2 input menghasilkan hash sama
- Deterministik: input sama → output **selalu** sama
- Output fixed 32 bytes (64 karakter hex)

### 7.3 Normalisasi Sebelum Hash

```dart
String normalizeText(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();
```

Semua whitespace berlebih dihapus agar hash konsisten antara input admin dan verifikasi PDF.

---

## 8. Konfigurasi Jaringan

### 8.1 Parameter Jaringan

| Parameter | Nilai | Keterangan |
|-----------|-------|------------|
| **Network** | Hardhat Local | Simulasi Ethereum |
| **RPC URL** | `http://127.0.0.1:8545` | JSON-RPC endpoint |
| **Chain ID** | `31337` | Default Hardhat |
| **Consensus** | Instant mining | Setiap tx langsung di-mine |
| **Block Gas Limit** | 30M gas | Default Hardhat |
| **Akun Test** | 20 akun | Masing-masing 10.000 ETH |

### 8.2 Akun yang Digunakan

| Role | Account # | Digunakan Untuk |
|------|-----------|-----------------|
| Admin | Account #0 | Membuat UU baru (write) |
| User 1 | Account #1 | Melihat & memverifikasi UU (read) |

Private key disimpan di `frontend/lib/data/dummy_data.dart`.

---

## 9. Deployment Flow

### 9.1 Compile & Deploy

```bash
# Terminal 1: Node harus sudah jalan
cd network
npx hardhat node

# Terminal 2: Deploy kontrak
cd network
npx hardhat run scripts/deploy.js --network localhost
```

### 9.2 Apa yang Terjadi Saat Deploy

```
deploy.js dijalankan
    │
    ▼
┌──────────────────────────────────────┐
│ 1. ethers.getContractFactory()       │
│    → Compile UuChain.sol             │
│    → Generate ABI + Bytecode         │
│    → Simpan ke artifacts/            │
└──────────────┬───────────────────────┘
               ▼
┌──────────────────────────────────────┐
│ 2. UuChain.deploy()                  │
│    → Kirim bytecode ke Hardhat Node  │
│    → EVM buat contract instance      │
│    → Assign alamat unik              │
└──────────────┬───────────────────────┘
               ▼
┌──────────────────────────────────────┐
│ 3. uuChain.deployed()               │
│    → Tunggu konfirmasi               │
│    → Print alamat kontrak            │
│    Output: "UuChain deployed to:     │
│     0x5FbDB23156..."                 │
└──────────────────────────────────────┘
```

### 9.3 Post-Deploy Checklist

Setelah deploy, **WAJIB** update 2 file di frontend:

| File | Yang Diupdate | Contoh |
|------|---------------|--------|
| `frontend/lib/config.dart` | `contractAddress` | Alamat dari output deploy |
| `frontend/lib/data/dummy_data.dart` | `privateKey` | Private key dari output Hardhat node |

---

## 10. Keamanan & Limitasi

### 10.1 ⚠️ Limitasi (Demo Only)

| Aspek | Status | Penjelasan |
|-------|--------|------------|
| Private key di frontend | 🔴 **Tidak aman** | Hanya untuk demo, production harus di backend |
| Tidak ada access control | 🔴 | Siapapun bisa panggil `buatUU()` |
| Data in-memory | 🟡 | Data hilang saat Hardhat node di-restart |
| Jaringan lokal only | 🟡 | Tidak bisa diakses dari luar localhost |
| Tidak ada upgrade mechanism | 🟡 | Kontrak tidak bisa diupdate setelah deploy |

### 10.2 Jika Ingin ke Production

| Aspek | Yang Perlu Ditambahkan |
|-------|----------------------|
| Access Control | Tambahkan `modifier onlyAdmin` di Solidity |
| Key Management | Pindahkan private key ke backend + gunakan wallet (MetaMask) |
| Persistent Data | Deploy ke testnet (Sepolia) atau mainnet |
| Upgrade Pattern | Implementasi Proxy Pattern (EIP-1967) |
| Backend Layer | Tambahkan API backend sebagai perantara |

---

## Referensi File

| File | Lokasi | Fungsi |
|------|--------|--------|
| Smart Contract | `network/contracts/UuChain.sol` | Logika blockchain |
| Deploy Script | `network/scripts/deploy.js` | Deployment automation |
| Hardhat Config | `network/hardhat.config.js` | Network & compiler config |
| Blockchain Service | `frontend/lib/service/block_chain_service.dart` | Flutter ↔ Blockchain bridge |
| App Config | `frontend/lib/config.dart` | RPC URL, ABI, Contract Address |
| Dummy Users | `frontend/lib/data/dummy_data.dart` | Test accounts & private keys |
| Verifikasi | `frontend/lib/ultility/verifikasi_uu.dart` | Hash verification logic |
| Admin Page | `frontend/lib/pages/home_page_admin.dart` | UI pembuatan UU |
