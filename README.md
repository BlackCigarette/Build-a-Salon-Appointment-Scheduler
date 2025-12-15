# Analisis dan Peningkatan Integritas Data pada Sistem Booking Salon
## (Studi Kasus: Pengembangan dari Proof of Concept ke Desain Siap Produksi)

## Executive Summary
### Latar Belakang

Proyek ini berawal dari sebuah tugas FreeCodeCamp berupa sistem booking salon sederhana berbasis CLI menggunakan Bash dan PostgreSQL.
Sistem tersebut saya perlakukan sebagai Proof of Concept (PoC) untuk memahami bagaimana sebuah sistem awal bekerja sebelum digunakan dalam skala yang lebih serius.

Dari PoC ini, saya melakukan analisis untuk melihat apakah sistem sudah cukup aman, rapi, dan siap dikembangkan ke tahap produksi.

### Tujuan
Tujuan dari studi kasus ini adalah menunjukkan cara saya berpikir sebagai Junior Technical Coordinator, khususnya dalam:

1. Memahami sistem yang sudah ada
2. Mengidentifikasi masalah integritas data dan keterbatasan arsitektur
3. Menyusun rekomendasi perbaikan agar sistem lebih stabil dan siap dikembangkan
   
Fokus utama proyek ini adalah analisis dan perencanaan teknis, _**bukan**_ pembuatan aplikasi secara penuh

### Fokus Proyek

Proyek ini berfokus pada:

1. Analisis integritas data menggunakan SQL
2. Pemahaman alur data dari input hingga penyimpanan
3. Evaluasi kesiapan sistem untuk skala produksi
4. Penggunaan Python dan AI tools untuk membantu analisis dan dokumentasi

### Pendekatan

Pendekatan yang digunakan meliputi:
1. Menganalisis struktur database dan alur sistem awal
2. Mengidentifikasi risiko sebelum sistem dikembangkan lebih jauh
3. Merancang perbaikan pada level desain database dan arsitektur
4. Melakukan investigasi data menggunakan SQL dan Python
   
Pendekatan ini mencerminkan peran Junior Technical Coordinator, yang bertugas membantu menjaga kualitas sistem dan data sejak tahap awal.

## Bagian 1 — Analisis Awal (The Starting Point)
### 1.1 Latar Belakang Proyek (Konteks PoC)
Sistem booking salon ini awalnya dikembangkan sebagai bagian dari tugas FreeCodeCamp dengan tujuan melatih pemahaman dasar mengenai:
1. Relasi antar tabel dalam database (Primary Key & Foreign Key)
2. Interaksi sederhana antara script Bash dan PostgreSQL
3. Alur input–proses–output dalam aplikasi berbasis CLI

Pada tahap ini, sistem sudah mampu menjalankan fungsi dasar, seperti:
1. menampilkan daftar layanan,
2. mencatat data pelanggan,
3. dan menyimpan jadwal appointment ke dalam database.

Sebagai Proof of Concept (PoC), sistem ini sudah memenuhi tujuannya:
membuktikan bahwa logika dasar aplikasi dan koneksi ke database dapat berjalan dengan baik.

### 1.2 Gambaran Arsitektur Sistem Awal
Secara umum, arsitektur sistem awal terdiri dari:
1. Interface: CLI berbasis Bash
2. Logic: Query SQL yang dieksekusi langsung dari script
3. Database: PostgreSQL dengan tiga tabel utama:
   
**customers**, **Services**, **appointments**

Alur data pada sistem awal dapat diringkas sebagai berikut:

Input Pengguna → Script Bash → Query SQL → Database → Output CLI

Struktur ini sederhana dan efektif untuk tahap pembelajaran, namun memiliki keterbatasan jika sistem ingin digunakan lebih lanjut.

### 1.3 Kekuatan Sistem Awal
Walaupun bersifat PoC, sistem awal memiliki beberapa kekuatan yang penting sebagai fondasi:

a. Relasi Data yang Jelas

Database sudah menggunakan:

1. Primary Key pada setiap tabel
2. Foreign Key pada tabel **_appointments_** yang menghubungkan pelanggan dan layanan

Hal ini menunjukkan bahwa struktur data sudah dipikirkan secara relasional dan tidak bersifat flat.

b. Kontrol Duplikasi Data

Tabel **_customers_** memiliki constraint unik pada nomor telepon, sehingga sistem dapat:

1. mencegah duplikasi data pelanggan
2. menjaga konsistensi identitas pelanggan

c. Alur Logika yang Dapat Ditelusuri

Logika aplikasi di dalam script Bash masih sederhana dan linear, sehingga:

