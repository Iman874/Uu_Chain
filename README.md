# Uu_Chain

**Uu_Chain** adalah aplikasi sederhana yang mengimplementasikan konsep blockchain secara lokal. Aplikasi ini dibuat untuk mensimulasikan proses pembuatan dan pencatatan Undang-Undang (UU) pada jaringan blockchain lokal menggunakan Hardhat dan Flutter.
Link demo penjelasan dan demo aplikasi:

---

## Penjelasan Singkat Aplikasi
Aplikasi ini merupakan sistem pencatatan Undang-Undang (UU) berbasis blockchain lokal. Pengguna dapat melihat dan mengunduh UU yang telah tersimpan di blockchain, sementara admin memiliki kemampuan untuk menambahkan UU baru ke dalam jaringan. Setiap UU berisi informasi seperti:

- Judul UU  
- Isi lengkap  
- Tanggal mulai berlaku  
- Tanggal kedaluwarsa
- hash_uu (hasil hash Judul UU, isi lengkap, tanggal berlaku, dan tanggal kadaluarsa)

Seluruh data dicatat secara transparan dan permanen melalui smart contract yang dibangun menggunakan Solidity dan dijalankan di jaringan Hardhat lokal.

## Fitur Utama Aplikasi

- **Pencatatan UU oleh Admin**  
  Admin dapat membuat UU baru yang akan disimpan ke dalam blockchain lokal.

- **Verifikasi UU melalui PDF**  
  Pengguna dapat mengunggah file PDF untuk diverifikasi apakah sesuai dengan data UU yang tercatat di blockchain.

- **Unduh UU**  
  Pengguna dan admin dapat mengunduh dokumen UU untuk disimpan atau ditinjau secara lokal.

- **Transparansi dan Keamanan**  
  Semua data UU disimpan di blockchain lokal, sehingga tidak dapat diubah atau dimanipulasi setelah tercatat.

---

## Alat yang Digunakan

- **Frontend**: Flutter
- **Smart Contract**: Solidity
- **Blockchain Framework**: Hardhat
- **Library**:
  - ethers.js
  - ethereum-waffle
  - chai
- **Jaringan**: Localhost (Hardhat local blockchain)

---

## Peringatan!
Project ini hanya bersifat demo, penggunaan private key pada flutter sangat tidak di sarankan, dan juga semua informasi yang ada pada config.dart 
lebih baik ditangani oleh backend bukan oleh frontend, namun project ini hanya sebatas demo aplikasi dan untuk testing maka dari itu semua dilakukan
pada sisi frontend agar lebih simple.

## Cara Menjalankan Proyek

### 1. Clone Repository
```bash
git clone https://github.com/username/uu_chain.git
cd uu_chain
```
### 1. Clone Repository
```bash
git clone https://github.com/username/uu_chain.git
cd uu_chain
```
### 2. Instalasi Dependensi untuk Hardhat
```bash
cd network
npm install
```
### 3. Jalankan Hardhat Node (Blockchain Lokal)
```bash
cd network
npx hardhat node
```
## Pastikan private key sesuai!
Sesuaikan private key yang tergenerate setelah terminal menjalankan npx hardhat node
frontend/lib/models/dummy_data.dart
```
const dummyUsers = [
  User(
    name: 'Admin',
    privateKey: '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80', // ganti privkey ini dengan yang sesuai
  ),
  User(
    name: 'User 1',
    privateKey: '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d', // ganti privkey ini dengan yang sesuai
  ),
];

```

### 4. Deploy Smart Contract ke Jaringan Lokal
Jalankan perintah ini di terminal baru agar node tetap berjalan.
```bash
cd network
npx hardhat run scripts/deploy.js --network localhost
```
## Ubah bagian String contractAddress pada bagian frontend/lib/config.dart sesuai dengan hasil dari 
  npx hardhat run scripts/deploy.js --network localhost
  Karena setiap kali deploy dijalankan contractAddress akan berbeda.
```
String contractAddress = "0x4826533B4897376654Bb4d4AD88B7faFD0C98528".toLowerCase();// Ganti dengan alamat kontrak yang sesuai
```
 
### 5. Jalankan Flutter Frontend
Masuk ke direktori proyek Flutter, lalu jalankan:
```bash
cd frontend
flutter pub get
flutter run
```
### Pastikan koneksi ke Hardhat node sudah aktif dan smart contract berhasil ter-deploy.

### Catatan Tambahan
Untuk membersihkan proyek dari folder yang tidak diperlukan, pastikan skrip berikut ada dalam package.json:
```
   "scripts": {
    "clean": "rd /s /q node_modules && rd /s /q artifacts && rd /s /q cache && rd /s /q coverage"
  },
```
Lalu jalankan:

```
cd network
npm run clean
```
Untuk membersihkan proyek flutter jalankan:
```
cd frontend
flutter clean
```
Pastikan di sisi Flutter, koneksi ke node lokal http://127.0.0.1:8545 sudah sesuai. Bila menggunakan emulator, sesuaikan alamat IP jika perlu (10.0.2.2 untuk Android emulator).

### Lisensi
Proyek ini bersifat open-source dan dapat digunakan untuk kepentingan edukasi.

