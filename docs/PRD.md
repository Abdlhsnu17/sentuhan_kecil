# Product Requirements Document — Sentuhan Kecil

| Informasi | Nilai |
| --- | --- |
| Produk | Sentuhan Kecil |
| Jenis | Web commerce dan booking baby massage/baby spa |
| Versi | 2.0 |
| Status | Baseline implementasi codebase |
| Audiens | Product owner, engineering, QA, operations, dan bisnis |

## 1. Ringkasan eksekutif

Sentuhan Kecil adalah platform untuk menemukan, memesan, membayar, dan mengelola layanan baby massage serta baby spa. Produk menggabungkan storefront pelanggan dan dashboard operasional admin.

Pelanggan dapat booking tanpa akun, memilih slot berdasarkan ketersediaan terapis, menggunakan voucher, membayar, memantau order, serta mengajukan perubahan jadwal. Admin mengelola katalog, pelanggan, terapis, jadwal, pembayaran, konten, promosi, laporan, dan audit aktivitas.

Dokumen ini mencatat perilaku produk yang didukung codebase saat ini sekaligus menjadi baseline pengembangan berikutnya.

## 2. Latar belakang

Operasional layanan perawatan bayi yang bergantung pada chat dan pencatatan manual menimbulkan masalah berikut:

- informasi paket, harga, dan durasi tidak terpusat;
- pelanggan perlu menanyakan slot berulang kali;
- booking berisiko bertabrakan;
- status pembayaran dan bukti transfer sulit dilacak;
- perubahan jadwal tidak memiliki alur persetujuan konsisten;
- histori pelanggan, transaksi, dan tindakan admin tersebar;
- laporan penjualan membutuhkan rekap manual.

Sentuhan Kecil menjadi sumber data terpusat agar pengalaman pelanggan lebih sederhana dan operasi bisnis lebih terukur.

## 3. Visi dan sasaran

### Visi

Menjadi kanal digital utama Sentuhan Kecil untuk menyediakan proses booking perawatan bayi yang aman, nyaman, transparan, dan mudah dikelola dari pemilihan layanan hingga sesi selesai.

### Sasaran bisnis

1. Meningkatkan konversi pengunjung menjadi booking.
2. Mengurangi pekerjaan manual dalam pengecekan slot dan pencatatan order.
3. Menghindari konflik jadwal melalui alokasi terapis otomatis.
4. Mempercepat verifikasi pembayaran dan konfirmasi layanan.
5. Menjaga konsistensi data katalog, pelanggan, dan transaksi.
6. Menyediakan laporan pendapatan dan layanan populer.
7. Meningkatkan retensi melalui profil, favorit, ulasan, voucher, dan newsletter.

## 4. Metrik keberhasilan

### Bisnis

- conversion rate katalog ke checkout;
- jumlah booking mingguan dan bulanan;
- paid-order rate;
- gross sales, net sales, dan average order value;
- penggunaan voucher;
- repeat-customer rate;
- perbandingan booking studio dan home care.

### Operasional

- waktu rata-rata verifikasi pembayaran;
- waktu penyelesaian change request;
- okupansi per terapis;
- persentase order kedaluwarsa;
- keberhasilan webhook pembayaran;
- jumlah konflik booking yang lolos, dengan target 0.

### Kualitas

- tingkat error API checkout;
- persentase automated test yang lulus;
- p95 response time katalog dan availability;
- insiden akses order tidak sah, dengan target 0;
- keberhasilan backup dan restore.

## 5. Ruang lingkup

### Termasuk

- katalog, pencarian, filter, detail, like, favorit, dan keranjang;
- akun, profil pelanggan, dan reset password;
- guest checkout dan pemulihan akses order;
- booking berbasis slot dan multi-terapis;
- layanan studio serta home care;
- voucher persen atau nominal;
- QRIS Midtrans, QRIS statis, transfer, dan tunai;
- upload/verifikasi bukti pembayaran;
- lifecycle order dan riwayat transaksi;
- perubahan metode pembayaran sebelum diproses;
- reschedule dan pembatalan dengan approval admin;
- ulasan dan moderasi;
- manajemen katalog, user, terapis, jadwal, konten, dan pengumuman;
- newsletter, laporan penjualan, invoice, dan audit log;
- email reset password dan notifikasi order.