1. mudah dibaca
2. mudah ditelusuri alur datanya
3. cocok untuk proses analisis awal

Bagi seorang Junior Technical Coordinator, kondisi ini justru ideal sebagai titik awal untuk melakukan evaluasi dan perencanaan perbaikan.

### 1.4 Alasan Dilakukannya Analisis Lanjutan
Meskipun sistem awal berfungsi, terdapat pertanyaan penting yang muncul jika sistem ini diasumsikan akan digunakan di lingkungan produksi, seperti:
1. Apakah format data yang digunakan sudah aman dari kesalahan input?
2. Apakah sistem mampu mencegah konflik jadwal?
3. Apakah arsitektur ini mudah dikembangkan oleh lebih dari satu developer?

Pertanyaan-pertanyaan inilah yang menjadi dasar dilakukannya analisis lebih lanjut pada bagian berikutnya.

### Bagian 1.5 — Identifikasi Inefisiensi & Risiko Arsitektur
### Ringkasan bagian identifikasi Inefisiensi & Risiko Arsitektur
| Area         | Risiko            | Dampak               |
| ------------ | ----------------- | -------------------- |
| Format Waktu | Tidak tervalidasi | Data tidak konsisten |
| Jadwal       | Double booking    | Konflik operasional  |
| Orkestrasi   | Bash-based logic  | Sulit dikembangkan   |

Pada tahap ini, sistem booking salon dianalisis bukan lagi sebagai tugas pembelajaran, tetapi sebagai sistem yang berpotensi digunakan di lingkungan nyata. Analisis difokuskan pada risiko yang dapat memengaruhi **integritas data**, **skalabilitas**, dan **kemudahan pengembangan**.

#### Temuan
Pada skema awal, kolom time pada tabel appointments menggunakan tipe data:
```
time VARCHAR(20)
```
#### Analisis
Penggunaan tipe data teks untuk menyimpan informasi waktu memiliki beberapa risiko:

1. Tidak ada validasi format waktu secara otomatis
2. Rentan terhadap kesalahan input pengguna (misalnya: 10.30, 11am, jam sepuluh)
3. Menyulitkan analisis berbasis waktu, seperti:
   
``
jam paling sibuk
``

``
pola booking harian
``

``
durasi antar appointment
``
#### Dampak
Dari sudut pandang integritas data, kondisi ini berisiko menyebabkan:

1. data tidak konsisten
2. kesulitan dalam analisis
3. potensi kesalahan laporan di tahap selanjutnya

#### Catatan Technical Coordinator:
Data yang tidak terstruktur dengan baik di awal akan meningkatkan beban koreksi di tahap pengembangan dan analisis.

### 1.5.2 Risiko Double Booking (Kesiapan Produksi)

#### Temuan
Skema awal belum memiliki mekanisme untuk mencegah:

1. dua appointment di waktu yang sama
2. konflik jadwal pada layanan atau stylist(pegawai)

Tidak terdapat tabel atau constraint yang mengatur ketersediaan waktu secara eksplisit.
#### Analisis
Pada tahap PoC, kondisi ini masih dapat diterima. Namun jika sistem digunakan di produksi:

1. Tidak ada jaminan bahwa satu slot waktu hanya bisa digunakan satu kali
2. Sistem tidak siap menangani peningkatan jumlah pelanggan
3. Potensi konflik jadwal meningkat seiring pertumbuhan data

#### Dampak

Risiko ini berdampak langsung pada:
1. kualitas layanan
2. kepercayaan pelanggan
3. stabilitas operasional sistem

#### Sudut pandang koordinasi teknis:
Masalah seperti ini sering kali tidak terlihat di awal, namun menjadi sumber error utama ketika sistem mulai digunakan oleh banyak pihak.

### 1.5.3 Inefisiensi Orkestrasi Teknis (Bash-based Flow)
## Temuan
Sistem awal menggunakan script Bash dengan eksekusi query PostgreSQL berulang melalui sub-shell:
```
$PSQL "QUERY"
```
#### Analisis

Pendekatan ini memiliki beberapa keterbatasan:

Sulit dipelihara jika logika bisnis bertambah kompleks

Validasi data terbatas

Tidak ideal untuk pengelolaan transaksi (transactional logic)

Kurang aman jika dikembangkan lebih lanjut

#### Dampak

Dalam konteks pengembangan jangka panjang:

alur sistem menjadi sulit dikontrol

koordinasi antar modul menjadi tidak jelas

risiko bug meningkat

#### Catatan Junior Technical Coordinator:
Script Bash cocok untuk automasi sederhana, namun bukan pilihan ideal untuk mengorkestrasi logika bisnis yang kompleks.

