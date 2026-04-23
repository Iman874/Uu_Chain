# 🚀 How to Run — Uu_Chain

Panduan lengkap untuk menjalankan proyek **Uu_Chain** dari awal hingga aplikasi siap digunakan.

---

## 📋 Prerequisites

Pastikan tools berikut sudah terinstall di sistem kamu:

| Tool       | Versi Minimum | Cek Instalasi          | Link Download                                      |
|------------|---------------|------------------------|-----------------------------------------------------|
| **Node.js** | v16+          | `node -v`              | [nodejs.org](https://nodejs.org/)                   |
| **npm**     | v8+           | `npm -v`               | Sudah termasuk di Node.js                           |
| **Flutter** | v3.8+         | `flutter --version`    | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| **Git**     | Terbaru       | `git --version`        | [git-scm.com](https://git-scm.com/)                |
| **Chrome**  | Terbaru       | —                      | [google.com/chrome](https://www.google.com/chrome/) |

> [!IMPORTANT]
> Proyek ini **hanya dapat berjalan pada Flutter Web** (Chrome). Platform mobile/desktop tidak didukung.

---

## 📁 Struktur Proyek

```
Uu_Chain/
├── network/              # Hardhat — blockchain lokal & smart contract
│   ├── contracts/
│   │   └── UuChain.sol   # Smart contract Solidity
│   ├── scripts/
│   │   └── deploy.js     # Script deploy kontrak
│   ├── hardhat.config.js
│   └── package.json
├── frontend/             # Flutter — aplikasi web
│   ├── lib/
│   │   ├── config.dart          # Konfigurasi RPC & contract address
│   │   ├── data/dummy_data.dart # Private key dummy users
│   │   ├── models/
│   │   ├── pages/
│   │   ├── service/
│   │   └── ultility/
│   └── pubspec.yaml
├── plan/
├── README.md
└── how_to_run.md         # ← File ini
```

---

## 🛠️ Langkah-Langkah Menjalankan

### Step 1 — Clone Repository

```bash
git clone https://github.com/Iman874/Uu_Chain.git
cd Uu_Chain
```

---

### Step 2 — Install Dependensi Hardhat

```bash
cd network
npm install
```

> [!NOTE]
> Perintah ini akan menginstall semua paket yang dibutuhkan: `hardhat`, `ethers`, `@nomiclabs/hardhat-waffle`, dll.

---

### Step 3 — Jalankan Hardhat Node (Blockchain Lokal)

```bash
cd network
npx hardhat node
```

**Output yang diharapkan:**

```
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Accounts
========
Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
...
```

> [!WARNING]
> **Jangan tutup terminal ini!** Node Hardhat harus tetap berjalan selama menggunakan aplikasi.

---

### Step 4 — Update Private Key (Jika Berubah)

Cocokkan **private key** dari output Hardhat node dengan file:

📄 **`frontend/lib/data/dummy_data.dart`**

```dart
const dummyUsers = [
  User(
    name: 'Admin',
    privateKey: '0xac0974...', // ← Ganti dengan Account #0
  ),
  User(
    name: 'User 1',
    privateKey: '0x59c699...', // ← Ganti dengan Account #1
  ),
];
```

> [!TIP]
> Private key bawaan Hardhat biasanya **tetap sama** setiap kali dijalankan. Kamu hanya perlu mengubahnya jika menggunakan konfigurasi Hardhat yang berbeda.

---

### Step 5 — Deploy Smart Contract

**Buka terminal baru** (terminal Hardhat node tetap berjalan), lalu:

```bash
cd network
npx hardhat run scripts/deploy.js --network localhost
```

**Output yang diharapkan:**

```
UuChain deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
```

> [!CAUTION]
> **Setiap kali deploy dijalankan, contract address akan berbeda!** Kamu WAJIB menyalin alamat ini ke langkah berikutnya.

---

### Step 6 — Update Contract Address

Salin alamat kontrak dari output deploy, lalu update file:

📄 **`frontend/lib/config.dart`**

```dart
String contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3".toLowerCase();
```

Pastikan juga **RPC URL** sudah sesuai:

```dart
const String rpcUrl = "http://127.0.0.1:8545";
```

---

### Step 7 — Jalankan Flutter Web

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

> [!NOTE]
> Gunakan flag `-d chrome` untuk memastikan aplikasi berjalan di browser Chrome. Atau bisa juga dengan `flutter run -d web-server` lalu buka URL yang diberikan di browser.

---

## ✅ Checklist Sebelum Menjalankan

- [ ] Node.js dan npm sudah terinstall
- [ ] Flutter SDK sudah terinstall dan `flutter doctor` tidak ada error kritis
- [ ] `npm install` di folder `network/` berhasil
- [ ] Hardhat node berjalan di terminal (http://127.0.0.1:8545)
- [ ] Smart contract sudah di-deploy dan contract address sudah di-update di `config.dart`
- [ ] Private key di `dummy_data.dart` sesuai dengan output Hardhat node
- [ ] `flutter pub get` di folder `frontend/` berhasil

---

## 🔄 Quick Restart (Jika Ingin Reset Semua Data)

Jika ingin mengulang dari awal (reset blockchain & data):

```bash
# 1. Hentikan Hardhat node (Ctrl+C di terminal node)

# 2. Jalankan ulang node
cd network
npx hardhat node

# 3. Deploy ulang kontrak (terminal baru)
cd network
npx hardhat run scripts/deploy.js --network localhost

# 4. Update contract address di frontend/lib/config.dart

# 5. Hot restart Flutter (tekan 'R' di terminal Flutter, atau jalankan ulang)
```

---

## 🧹 Membersihkan Proyek

### Bersihkan Network (Hardhat)

```bash
cd network
npm run clean
```

> Ini akan menghapus `node_modules/`, `artifacts/`, `cache/`, dan `coverage/`.

### Bersihkan Frontend (Flutter)

```bash
cd frontend
flutter clean
```

### Install Ulang Setelah Clean

```bash
# Network
cd network
npm install

# Frontend
cd frontend
flutter pub get
```

---

## ❗ Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `flutter run` error "No supported devices" | Pastikan menggunakan `-d chrome` dan Chrome sudah terinstall |
| Tidak bisa konek ke blockchain | Pastikan Hardhat node masih berjalan di `http://127.0.0.1:8545` |
| Transaksi gagal / `revert` | Pastikan contract address dan private key sudah benar dan sesuai |
| `npm install` gagal | Hapus `node_modules/` dan `package-lock.json`, lalu jalankan ulang `npm install` |
| Contract address tidak cocok | Jalankan ulang deploy dan salin alamat baru ke `config.dart` |
| Flutter web blank putih | Periksa console browser (F12) untuk error, biasanya RPC URL salah |

---

## 📌 Ringkasan Perintah

```bash
# Terminal 1 — Hardhat Node
cd network && npx hardhat node

# Terminal 2 — Deploy Contract
cd network && npx hardhat run scripts/deploy.js --network localhost

# Terminal 3 — Flutter Web
cd frontend && flutter pub get && flutter run -d chrome
```

> Butuh minimal **2 terminal** yang berjalan bersamaan (Hardhat node + Flutter).