### Belum termasuk

- aplikasi native;
- marketplace multi-merchant atau multi-tenant;
- loyalty points dan subscription;
- payroll/komisi terapis;
- refund otomatis;
- WhatsApp Business API otomatis;
- sinkronisasi kalender eksternal;
- multi-cabang dan zona waktu per cabang.

## 6. Persona

### Pengunjung/tamu

Orang tua yang ingin melihat layanan dan booking cepat tanpa registrasi. Membutuhkan harga jelas, slot valid, checkout singkat, dan akses order yang dapat dipulihkan.

### Pelanggan terdaftar

Pelanggan yang ingin menyimpan profil anak, alamat, histori, favorit, dan ulasan dalam satu akun.

### Admin operasional

Staf yang memproses order, pembayaran, jadwal, pelanggan, dan konten harian. Membutuhkan dashboard ringkas, status konsisten, dan jejak tindakan.

### Pemilik bisnis

Pengambil keputusan yang membutuhkan visibilitas pendapatan, produk terlaris, pembayaran, voucher, dan performa operasional.

## 7. Prinsip produk

1. Booking harus dapat selesai tanpa akun.
2. Harga dan ketersediaan sah selalu berasal dari server.
3. Status memakai bahasa yang mudah dipahami pelanggan.
4. Tindakan berisiko harus tervalidasi dan dapat diaudit.
5. Gangguan layanan eksternal tidak boleh merusak konsistensi order.
6. Pengalaman mobile menjadi prioritas.
7. Data anak dan kontak pelanggan diperlakukan sebagai data sensitif.

## 8. User journey utama

### Discovery sampai checkout

1. Pelanggan membuka katalog dan memilih layanan.
2. Layanan dimasukkan ke keranjang.
3. Sistem menghitung total durasi dan menampilkan slot tersedia.
4. Pelanggan memilih lokasi, jadwal, metode pembayaran, data pasien, dan alamat.
5. Server memvalidasi ulang harga, stok, voucher, slot, dan terapis dalam transaksi.
6. Order dibuat, stok dikurangi, terapis ditetapkan, dan keranjang dikosongkan.
7. Pelanggan menerima kode order, token akses, tenggat, dan instruksi pembayaran.

### QRIS dinamis

1. Server membuat transaksi Midtrans dan menyimpan referensi gateway.
2. Pelanggan memindai QR.
3. Midtrans mengirim webhook.
4. Server memverifikasi signature dan nominal.
5. Status pembayaran diperbarui tanpa mengizinkan status lunas mundur.

### Transfer/QRIS statis

1. Pelanggan mengikuti instruksi dan mengunggah bukti.
2. Status menjadi `Menunggu verifikasi`.
3. Admin memverifikasi dan menetapkan hasil pembayaran.

### Pemulihan order tamu

1. Pelanggan memasukkan kode order dan nomor WhatsApp.
2. Sistem menormalisasi input dan mencocokkan data dengan rate limiting.
3. Jika cocok, sistem menerbitkan token terbatas pada order tersebut.

### Reschedule/pembatalan

1. Pelanggan mengajukan tipe perubahan dan alasan.
2. Reschedule divalidasi terhadap availability baru.
3. Hanya satu permintaan pending diperbolehkan per order.
4. Admin menyetujui atau menolak.
5. Persetujuan memperbarui jadwal atau membatalkan order dan memulihkan resource terkait.

## 9. Functional requirements

### FR-01 — Katalog

- Publik hanya melihat layanan aktif.
- Layanan memiliki kategori, nama, slug, deskripsi, durasi, harga, stok, badge, gambar, dan status.
- Mendukung pencarian, filter kategori, sorting, dan detail.
- Admin dapat membuat, memperbarui, menonaktifkan, dan menghapus layanan sesuai integritas data.
- Slug unik; harga dan stok tidak negatif.
- Checkout memakai nilai database, bukan payload browser.

### FR-02 — Like, favorit, dan newsletter

- Tamu dikenali dengan session token, user login dengan user ID.
- Like dan favorit bersifat toggle dan unik per owner-produk.
- Data sesi yang relevan dapat digabung saat login.
- Newsletter menerima email unik dan admin dapat melihat/menghapus subscriber.

