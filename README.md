# Uu_Chain

**Uu_Chain** adalah aplikasi sederhana yang mengimplementasikan konsep blockchain secara lokal. Aplikasi ini dibuat untuk mensimulasikan proses pembuatan dan pencatatan Undang-Undang (UU) pada jaringan blockchain lokal menggunakan Hardhat dan Flutter.

---

## Penjelasan Singkat Aplikasi

Aplikasi ini memungkinkan pengguna untuk membuat dan mencatat Undang-Undang (UU) di jaringan blockchain lokal. Setiap UU memiliki judul, isi, tanggal berlaku, dan tanggal kadaluarsa yang dicatat dalam blockchain menggunakan smart contract Solidity.

---

## Fitur Utama Aplikasi

- Membuat dan mencatat UU ke dalam blockchain.
- Menentukan tanggal mulai dan kadaluarsa UU.
- Menampilkan daftar UU yang telah dibuat.
- Mendownload data UU dalam bentuk PDF lengkap dengan hash.
- Simulasi berjalan di jaringan blockchain lokal (Hardhat).

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
'''

### 1. Clone Repository
```bash
git clone https://github.com/username/uu_chain.git
cd uu_chain
2. Instalasi Dependensi untuk Hardhat
bash
Salin
Edit
npm install
3. Jalankan Hardhat Node (Blockchain Lokal)
bash
Salin
Edit
npx hardhat node
4. Deploy Smart Contract ke Jaringan Lokal
Jalankan perintah ini di terminal baru agar node tetap berjalan.

bash
Salin
Edit
npx hardhat run scripts/deploy.js --network localhost
5. Jalankan Flutter Frontend
Masuk ke direktori proyek Flutter, lalu jalankan:

bash
Salin
Edit
flutter pub get
flutter run
Pastikan koneksi ke Hardhat node sudah aktif dan smart contract berhasil ter-deploy.

Catatan Tambahan
Untuk membersihkan proyek dari folder yang tidak diperlukan, tambahkan skrip berikut ke dalam package.json:

json
Salin
Edit
"scripts": {
  "clean": "rm -rf node_modules artifacts cache coverage"
}
Lalu jalankan:

bash
Salin
Edit
npm run clean
Pastikan di sisi Flutter, koneksi ke node lokal http://127.0.0.1:8545 sudah sesuai. Bila menggunakan emulator, sesuaikan alamat IP jika perlu (10.0.2.2 untuk Android emulator).

Lisensi
Proyek ini bersifat open-source dan dapat digunakan untuk kepentingan edukasi.

