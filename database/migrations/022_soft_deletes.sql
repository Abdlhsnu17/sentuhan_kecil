-- Soft delete untuk data bisnis dan historis.
-- deleted_by tidak memakai foreign key agar jejak actor tetap tersimpan
-- walaupun akun admin tersebut kemudian ikut diarsipkan.

ALTER TABLE users
  ADD COLUMN deleted_at DATETIME NULL AFTER updated_at,
  ADD COLUMN deleted_by INT UNSIGNED NULL AFTER deleted_at,
  ADD KEY idx_users_deleted_at (deleted_at);

ALTER TABLE categories
  ADD COLUMN deleted_at DATETIME NULL,
  ADD COLUMN deleted_by INT UNSIGNED NULL AFTER deleted_at,
  ADD KEY idx_categories_deleted_at (deleted_at);

ALTER TABLE products
  ADD COLUMN deleted_at DATETIME NULL AFTER updated_at,
  ADD COLUMN deleted_by INT UNSIGNED NULL AFTER deleted_at,
  ADD KEY idx_products_deleted_at (deleted_at);

ALTER TABLE therapists
  ADD COLUMN deleted_at DATETIME NULL AFTER updated_at,
  ADD COLUMN deleted_by INT UNSIGNED NULL AFTER deleted_at,
  ADD KEY idx_therapists_deleted_at (deleted_at);

ALTER TABLE coupons
  ADD COLUMN deleted_at DATETIME NULL,
  ADD COLUMN deleted_by INT UNSIGNED NULL AFTER deleted_at,
  ADD KEY idx_coupons_deleted_at (deleted_at);

ALTER TABLE orders
  ADD COLUMN deleted_at DATETIME NULL AFTER updated_at,
  ADD COLUMN deleted_by INT UNSIGNED NULL AFTER deleted_at,
  ADD KEY idx_orders_deleted_at (deleted_at);

ALTER TABLE service_reviews
  ADD COLUMN deleted_at DATETIME NULL,
  ADD COLUMN deleted_by INT UNSIGNED NULL AFTER deleted_at,
  ADD KEY idx_service_reviews_deleted_at (deleted_at);

ALTER TABLE announcements
  ADD COLUMN deleted_at DATETIME NULL AFTER updated_at,
  ADD COLUMN deleted_by INT UNSIGNED NULL AFTER deleted_at,
  ADD KEY idx_announcements_deleted_at (deleted_at);

ALTER TABLE newsletter_subscribers
  ADD COLUMN deleted_at DATETIME NULL AFTER created_at,
  ADD COLUMN deleted_by INT UNSIGNED NULL AFTER deleted_at,
  ADD KEY idx_newsletter_deleted_at (deleted_at);