### FR-03 — Keranjang

- Tersedia untuk tamu dan user login.
- Mendukung tambah, ubah jumlah, dan hapus item.
- Jumlah wajib positif dan tidak melebihi stok.
- Produk nonaktif tidak dapat di-checkout.
- Keranjang tamu digabung ke akun saat login.
- Keranjang dikosongkan hanya setelah order berhasil.

### FR-04 — Autentikasi dan user

- Mendukung registrasi, login, logout, sesi aktif, ubah password, dan reset password.
- Email unik dan dinormalisasi; password memakai bcrypt.
- Reset token sekali pakai dengan masa berlaku 30 menit.
- Perubahan password menaikkan session version untuk membatalkan sesi lama.
- Login, registrasi, reset, dan lookup order memiliki rate limit.
- Admin dapat mengelola user, role, dan password.
- Sistem harus mencegah admin terakhir terhapus atau kehilangan role tanpa pengganti.

### FR-05 — Profil pelanggan

- Satu user memiliki maksimal satu profil.
- Profil menyimpan nama anak, tanggal lahir, alergi, catatan, alamat, kota, dan kode pos.
- Data profil dapat menjadi default checkout.

### FR-06 — Jadwal dan terapis

- Admin mengatur jam buka/tutup, interval slot, buffer, batas hari pemesanan, dan hari operasional.
- Durasi booking adalah jumlah seluruh durasi item dikali kuantitas.
- Slot tersedia jika minimal satu terapis aktif bebas overlap termasuk buffer.
- Waktu lampau dan di luar rentang booking tidak ditawarkan.
- Terapis tersedia ditetapkan otomatis.
- Booking dibatalkan tidak memblokir slot.
- Validasi akhir menggunakan transaction lock untuk mengurangi race condition.
- Admin dapat mengelola terapis, tetapi minimal satu harus tetap aktif.

### FR-07 — Checkout

- Tamu dan user login dapat checkout.
- Nama orang tua, nama pasien, WhatsApp, alamat, tanggal, waktu, lokasi, dan pembayaran wajib.
- Email opsional tetapi harus valid bila diisi.
- Lokasi: `studio` atau `home`.
- Home care tidak menerima tunai.
- Server menghitung subtotal, diskon, biaya, dan total.
- Setiap order memperoleh kode unik dan guest access token.
- Order item menyimpan snapshot nama, gambar, harga, dan jumlah.

### FR-08 — Voucher

- Tipe voucher: `percent` dan `fixed`.
- Mendukung minimum order, kuota, periode, dan status aktif.
- Kode unik dan dinormalisasi uppercase.
- Diskon maksimal sebesar subtotal.
- Penggunaan bertambah saat checkout sukses dan dikembalikan ketika pembatalan memenuhi aturan.
- Admin dapat mengelola voucher tanpa merusak histori order.

### FR-09 — Pembayaran

- Metode: QRIS, transfer bank, dan tunai.
- QRIS memakai Midtrans bila server key tersedia atau gambar statis sebagai fallback.
- QRIS dan transfer memiliki tenggat.
- QRIS dapat diganti ke transfer dan sebaliknya hanya saat `Menunggu pembayaran`.
- Penggantian metode membuat tenggat/instruksi baru dan membersihkan bukti lama.
- Bukti hanya diterima untuk transfer dan QRIS statis.
- Webhook memverifikasi signature serta gross amount.
- Status `Dibayar` tidak boleh turun karena notifikasi lama.
- Order kedaluwarsa melepas stok, slot, dan konsumsi voucher.

### FR-10 — Lifecycle order

Status order:

- `Menunggu pembayaran`
- `Menunggu konfirmasi`
- `Terkonfirmasi`
- `Dalam pelayanan`
- `Selesai`
- `Dibatalkan`

Status pembayaran:

- `Menunggu pembayaran`
- `Menunggu verifikasi`
- `Dibayar`
- `Gagal`
- `Kedaluwarsa`
- `Dibatalkan`
- `Dikembalikan`

Status appointment:

- `Menunggu konfirmasi`
- `Dikonfirmasi`
- `Dalam pelayanan`
- `Selesai`
- `Dibatalkan`

