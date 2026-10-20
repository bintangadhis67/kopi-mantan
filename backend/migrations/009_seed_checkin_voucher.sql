
INSERT INTO vouchers (code, title, description, type, value, is_promo, claim_key) VALUES
  ('CHECKIN10', 'Diskon 10%', 'Hadiah check-in', 'pct', 10, FALSE, NULL);

INSERT INTO notifications (user_id, title, body)
SELECT id, 'Purple Cloud Series', 'Beli 2 diskon 25% untuk semua varian Purple Cloud.' FROM users;

INSERT INTO notifications (user_id, title, body)
SELECT id, 'Selamat datang di Kopi Mantan', 'Nikmati promo Beli 1 Gratis 1 setiap hari hanya di aplikasi.' FROM users;