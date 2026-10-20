const router = require('express').Router();
const jwt = require('jsonwebtoken');
const db = require('../db');
const { toUser } = require('./me');
const notify = require('../notify');

const DEMO_OTP = '1234';
// Voucher sambutan untuk akun baru
async function grantWelcome(userId) {
  await db.query(
    `INSERT INTO user_vouchers (user_id, voucher_code, description)
     VALUES ($1, 'MANTAN10', 'Voucher selamat datang')`, [userId]);
  await notify(db, userId, 'Purple Cloud Series', 'Beli 2 diskon 25% untuk semua varian Purple Cloud.');
  await notify(db, userId, 'Selamat datang di Kopi Mantan', 'Nikmati promo Beli 1 Gratis 1 setiap hari hanya di aplikasi.');
}

const sign = (id) => jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });

// Normalisasi nomor: "0812.." / "62812.." / "812.." -> "812.."
const normPhone = (p = '') => {
  let n = String(p).replace(/\D/g, '');
  if (n.startsWith('0')) n = n.slice(1);
  if (n.startsWith('62')) n = n.slice(2);
  return n;
};

// POST /auth/otp/request  { phone }
router.post('/otp/request', (req, res) => {
  const phone = normPhone(req.body.phone);
  if (phone.length < 8) return res.status(400).json({ message: 'Nomor handphone tidak valid' });
  // Mode demo: OTP selalu 1234 (tidak ada SMS sungguhan)
  res.json({ message: 'OTP terkirim (mode demo: 1234)' });
});

// POST /auth/otp/verify  { phone, otp }
router.post('/otp/verify', async (req, res, next) => {
  try {
    const phone = normPhone(req.body.phone);
    if (phone.length < 8) return res.status(400).json({ message: 'Nomor handphone tidak valid' });
    if (String(req.body.otp) !== DEMO_OTP) return res.status(400).json({ message: 'Kode OTP salah' });

    let { rows } = await db.query('SELECT * FROM users WHERE phone = $1', [phone]);
    let isNew = false;
    if (!rows.length) {
      ({ rows } = await db.query(
        `INSERT INTO users (phone, provider) VALUES ($1, 'phone') RETURNING *`, [phone]));
      isNew = true;
    }
    if (isNew) await grantWelcome(rows[0].id);
    res.json({ token: sign(rows[0].id), isNew, user: toUser(rows[0]) });
  } catch (e) { next(e); }
});

// POST /auth/social  { provider: whatsapp | apple | google }
// Login simulasi (tanpa OAuth sungguhan) untuk tombol WA / Apple / Google di aplikasi.
router.post('/social', async (req, res, next) => {
  try {
    const provider = String(req.body.provider || '').toLowerCase();
    const names = { whatsapp: 'Pengguna Mantan', apple: 'Pengguna Apple', google: 'Pengguna Google' };
    if (!names[provider]) return res.status(400).json({ message: 'Provider tidak dikenal' });

    let { rows } = await db.query(
      'SELECT * FROM users WHERE provider = $1 AND phone IS NULL', [provider]);
    let isNew = false;
    if (!rows.length) {
      ({ rows } = await db.query(
        `INSERT INTO users (name, provider, google_linked) VALUES ($1, $2, $3) RETURNING *`,
        [names[provider], provider, provider === 'google']));
      isNew = true;
    }
    if (isNew) await grantWelcome(rows[0].id);
    res.json({ token: sign(rows[0].id), isNew, user: toUser(rows[0]) });
  } catch (e) { next(e); }
});

module.exports = router;