Aturan transisi:

- status final tidak kembali ke status aktif;
- pembayaran dan appointment dapat mendorong status order otomatis;
- penyelesaian order mensyaratkan pembayaran dan appointment sesuai aturan;
- order aktif dibatalkan sebelum penghapusan permanen;
- pembatalan tidak boleh menggandakan pemulihan stok/voucher.

### FR-11 — Otorisasi dan riwayat order

- User hanya melihat order miliknya.
- Tamu hanya melihat order dengan access token valid.
- Recovery token hanya memberi akses ke order dalam claim.
- Jumlah token dalam satu request dibatasi.
- Database hanya menyimpan hash token acak.

### FR-12 — Change request

- Tipe permintaan: `reschedule` dan `cancel`.
- Order final tidak dapat diubah.
- Hanya satu request `Menunggu` per order.
- Jadwal baru harus valid, di masa depan, dan tersedia.
- Admin dapat menyetujui/menolak; keputusan tercatat beserta waktu review.

### FR-13 — Ulasan

- Hanya user login pemilik order selesai yang dapat memberi ulasan.
- Satu order memiliki maksimal satu ulasan.
- Rating 1–5.
- Admin dapat publish/unpublish ulasan.

### FR-14 — Konten publik

- Admin dapat mengatur judul/intro layanan dan bagian tentang.
- Announcement berupa berita atau pengumuman dengan judul, excerpt, isi, gambar, publish flag, dan tanggal.
- Publik hanya melihat announcement terbit.

### FR-15 — Dashboard admin

- Menampilkan total user/admin, produk, produk nonaktif, stok rendah, order, pending order, pending payment, revenue, dan subscriber.
- Admin dapat mengelola order, pembayaran, appointment, produk, kategori, user, role, password, ulasan, voucher, terapis, jadwal, konten, dan announcement.
- Semua endpoint admin memerlukan role admin.
- Mutasi admin yang berhasil masuk audit log.

### FR-16 — Laporan dan invoice

- Laporan menerima periode tanggal valid.
- Memuat ringkasan transaksi dan item terjual sesuai endpoint.
- Dashboard mendukung export invoice/rekap yang tersedia di frontend.
- Nilai spreadsheet berawalan formula harus dinetralisasi.

### FR-17 — Upload

- Admin dapat upload gambar katalog/konten.
- Pelanggan dapat upload bukti pembayaran.
- Server memvalidasi jenis dan ukuran file.
- File yang gagal dipakai harus dibersihkan.
- URL publik berada di `/uploads/`.

### FR-18 — Email

- Sistem mengirim reset password dan notifikasi transaksi penting.
- Gangguan email setelah commit tidak membatalkan transaksi.
- Production tanpa SMTP harus menghasilkan kegagalan aman untuk fitur yang wajib mengirim email.

### FR-19 — Audit

- Mutasi admin mencatat actor, action, target, metadata aman, IP, dan waktu.
- Password/secret tidak masuk metadata.
- Log dapat dibaca dengan pagination dan tidak diedit melalui API biasa.

## 10. Aturan bisnis

| ID | Aturan |
| --- | --- |
| BR-01 | Harga, stok, diskon, dan total final dihitung server. |
| BR-02 | Satu terapis tidak boleh memiliki sesi overlap termasuk buffer. |
| BR-03 | Home care hanya menerima QRIS atau transfer. |
| BR-04 | Bukti transfer tidak otomatis menandai pembayaran lunas. |
| BR-05 | Order belum dibayar yang melewati tenggat dibatalkan otomatis. |
| BR-06 | Pembatalan melepas stok, slot, dan voucher tepat satu kali. |
| BR-07 | Pembayaran lunas tidak boleh mundur karena webhook lama. |
| BR-08 | Hanya pemilik order selesai yang dapat memberi ulasan. |
| BR-09 | Hanya satu change request pending per order. |
| BR-10 | Token order mentah tidak disimpan di database. |
| BR-11 | Order item mempertahankan snapshot transaksi. |
| BR-12 | Admin terakhir harus dilindungi dari penghapusan/demotion. |

## 11. Data model

### Identity

`users`, `customer_profiles`, `password_reset_tokens`

