

# ⚖️ Uu_Chain

**Uu_Chain** adalah aplikasi sederhana yang mengimplementasikan konsep blockchain secara lokal.  
Aplikasi ini dibuat untuk mensimulasikan proses pembuatan dan pencatatan Undang-Undang (UU) pada jaringan blockchain lokal menggunakan **Hardhat** dan **Flutter**.

🎥 *Link demo penjelasan dan demo aplikasi:* (tambahkan link di sini)

---

# 🗂️ Daftar Isi
- [Penjelasan Singkat Aplikasi](#penjelasan-singkat-aplikasi)
- [Fitur Utama Aplikasi](#fitur-utama-aplikasi)
- [Alat yang Digunakan](#alat-yang-digunakan)
- [Peringatan!](#peringatan)
- [Cara Menjalankan Proyek](#cara-menjalankan-proyek)
  - [Clone Repository](#1️⃣-clone-repository)
  - [Instalasi Dependensi](#2️⃣-instalasi-dependensi-untuk-hardhat)
  - [Jalankan Hardhat Node](#3️⃣-jalankan-hardhat-node-blockchain-lokal)
  - [Deploy Smart Contract](#4️⃣-deploy-smart-contract-ke-jaringan-lokal)
  - [Jalankan Flutter](#5️⃣-jalankan-flutter-frontend)
- [Cara Membersihkan Proyek](#cara-membersihkan-proyek)
- [Lisensi](#lisensi)

---

<a name="penjelasan-singkat-aplikasi"></a>
## 🧾 Penjelasan Singkat Aplikasi

Aplikasi ini merupakan sistem pencatatan Undang-Undang (UU) berbasis blockchain lokal.  
Pengguna dapat **melihat** dan **mengunduh UU** yang telah tersimpan di blockchain, sementara **admin** memiliki kemampuan untuk **menambahkan UU baru** ke dalam jaringan.  
Setiap UU berisi informasi seperti:

- 📘 **Judul UU**  
- 📄 **Isi lengkap**  
- 📅 **Tanggal mulai berlaku**  
- ⏳ **Tanggal kedaluwarsa**  
- 🧬 **Hash UU** (hasil hash dari semua elemen di atas)

🔐 Seluruh data dicatat secara **transparan** dan **permanen** melalui smart contract Solidity yang dijalankan di jaringan lokal Hardhat.

---

<a name="fitur-utama-aplikasi"></a>
## 🚀 Fitur Utama Aplikasi

- ✍️ **Pencatatan UU oleh Admin**  
  Admin dapat membuat UU baru yang langsung disimpan ke blockchain lokal.

- 🧾 **Verifikasi UU melalui PDF**  
  Pengguna dapat mengunggah file PDF untuk memverifikasi apakah isinya sesuai dengan data UU di blockchain.

- 📥 **Unduh UU**  
  Pengguna dan admin dapat mengunduh dokumen UU secara lokal.

- 🔒 **Transparansi & Keamanan**  
  Semua data tidak dapat diubah setelah tercatat di blockchain.

---

<a name="alat-yang-digunakan"></a>
## 🧰 Alat yang Digunakan

- 🎯 **Frontend**: Flutter  
- 🛠️ **Smart Contract**: Solidity  
- 🔗 **Blockchain Framework**: Hardhat  
- 📚 **Library**:  
  - ethers.js  
  - ethereum-waffle  
  - chai  
- 🌐 **Jaringan**: Localhost (Hardhat local blockchain)

---

<a name="peringatan"></a>
## ⚠️ Peringatan!

🚧 Project ini hanya bersifat demo!  
🔐 Penggunaan private key di sisi frontend **sangat tidak disarankan**.  
⚙️ Semua konfigurasi sebaiknya ditangani oleh backend, namun untuk tujuan edukasi dan kesederhanaan, semua logika ditempatkan di frontend.
🌐 proyek ini hanya dapat berjalan pada flutter web!!

---

<a name="cara-menjalankan-proyek"></a>
## 🛠️ Cara Menjalankan Proyek

<a name="clone-repository"></a>
### 1️⃣ Clone Repository
```bash
git clone https://github.com/username/uu_chain.git
cd uu_chain
```

<a name="instalasi-dependensi"></a>
### 2️⃣ Instalasi Dependensi untuk Hardhat
```bash
cd network
npm install
```

<a name="jalankan-hardhat-node"></a>
### 3️⃣ Jalankan Hardhat Node (Blockchain Lokal)
```bash
cd network
npx hardhat node
```
### 🔑 Pastikan private key sesuai!
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

<a name="deploy-smart-contract"></a>
### 4️⃣ Deploy Smart Contract ke Jaringan Lokal
Jalankan perintah ini di terminal baru agar node tetap berjalan.
```bash
cd network
npx hardhat run scripts/deploy.js --network localhost
```
### 📍 Ubah bagian String contractAddress pada bagian frontend/lib/config.dart sesuai dengan hasil dari 
  npx hardhat run scripts/deploy.js --network localhost
  Karena setiap kali deploy dijalankan contractAddress akan berbeda.
```
String contractAddress = "0x4826533B4897376654Bb4d4AD88B7faFD0C98528".toLowerCase();// Ganti dengan alamat kontrak yang sesuai
```

<a name="jalankan-flutter"></a>
### 5️⃣ Jalankan Flutter Frontend dan instalasi dependensi yang diperlukan
Masuk ke direktori proyek Flutter, lalu jalankan:
```bash
cd frontend
flutter pub get
flutter run
```
### ✅ Pastikan koneksi ke Hardhat node sudah aktif dan smart contract berhasil ter-deploy.

---

<a name="cara-membersihkan-proyek"></a>
## Catatan Tambahan (🧹 Pembersihan Proyek)
Membersihkan proyek Node.js
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
Membersihkan proyek Flutter
```
cd frontend
flutter clean
```
📡 Pastikan di sisi Flutter, koneksi ke node lokal http://127.0.0.1:8545 sudah sesuai. Proyek ini hanya dapat berjalan pada flutter web!!

---

<a name="lisensi"></a>
# 📄 Lisensi
Proyek ini bersifat open-source dan dapat digunakan untuk kepentingan edukasi.

