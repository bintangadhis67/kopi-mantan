
INSERT INTO vouchers (code, title, description, type, value, is_promo, claim_key) VALUES
  ('MANTAN10',    'Diskon 10%',            'Kode promo',            'pct',  10,   TRUE,  NULL),
  ('HEMAT5',      'Potongan Rp5.000',      'Kode promo',            'flat', 5000, TRUE,  NULL),
  ('B1G1MANTAN',  'Beli 1 Gratis 1',       'Kode promo',            'b1g1', 0,    TRUE,  NULL),
  ('ONGKIR',      'Diskon Ongkir Rp5.000', 'Kode promo',            'ship', 5000, TRUE,  NULL),
  ('OVO5',        'Diskon Rp5.000 OVO',    'Klaim Beranda',         'flat', 5000, FALSE, 'ovo5'),
  ('GEX5',        'Diskon Ongkir Rp5.000', 'Klaim Beranda',         'ship', 5000, FALSE, 'gex5'),
  ('BLU4',        'Diskon Rp4.000 blu',    'Klaim Beranda',         'flat', 4000, FALSE, 'blu4'),
  ('B1G1KLAIM',   'Beli 1 Gratis 1',       'Voucher klaim Beranda', 'b1g1', 0,    FALSE, 'b1g1home'),
  ('PACKB1G1',    'Voucher B1G1',          'Voucher Pack',          'b1g1', 0,    FALSE, NULL),
  ('PACK10',      'Diskon 10%',            'Voucher Pack',          'pct',  10,   FALSE, NULL),
  ('PACKONGKIR',  'Diskon Ongkir Rp5.000', 'Voucher Pack',          'ship', 5000, FALSE, NULL);


INSERT INTO user_vouchers (user_id, voucher_code, description)
SELECT id, 'MANTAN10', 'Voucher selamat datang' FROM users;