const router = require('express').Router();
const jwt = require('jsonwebtoken');
const db = require('../db');
const auth = require('../middleware/auth');
const notify = require('../notify');

// Voucher Pack yang dijual di halaman VIP: harga -> nama paket
const PACKS = {
  9000: 'Langganan Voucher Rp9.000',
  24000: 'Langganan Voucher Rp24.000',
};

const SELECT_OWNED = `
  SELECT uv.id, uv.claim_key, v.code, v.title, v.type, v.value,
         COALESCE(uv.description, v.description) AS description
  FROM user_vouchers uv
  JOIN vouchers v ON v.code = uv.voucher_code`;

const toVoucher = (r) => ({
  id: r.id ?? null,
  code: r.code,
  title: r.title,
  desc: r.description,
  type: r.type,
  value: r.value,
});

// Baca user dari token bila ada (untuk endpoint yang boleh diakses tamu)
function optionalUserId(req) {
  const h = req.headers.authorization || '';
  if (!h.startsWith('Bearer ')) return null;
  try {
    return jwt.verify(h.slice(7), process.env.JWT_SECRET).id;
  } catch {
    return null;
  }
}

// GET /vouchers -> voucher yang belum dipakai + daftar kunci klaim yang pernah diambil
router.get('/', auth, async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `${SELECT_OWNED} WHERE uv.user_id = $1 AND uv.used = FALSE ORDER BY uv.id`, [req.userId]);
    const keys = await db.query(
      'SELECT claim_key FROM user_vouchers WHERE user_id = $1 AND claim_key IS NOT NULL', [req.userId]);
    res.json({ vouchers: rows.map(toVoucher), claimedKeys: keys.rows.map((r) => r.claim_key) });
  } catch (e) { next(e); }
});

// POST /vouchers/claim  { key }  -> klaim voucher dari Beranda (sekali per akun)
router.post('/claim', auth, async (req, res, next) => {
  try {
    const key = String(req.body.key || '').trim();
    const v = await db.query('SELECT * FROM vouchers WHERE claim_key = $1', [key]);
    if (!v.rows.length) return res.status(404).json({ message: 'Voucher tidak ditemukan' });

    const dup = await db.query(
      'SELECT 1 FROM user_vouchers WHERE user_id = $1 AND claim_key = $2', [req.userId, key]);
    if (dup.rows.length) return res.status(409).json({ message: 'Voucher sudah pernah diklaim' });

    try {
      await db.query(
        'INSERT INTO user_vouchers (user_id, voucher_code, claim_key) VALUES ($1, $2, $3)',
        [req.userId, v.rows[0].code, key]);
    } catch (e) {
      if (e.code === '23505') return res.status(409).json({ message: 'Voucher sudah pernah diklaim' });
      throw e;
    }
    await notify(db, req.userId, 'Voucher diklaim', `${v.rows[0].title} berhasil masuk ke akunmu.`);
    res.status(201).json({ message: 'Voucher berhasil diklaim', title: v.rows[0].title });
  } catch (e) { next(e); }
});

// POST /vouchers/validate  { code } -> cek kode voucher (milik user atau kode promo umum)
router.post('/validate', async (req, res, next) => {
  try {
    const code = String(req.body.code || '').trim().toUpperCase();
    if (!code) return res.status(400).json({ message: 'Kode voucher wajib diisi' });

    const userId = optionalUserId(req);
    if (userId) {
      const owned = await db.query(
        `${SELECT_OWNED} WHERE uv.user_id = $1 AND uv.voucher_code = $2 AND uv.used = FALSE
         ORDER BY uv.id LIMIT 1`, [userId, code]);
      if (owned.rows.length) return res.json(toVoucher(owned.rows[0]));
    }
    const promo = await db.query('SELECT * FROM vouchers WHERE code = $1 AND is_promo = TRUE', [code]);
    if (!promo.rows.length) return res.status(404).json({ message: 'Kode voucher tidak valid' });
    res.json(toVoucher(promo.rows[0]));
  } catch (e) { next(e); }
});

// POST /vouchers/buy-pack  { price } -> beli Voucher Pack (pembayaran disimulasikan)
router.post('/buy-pack', auth, async (req, res, next) => {
  try {
    const title = PACKS[Number(req.body.price)];
    if (!title) return res.status(400).json({ message: 'Paket tidak dikenal' });
    const desc = `Dari ${title}`;
    // 1x B1G1 + 3x Diskon 10% + 1x Diskon Ongkir, dimasukkan sekaligus dalam satu perintah
    await db.query(
      `INSERT INTO user_vouchers (user_id, voucher_code, description) VALUES
         ($1, 'PACKB1G1', $2), ($1, 'PACK10', $2), ($1, 'PACK10', $2),
         ($1, 'PACK10', $2), ($1, 'PACKONGKIR', $2)`, [req.userId, desc]);
    await notify(db, req.userId, 'Voucher Pack dibeli', `${title} aktif. Cek voucher di halaman checkout.`);
    res.status(201).json({ message: 'Voucher Pack berhasil dibeli', title });
  } catch (e) { next(e); }
});

module.exports = router;