### Catalog dan engagement

`categories`, `products`, `service_likes`, `favorites`, `newsletter_subscribers`

### Commerce dan booking

`carts`, `cart_items`, `orders`, `order_items`, `coupons`, `therapists`, `booking_settings`, `order_change_requests`, `service_reviews`

### Content dan operations

`announcements`, `site_content`, `payment_settings`, `admin_audit_logs`, `schema_migrations`

Prinsip data:

- transaksi menggunakan InnoDB dan `utf8mb4`;
- foreign key menjaga relasi;
- lookup utama memiliki indeks;
- histori transaksi memakai snapshot;
- secret token disimpan sebagai hash.

## 12. API dan trust boundary

- **Publik:** katalog, kategori, pengumuman, konten, voucher, health check.
- **Customer authenticated:** profil, password, dan ulasan dengan scope user.
- **Guest/session commerce:** cart, favorite, checkout, order, pembayaran, dan change request.
- **Admin:** manajemen dan reporting dengan role admin serta audit.
- **Gateway:** webhook tanpa sesi browser, diverifikasi melalui signature.

## 13. Non-functional requirements

### Keamanan

- JWT secret minimal 32 karakter di production.
- Cookie HTTP-only, secure pada HTTPS, dan SameSite sesuai arsitektur.
- Request mutasi browser dilindungi CSRF; webhook memakai signature.
- Query input memakai parameter binding.
- Endpoint sensitif memiliki rate limit.
- Upload memverifikasi tipe dan ukuran.
- Error tidak membocorkan stack, credential, atau query sensitif.
- Data anak, alamat, nomor telepon, dan email hanya diakses sesuai kewenangan.

### Konsistensi dan reliabilitas

- Checkout, stok, voucher, item, dan cart berada dalam satu transaksi.
- Pembatalan idempotent secara bisnis.
- Transaction lock digunakan pada pemilihan slot.
- Kegagalan email tidak menggagalkan transaksi tersimpan.
- Readiness check memeriksa database.

### Kinerja

- Target p95 katalog < 500 ms pada beban normal.
- Target p95 availability < 750 ms.
- Target p95 checkout < 2 detik di luar latensi gateway.
- Daftar berukuran besar menggunakan pagination.
- Kolom lookup dan foreign key utama diindeks.

### Usability dan accessibility

- Alur utama responsif pada mobile.
- Form memiliki label, error state, dan pesan jelas.
- Interaksi utama dapat menggunakan keyboard.
- Kontras mengikuti WCAG AA sejauh praktis.
- Rupiah, tanggal, dan waktu konsisten dengan locale Indonesia.

### Compatibility dan operations

- Mendukung browser evergreen, Node.js 20+, MySQL 8+/MariaDB 10.5+.
- Reverse proxy meneruskan protokol dan IP secara benar.
- `/health` untuk liveness dan `/ready` untuk readiness.
- Database serta `public/uploads` dibackup dan diuji restore.

## 14. State transition

### Pembayaran

```text
Menunggu pembayaran
├── bukti diunggah ──> Menunggu verifikasi
├── gateway sukses ──> Dibayar
├── tenggat lewat ──> Kedaluwarsa
├── gateway gagal ──> Gagal
└── order dibatalkan ──> Dibatalkan

Menunggu verifikasi
├── admin menerima ──> Dibayar
└── admin menolak ──> Gagal/Dibatalkan

Dibayar ──> Dikembalikan (proses administratif)
```

### Appointment

```text
Menunggu konfirmasi
├── admin konfirmasi ──> Dikonfirmasi
└── pembatalan ──> Dibatalkan

Dikonfirmasi ──> Dalam pelayanan ──> Selesai
```

## 15. Error dan empty states

Produk harus memberi pesan aman dan actionable untuk:

- produk nonaktif/stok habis;
- cart kosong;
- voucher invalid, belum aktif, habis, atau minimum order tidak tercapai;
- slot diambil transaksi lain;
- tidak ada terapis aktif;
- metode pembayaran tidak cocok dengan lokasi;
- QRIS/SMTP belum dikonfigurasi;
- bukti pembayaran tidak valid;
- token order salah;
- order final tidak dapat diubah;
- database/gateway tidak tersedia.

