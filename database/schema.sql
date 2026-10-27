-- Schema database Sentuhan Kecil
-- MySQL 8.0+ / MariaDB 10.5+

CREATE DATABASE IF NOT EXISTS sentuhan_kecil_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sentuhan_kecil_db;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS schema_migrations (
  filename VARCHAR(190) NOT NULL,
  checksum CHAR(64) NOT NULL,
  applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (filename)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Baseline ini sudah memuat soft delete; cegah migration runner menambah
-- kolom yang sama ketika schema baru selesai diimpor.
INSERT INTO schema_migrations (filename, checksum)
VALUES ('022_soft_deletes.sql', 'dd432cda472507faeb3386cca8f38285e03d6f8b81385118018e109bfff2441d')
ON DUPLICATE KEY UPDATE checksum = VALUES(checksum);

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(30) NULL,
  role ENUM('customer', 'admin') NOT NULL DEFAULT 'customer',
  session_version INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  deleted_by INT UNSIGNED NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_role (role),
  KEY idx_users_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_password_reset_token (token_hash),
  KEY idx_password_reset_user (user_id),
  KEY idx_password_reset_expiry (expires_at),
  CONSTRAINT fk_password_reset_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_profiles (
  user_id INT UNSIGNED NOT NULL,
  child_name VARCHAR(120) NULL,
  child_birth_date DATE NULL,
  allergies TEXT NULL,
  care_notes TEXT NULL,
  default_address TEXT NULL,
  default_city VARCHAR(100) NULL,
  default_zip VARCHAR(20) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_customer_profiles_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS categories (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  slug VARCHAR(140) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  deleted_by INT UNSIGNED NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_name (name),
  UNIQUE KEY uq_categories_slug (slug),
  KEY idx_categories_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS products (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_id INT UNSIGNED NOT NULL,
  name VARCHAR(180) NOT NULL,
  slug VARCHAR(200) NOT NULL,
  description TEXT NULL,
  duration_minutes SMALLINT UNSIGNED NULL,
  price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  stock INT UNSIGNED NOT NULL DEFAULT 0,
  badge VARCHAR(80) NULL,
  image VARCHAR(500) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  deleted_by INT UNSIGNED NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_slug (slug),
  KEY idx_products_category_active (category_id, is_active),
  KEY idx_products_deleted_at (deleted_at),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id)
    REFERENCES categories (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_products_price CHECK (price >= 0),
  CONSTRAINT chk_products_stock CHECK (stock >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS carts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NULL,
  session_token CHAR(36) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_carts_user (user_id),
  UNIQUE KEY uq_carts_session (session_token),
  CONSTRAINT fk_carts_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_carts_owner CHECK (user_id IS NOT NULL OR session_token IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cart_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cart_id BIGINT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cart_items_product (cart_id, product_id),
  KEY idx_cart_items_product (product_id),
  CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id)
    REFERENCES carts (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id)
    REFERENCES products (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_cart_items_quantity CHECK (quantity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS favorites (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NULL,
  session_token CHAR(36) NULL,
  product_id INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_favorites_user (user_id, product_id),
  UNIQUE KEY uq_favorites_session (session_token, product_id),
  KEY idx_favorites_product (product_id),
  CONSTRAINT fk_favorites_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_favorites_product FOREIGN KEY (product_id)
    REFERENCES products (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_favorites_owner CHECK (user_id IS NOT NULL OR session_token IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_likes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NULL,
  session_token CHAR(36) NULL,
  product_id INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_service_likes_user (user_id, product_id),
  UNIQUE KEY uq_service_likes_session (session_token, product_id),
  KEY idx_service_likes_product (product_id),
  CONSTRAINT fk_service_likes_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_service_likes_product FOREIGN KEY (product_id)
    REFERENCES products (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_service_likes_owner CHECK (user_id IS NOT NULL OR session_token IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS therapists (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(30) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  deleted_by INT UNSIGNED NULL,
  PRIMARY KEY (id),
  KEY idx_therapists_active (is_active),
  KEY idx_therapists_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS coupons (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(40) NOT NULL,
  discount_type ENUM('percent', 'fixed') NOT NULL,
  discount_value DECIMAL(12,2) NOT NULL,
  minimum_order DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  usage_limit INT UNSIGNED NULL,
  used_count INT UNSIGNED NOT NULL DEFAULT 0,
  starts_at DATETIME NULL,
  ends_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  deleted_by INT UNSIGNED NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_coupons_code (code),
  KEY idx_coupons_active_dates (is_active, starts_at, ends_at),
  KEY idx_coupons_deleted_at (deleted_at),
  CONSTRAINT chk_coupons_value CHECK (discount_value > 0),
  CONSTRAINT chk_coupons_usage CHECK (usage_limit IS NULL OR used_count <= usage_limit)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_code VARCHAR(50) NOT NULL,
  user_id INT UNSIGNED NULL,
  guest_access_token_hash CHAR(64) NOT NULL,
  therapist_id INT UNSIGNED NULL,
  status ENUM('Menunggu pembayaran', 'Menunggu konfirmasi', 'Terkonfirmasi', 'Dalam pelayanan', 'Selesai', 'Dibatalkan') NOT NULL DEFAULT 'Menunggu pembayaran',
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  discount_code VARCHAR(40) NULL,
  discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  shipping_cost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  shipping_method VARCHAR(30) NOT NULL DEFAULT 'regular',
  payment_method ENUM('QRIS', 'Transfer Bank', 'Tunai') NOT NULL,
  payment_status ENUM('Menunggu pembayaran', 'Menunggu verifikasi', 'Dibayar', 'Gagal', 'Kedaluwarsa', 'Dibatalkan', 'Dikembalikan') NOT NULL DEFAULT 'Menunggu pembayaran',
  payment_gateway VARCHAR(40) NULL,
  payment_reference VARCHAR(100) NULL,
  gateway_transaction_id VARCHAR(150) NULL,
  qris_url VARCHAR(500) NULL,
  payment_due_at DATETIME NULL,
  payment_updated_at DATETIME NULL,
  payment_proof_url VARCHAR(500) NULL,
  payment_proof_uploaded_at DATETIME NULL,
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  service_duration_minutes SMALLINT UNSIGNED NOT NULL DEFAULT 60,
  service_location ENUM('studio', 'home') NOT NULL DEFAULT 'studio',
  appointment_status ENUM('Menunggu konfirmasi', 'Dikonfirmasi', 'Dalam pelayanan', 'Selesai', 'Dibatalkan') NOT NULL DEFAULT 'Menunggu konfirmasi',
  recipient_name VARCHAR(120) NOT NULL,
  patient_name VARCHAR(120) NOT NULL,
  recipient_email VARCHAR(160) NULL,
  recipient_phone VARCHAR(30) NOT NULL,
  shipping_address TEXT NOT NULL,
  shipping_city VARCHAR(100) NULL,
  shipping_zip VARCHAR(20) NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  deleted_by INT UNSIGNED NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_orders_code (order_code),
  UNIQUE KEY uq_orders_guest_token (guest_access_token_hash),
  KEY idx_orders_user_created (user_id, created_at),
  KEY idx_orders_schedule (appointment_date, appointment_time, therapist_id),
  KEY idx_orders_payment_expiry (payment_status, payment_due_at),
  KEY idx_orders_payment_reference (payment_reference),
  KEY idx_orders_deleted_at (deleted_at),
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_orders_therapist FOREIGN KEY (therapist_id)
    REFERENCES therapists (id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_orders_amounts CHECK (subtotal >= 0 AND discount_amount >= 0 AND shipping_cost >= 0 AND total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NULL,
  product_name VARCHAR(180) NOT NULL,
  product_image VARCHAR(500) NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  quantity INT UNSIGNED NOT NULL,
  line_total DECIMAL(12,2) GENERATED ALWAYS AS (unit_price * quantity) STORED,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_items_order (order_id),
  KEY idx_order_items_product (product_id),
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
    REFERENCES orders (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id)
    REFERENCES products (id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_order_items_values CHECK (unit_price >= 0 AND quantity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_reviews (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  comment TEXT NULL,
  is_published TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  deleted_by INT UNSIGNED NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_service_reviews_order (order_id),
  KEY idx_service_reviews_user (user_id),
  KEY idx_service_reviews_published (is_published, created_at),
  KEY idx_service_reviews_deleted_at (deleted_at),
  CONSTRAINT fk_service_reviews_order FOREIGN KEY (order_id)
    REFERENCES orders (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_service_reviews_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_service_reviews_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS order_change_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NULL,
  request_type ENUM('reschedule', 'cancel') NOT NULL,
  requested_date DATE NULL,
  requested_time TIME NULL,
  reason VARCHAR(500) NULL,
  status ENUM('Menunggu', 'Disetujui', 'Ditolak') NOT NULL DEFAULT 'Menunggu',
  reviewed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_change_requests_order (order_id, created_at),
  KEY idx_change_requests_status (status, created_at),
  CONSTRAINT fk_change_requests_order FOREIGN KEY (order_id)
    REFERENCES orders (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_change_requests_user FOREIGN KEY (user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS announcements (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kind ENUM('Berita', 'Pengumuman') NOT NULL,
  title VARCHAR(180) NOT NULL,
  excerpt VARCHAR(255) NULL,
  content TEXT NOT NULL,
  image VARCHAR(255) NULL,
  is_published TINYINT(1) NOT NULL DEFAULT 0,
  published_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  deleted_by INT UNSIGNED NULL,
  PRIMARY KEY (id),
  KEY idx_announcements_public (is_published, published_at),
  KEY idx_announcements_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS newsletter_subscribers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(160) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  deleted_by INT UNSIGNED NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_newsletter_email (email),
  KEY idx_newsletter_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS site_content (
  id TINYINT UNSIGNED NOT NULL,
  services_title VARCHAR(180) NULL,
  services_intro TEXT NULL,
  about_label VARCHAR(100) NULL,
  about_title VARCHAR(180) NULL,
  about_text TEXT NULL,
  about_image VARCHAR(500) NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS payment_settings (
  id TINYINT UNSIGNED NOT NULL,
  bank_name VARCHAR(100) NOT NULL,
  bank_account_number VARCHAR(80) NOT NULL,
  bank_account_holder VARCHAR(120) NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS booking_settings (
  id TINYINT UNSIGNED NOT NULL,
  open_time TIME NOT NULL DEFAULT '09:00:00',
  close_time TIME NOT NULL DEFAULT '17:00:00',
  slot_interval_minutes SMALLINT UNSIGNED NOT NULL DEFAULT 30,
  buffer_minutes SMALLINT UNSIGNED NOT NULL DEFAULT 15,
  advance_days SMALLINT UNSIGNED NOT NULL DEFAULT 30,
  operating_days VARCHAR(20) NOT NULL DEFAULT '1,2,3,4,5,6',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS admin_audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  actor_user_id INT UNSIGNED NOT NULL,
  action VARCHAR(160) NOT NULL,
  target_type VARCHAR(60) NULL,
  target_id VARCHAR(80) NULL,
  metadata JSON NULL,
  ip_address VARCHAR(64) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_admin_audit_actor (actor_user_id, created_at),
  KEY idx_admin_audit_action (action, created_at),
  CONSTRAINT fk_admin_audit_actor FOREIGN KEY (actor_user_id)
    REFERENCES users (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO payment_settings
  (id, bank_name, bank_account_number, bank_account_holder)
VALUES
  (1, 'Bank Mandiri', '9000050103739', 'HAFSAH QUROTUN AINI')
ON DUPLICATE KEY UPDATE id = VALUES(id);

INSERT INTO booking_settings
  (id, open_time, close_time, slot_interval_minutes, buffer_minutes, advance_days, operating_days)
VALUES
  (1, '09:00:00', '17:00:00', 30, 15, 30, '1,2,3,4,5,6')
ON DUPLICATE KEY UPDATE id = VALUES(id);

INSERT INTO therapists (name, phone, is_active)
SELECT 'Terapis Utama', NULL, 1
WHERE NOT EXISTS (SELECT 1 FROM therapists);

INSERT INTO categories (name, slug)
VALUES ('Pijat Bayi', 'pijat-bayi')
ON DUPLICATE KEY UPDATE name = VALUES(name);

SET @massage_category_id = (
  SELECT id FROM categories WHERE slug = 'pijat-bayi' LIMIT 1
);

INSERT INTO products
  (category_id, name, slug, description, duration_minutes, price, stock, badge, image, is_active)
VALUES
  (@massage_category_id, 'Baby Massage Relaksasi', 'baby-massage-relaksasi-30', 'Pijat lembut untuk membantu bayi rileks dan tidur lebih nyaman.', 30, 75000, 20, 'Pilihan populer', NULL, 1),
  (@massage_category_id, 'Baby Spa Sensory', 'baby-spa-sensory-45', 'Sesi spa ringan dan stimulasi sensorik yang menyenangkan untuk si kecil.', 45, 100000, 15, 'Favorit', NULL, 1),
  (@massage_category_id, 'Massage & Spa Lengkap', 'massage-spa-lengkap-60', 'Kombinasi massage dan spa untuk perawatan yang lebih lengkap.', 60, 135000, 12, 'Sesi lengkap', NULL, 1),
  (@massage_category_id, 'Pijat Kolik Bayi', 'pijat-kolik-bayi-30', 'Pijatan lembut pada area perut untuk membantu bayi merasa lebih nyaman.', 30, 85000, 10, 'Nyaman di perut', NULL, 1),
  (@massage_category_id, 'Pijat Tumbuh Kembang', 'pijat-tumbuh-kembang-45', 'Sesi sentuhan lembut yang disesuaikan untuk kebutuhan tumbuh kembang.', 45, 110000, 10, 'Pendampingan', NULL, 1),
  (@massage_category_id, 'Home Care Massage', 'home-care-massage-60', 'Layanan massage nyaman di rumah sesuai jadwal yang telah dikonfirmasi.', 60, 160000, 8, 'Kunjungan rumah', NULL, 1)
ON DUPLICATE KEY UPDATE slug = VALUES(slug);

SET FOREIGN_KEY_CHECKS = 1;
