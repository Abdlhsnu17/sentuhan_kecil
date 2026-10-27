# Sentuhan Kecil

Sentuhan Kecil adalah aplikasi web untuk katalog, pemesanan, pembayaran, dan pengelolaan layanan baby massage serta baby spa. Aplikasi ini menyediakan guest checkout, penjadwalan multi-terapis, pembayaran QRIS/transfer, dan dashboard operasional admin.

## Fitur

### Pelanggan

- Katalog, pencarian, filter kategori, detail, like, dan favorit layanan.
- Keranjang untuk tamu maupun pengguna terdaftar.
- Checkout tanpa wajib membuat akun.
- Pilihan sesi studio atau home care dengan slot real-time.
- Voucher persen atau nominal tetap.
- QRIS Midtrans, QRIS statis, transfer bank, dan tunai sesuai aturan layanan.
- Upload bukti pembayaran dan pemantauan status order.
- Penggantian metode pembayaran QRIS/transfer sebelum pembayaran diproses.
- Pemulihan akses order memakai kode order dan nomor WhatsApp.
- Permintaan reschedule atau pembatalan.
- Profil anak, alergi, catatan perawatan, dan alamat default.
- Ulasan setelah layanan selesai.

### Admin

- Statistik operasional serta pengelolaan order dan pembayaran.
- Pengelolaan kategori, layanan, stok, harga, gambar, dan konten situs.
- Pengelolaan user, role, voucher, ulasan, dan pengumuman.
- Pengelolaan terapis, jam kerja, hari operasional, slot, dan buffer sesi.
- Persetujuan reschedule dan pembatalan.
- Subscriber newsletter, laporan penjualan, invoice, dan audit log.

## Stack

- Node.js 20+ dan Express 4
- MySQL 8+ atau MariaDB 10.5+
- JavaScript, HTML, dan CSS
- JWT dalam cookie HTTP-only
- bcryptjs, mysql2, Multer, Nodemailer
- Midtrans Core API untuk QRIS dinamis

## Struktur proyek

```text
E-Comerce-Massage-main/
├── db/
│   └── schema.sql
├── docker/
├── docs/
│   └── PRD.md
├── public/
│   ├── assets/
│   ├── css/
│   ├── js/
│   ├── uploads/
│   ├── dashboard.html
│   └── index.html
├── server/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── routes/
│   ├── scripts/
│   ├── services/
│   ├── app.js
│   └── server.js
├── test/
├── package.json
└── README.md
```

## Instalasi

### 1. Instal dependency

```bash
npm install
```

### 2. Buat `.env`

```env
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000

DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASS=
DB_NAME=sentuhan_kecil_db

JWT_SECRET=ganti_dengan_string_acak_minimal_32_karakter
JWT_EXPIRES_IN=7d

BOOTSTRAP_ADMIN_EMAIL=admin@example.com
BOOTSTRAP_ADMIN_NAME=Administrator Sentuhan Kecil
BOOTSTRAP_ADMIN_PASSWORD=ganti_dengan_password_yang_kuat

SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=
SMTP_PASS=
MAIL_FROM="Sentuhan Kecil <no-reply@example.com>"

BANK_NAME=Bank Mandiri
BANK_ACCOUNT_NUMBER=9000050103739
BANK_ACCOUNT_HOLDER="HAFSAH QUROTUN AINI"

QRIS_IMAGE_URL=
MIDTRANS_SERVER_KEY=
MIDTRANS_IS_PRODUCTION=false
MIDTRANS_QRIS_ACQUIRER=gopay
QRIS_PAYMENT_MINUTES=30
TRANSFER_PAYMENT_HOURS=24
```

`DB_PASS` adalah nama variabel utama. `DB_PASSWORD` masih didukung untuk konfigurasi lama.

### 3. Impor database

Schema membuat database `sentuhan_kecil_db`, tabel, indeks, relasi, pengaturan awal, satu terapis awal, dan katalog awal.

```bash
mysql -u root -p < db/schema.sql
```

### 4. Buat admin pertama

```bash
npm run admin:create
```

### 5. Jalankan aplikasi

```bash
npm run dev
```

Untuk mode biasa:

```bash
npm start
```

Buka `http://localhost:3000`. Jangan membuka file HTML secara langsung karena frontend membutuhkan API, cookie sesi, dan middleware Express.

## Perintah npm

| Perintah | Fungsi |
| --- | --- |
| `npm start` | Menjalankan server |
| `npm run dev` | Menjalankan server dalam watch mode |
| `npm test` | Menjalankan automated test |
| `npm run admin:create` | Membuat admin awal dari environment |
| `npm run db:seed:services` | Mengisi katalog awal tanpa menimpa perubahan admin |
| `npm run db:migrate` | Menjalankan migration runner jika folder migrasi tersedia |

## Alur booking

1. Pelanggan memasukkan layanan ke keranjang.
2. Server membaca ulang harga, stok, durasi, dan voucher dari database.
3. Sistem memeriksa jam operasional dan konflik jadwal semua terapis aktif.
4. Terapis yang tersedia ditetapkan otomatis.
5. Order, item, stok, voucher, dan keranjang diproses dalam transaksi database.
6. QRIS berlaku 30 menit dan transfer bank 24 jam secara default.
7. Order yang melewati tenggat dibatalkan; stok dan slot dilepas kembali.
8. Admin memproses pembayaran dan sesi hingga order selesai.

Pembayaran tunai hanya tersedia untuk sesi studio. Home care wajib memakai QRIS atau transfer bank.

## Guest checkout

