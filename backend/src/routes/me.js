const router = require('express').Router();
const bcrypt = require('bcrypt');
const db = require('../db');
const auth = require('../middleware/auth');

const toUser = (r) => ({
  id: r.id,
  name: r.name,
  email: r.email || '',
  emailVerified: r.email_verified,
  phone: r.phone ? '0' + r.phone : '',
  gender: r.gender,
  birth: r.birth ? new Date(r.birth).toISOString().slice(0, 10) : null,
  city: r.city,
  googleLinked: r.google_linked,
  hasPin: !!r.pin_hash,
  points: r.points,
  spend: Number(r.spend),
});

// Normalisasi nomor: "0812.." / "62812.." / "812.." -> "812.."
const normPhone = (p = '') => {
  let n = String(p).replace(/\D/g, '');
  if (n.startsWith('0')) n = n.slice(1);
  if (n.startsWith('62')) n = n.slice(2);
  return n;
};

const isEmail = (e) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e);

router.use(auth);

router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query('SELECT * FROM users WHERE id = $1', [req.userId]);
    if (!rows.length) return res.status(404).json({ message: 'User tidak ditemukan' });
    res.json(toUser(rows[0]));
  } catch (e) { next(e); }
});

router.put('/', async (req, res, next) => {
  try {
    const { name, gender, birth, city } = req.body;

    if (name !== undefined && !String(name).trim())
      return res.status(400).json({ message: 'Nama tidak boleh kosong' });

    // Email: undefined/null/kosong = tidak diubah
    let email = null;
    if (req.body.email !== undefined && req.body.email !== null && String(req.body.email).trim() !== '') {
      email = String(req.body.email).trim().toLowerCase();
      if (!isEmail(email))
        return res.status(400).json({ message: 'Format email tidak valid' });
    }

    // Nomor HP: undefined/null/kosong = tidak diubah
    let phone = null;
    if (req.body.phone !== undefined && req.body.phone !== null && String(req.body.phone).trim() !== '') {
      phone = normPhone(req.body.phone);
      if (phone.length < 8)
        return res.status(400).json({ message: 'Nomor handphone tidak valid' });
    }

    const { rows } = await db.query(
      `UPDATE users SET
         name           = COALESCE($1, name),
         email_verified = CASE
                            WHEN $2::text IS NOT NULL AND $2::text IS DISTINCT FROM email THEN TRUE
                            ELSE email_verified
                          END,
         email          = COALESCE($2::text, email),
         phone          = COALESCE($3::text, phone),
         gender         = COALESCE($4, gender),
         birth          = COALESCE($5::date, birth),
         city           = COALESCE($6, city)
       WHERE id = $7 RETURNING *`,
      [name ?? null, email, phone, gender ?? null, birth ?? null, city ?? null, req.userId]);

    res.json(toUser(rows[0]));
  } catch (e) {
    // 23505 = unique_violation (nomor HP sudah dipakai akun lain)
    if (e.code === '23505')
      return res.status(409).json({ message: 'Nomor handphone sudah dipakai akun lain' });
    next(e);
  }
});

router.put('/pin', async (req, res, next) => {
  try {
    const pin = String(req.body.pin || '');
    if (!/^\d{6}$/.test(pin)) return res.status(400).json({ message: 'PIN harus 6 digit angka' });
    await db.query('UPDATE users SET pin_hash = $1 WHERE id = $2', [await bcrypt.hash(pin, 10), req.userId]);
    res.json({ message: 'PIN berhasil diganti' });
  } catch (e) { next(e); }
});

router.delete('/', async (req, res, next) => {
  try {
    await db.query('DELETE FROM users WHERE id = $1', [req.userId]);
    res.json({ message: 'Akun dihapus' });
  } catch (e) { next(e); }
});

module.exports = router;
module.exports.toUser = toUser;