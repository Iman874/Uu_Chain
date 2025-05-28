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
### 4. Deploy Smart Contract ke Jaringan Lokal
Jalankan perintah ini di terminal baru agar node tetap berjalan.
```bash
cd network
npx hardhat run scripts/deploy.js --network localhost
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