Pelanggan tidak wajib login. Setelah checkout, server menghasilkan token akses acak dan hanya menyimpan hash SHA-256-nya di database. Jika data browser hilang, akses dapat dipulihkan melalui kode order dan nomor WhatsApp. Endpoint pemulihan dilindungi rate limit.

## Pembayaran

### QRIS Midtrans

Isi `MIDTRANS_SERVER_KEY` untuk membuat QRIS dinamis. Atur Payment Notification URL di Midtrans menjadi:

```text
https://domain-anda.example/api/payments/midtrans/notification
```

Notifikasi diverifikasi menggunakan signature dan nominal transaksi. Status pembayaran tidak ditentukan oleh browser pelanggan.

### QRIS statis dan transfer

Jika Midtrans tidak digunakan, isi `QRIS_IMAGE_URL`. Untuk QRIS statis dan transfer, pelanggan mengunggah bukti dan status berubah menjadi `Menunggu verifikasi`. Hanya admin yang dapat menandainya sebagai dibayar.

## Email

SMTP digunakan untuk reset password dan notifikasi perubahan penting pada order. Gangguan email setelah transaksi tersimpan tidak membatalkan order. Pada development tanpa SMTP, tautan reset dapat ditampilkan di terminal; production harus memakai SMTP.

## API utama

### Publik dan autentikasi

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| `GET` | `/health` | Liveness check |
| `GET` | `/ready` | Readiness check termasuk database |
| `GET` | `/api/products` | Layanan aktif |
| `GET` | `/api/products/:id` | Detail layanan |
| `POST` | `/api/products/:id/like` | Toggle like |
| `GET` | `/api/categories` | Kategori |
| `GET` | `/api/announcements` | Pengumuman publik |
| `GET` | `/api/coupons` | Voucher tersedia |
| `POST` | `/api/auth/register` | Registrasi |
| `POST` | `/api/auth/login` | Login |
| `POST` | `/api/auth/logout` | Logout |
| `GET` | `/api/auth/me` | User aktif |
| `PATCH` | `/api/auth/password` | Ubah password |
| `GET/PUT` | `/api/auth/profile` | Profil pelanggan |
| `POST` | `/api/auth/password-reset` | Meminta reset password |
| `POST` | `/api/auth/password-reset/confirm` | Menetapkan password baru |

### Commerce

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| `GET` | `/api/cart` | Isi keranjang |
| `POST` | `/api/cart/items` | Tambah item |
| `PATCH/DELETE` | `/api/cart/items/:productId` | Ubah/hapus item |
| `GET/POST` | `/api/favorites[/:productId]` | Daftar/toggle favorit |
| `GET` | `/api/appointments/availability` | Slot tersedia |
| `POST` | `/api/orders` | Membuat order |
| `GET` | `/api/orders` | Riwayat order yang dapat diakses |
| `POST` | `/api/orders/lookup` | Memulihkan akses order |
| `POST` | `/api/orders/:id/payment-method` | Mengganti metode pembayaran |
| `POST` | `/api/orders/:id/payment-proof` | Upload bukti pembayaran |
| `POST` | `/api/orders/:id/payment/refresh` | Sinkronisasi QRIS |
| `POST` | `/api/orders/:id/change-request` | Reschedule/pembatalan |
| `POST` | `/api/orders/:orderId/review` | Membuat ulasan |
| `POST` | `/api/newsletter` | Berlangganan newsletter |

Seluruh endpoint `/api/admin/*` memerlukan role `admin`. Cakupannya meliputi order, kategori, produk, user, ulasan, voucher, terapis, jadwal, konten, pengumuman, newsletter, laporan, upload, dan audit log.

## Keamanan

- Password di-hash dengan bcrypt.
- JWT dikirim melalui cookie HTTP-only.
- Request mutasi browser dilindungi CSRF.
- Endpoint sensitif memakai rate limit.
- Ubah password menaikkan `session_version` dan membatalkan sesi lama.
- Query memakai parameter binding.
- Token reset dan token order disimpan dalam bentuk hash.
- Webhook pembayaran diverifikasi dengan signature gateway.
- Perubahan admin direkam dalam audit log tanpa password.

## Upload dan backup

Upload disimpan di `public/uploads/`. Pada production, folder tersebut harus writable oleh proses Node.js dan disimpan pada volume persisten. Backup harus mencakup database serta folder upload, dan prosedur restore perlu diuji berkala.

## Pengujian

```bash
npm test
```

Test mencakup booking, pembayaran, voucher, audit, akses order, upload, CSRF, invoice, laporan, dan health check.

## Checklist production

- Gunakan `NODE_ENV=production` dan `JWT_SECRET` acak.
- Pasang HTTPS melalui reverse proxy; jangan mengekspos port Node langsung.
- Konfigurasikan `TRUST_PROXY`, SMTP, `APP_URL`, serta credential Midtrans.
- Gunakan user database dengan hak minimum.
- Pastikan `public/uploads` persisten dan ikut backup.
- Pantau `/health` dan `/ready`.
- Lakukan test checkout, webhook, email, backup, dan restore sebelum go-live.

## Troubleshooting

- Database gagal: cek `DB_*`, pastikan MySQL aktif, lalu impor `db/schema.sql`.
- QRIS tidak muncul: isi `MIDTRANS_SERVER_KEY` atau `QRIS_IMAGE_URL`.
- Email gagal: periksa host, port, secure mode, kredensial, dan `MAIL_FROM`.
- API tidak terjangkau: akses frontend melalui server Express, bukan Live Server.

## Dokumentasi produk

PRD lengkap tersedia di [docs/PRD.md](docs/PRD.md).

## Lisensi

Proyek ini ditujukan untuk kebutuhan internal Sentuhan Kecil. Penggunaan dan distribusi mengikuti persetujuan pemilik proyek.