## 16. Analytics rekomendasi

Event berikut direkomendasikan untuk tahap analytics:

- `catalog_viewed`, `service_viewed`, `service_added_to_cart`;
- `checkout_started`, `availability_checked`, `coupon_applied`;
- `order_created`, `payment_method_changed`, `payment_proof_uploaded`;
- `payment_confirmed`, `order_completed`;
- `change_request_created`, `review_submitted`.

Event tidak boleh membawa data kesehatan anak, alamat lengkap, token, atau credential.

## 17. Acceptance criteria rilis

Rilis production diterima bila:

1. Dependency terinstal pada Node.js yang didukung.
2. `db/schema.sql` dapat diimpor pada database kosong.
3. Admin awal dapat dibuat.
4. Guest checkout berhasil dari cart hingga order.
5. Sistem mencegah overlap terapis.
6. Pembayaran gateway atau fallback manual bekerja sesuai konfigurasi.
7. Upload bukti hanya menghasilkan `Menunggu verifikasi`.
8. Admin dapat menyelesaikan lifecycle order.
9. Recovery order hanya berhasil dengan data benar.
10. Mutasi admin tercatat di audit log.
11. Test kritikal lulus.
12. `/health` dan `/ready` benar.
13. Tidak ada secret di repository.
14. Backup dan restore telah diuji.

## 18. Risiko dan mitigasi

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Checkout bersamaan memilih slot sama | Double booking | Transaction lock dan validasi ulang |
| Webhook berulang/tidak berurutan | Status salah | Signature, validasi nominal, guard status lunas |
| Token order hilang | Pelanggan kehilangan akses | Lookup kode + WhatsApp dengan rate limit |
| Bukti pembayaran palsu | Kerugian | Manual verification oleh admin |
| SMTP gagal | Notifikasi terlambat | Tidak membatalkan transaksi; monitoring/retry roadmap |
| Storage upload penuh | Downtime | Batas file, cleanup, monitoring, retention |
| Kesalahan admin | Gangguan operasional | Validasi, final-state guard, audit log |
| Kebocoran database | Paparan data | Least privilege, backup aman, pembatasan akses |

## 19. Roadmap

### Fase 1 — Hardening

- selaraskan migration baseline dengan `db/schema.sql`;
- CI untuk lint, test, dan validasi schema;
- structured logging dan error monitoring;
- scheduled job untuk expiry order;
- prosedur backup, restore, dan retention data.

### Fase 2 — Customer experience

- WhatsApp Business notification;
- repeat booking;
- reminder otomatis;
- halaman detail terapis;
- retry email dan notification center.

### Fase 3 — Business intelligence

- okupansi terapis;
- cohort dan repeat rate;
- performa voucher;
- rekonsiliasi gateway;
- laporan terjadwal dan perbandingan periode.

### Fase 4 — Scale

- multi-cabang;
- zona dan biaya home care;
- permission admin granular;
- calendar integration;
- queue untuk email, webhook, dan background jobs.

## 20. Open questions

- Apakah stok merupakan kapasitas layanan atau inventori aktual?
- Bagaimana refund untuk pembatalan setelah pembayaran?
- Berapa batas waktu reschedule sebelum sesi?
- Apakah home care membutuhkan ongkos berdasarkan jarak?
- Berapa lama data pelanggan, bukti bayar, dan audit disimpan?
- Apakah satu order boleh memiliki beberapa pasien?
- Apakah diperlukan role finance, therapist, dan content editor?

## 21. Definition of done

Fitur dianggap selesai bila:

- requirement dan acceptance criteria disepakati;
- validasi server dan otorisasi tersedia;
- schema/migration diperbarui bila perlu;
- error state serta empty state ditangani;
- test relevan ditambah/diperbarui;
- README/API diperbarui;
- tidak ada secret atau data sensitif dalam log/repository;
- langkah operasional admin terdokumentasi.

## 22. Persetujuan dokumen

Dokumen ini menjadi baseline produk Sentuhan Kecil berdasarkan codebase saat ini. Perubahan scope, pembayaran, lifecycle order, atau model akses pelanggan harus dicatat sebagai revisi PRD dan disertai pembaruan test serta dokumentasi teknis.
