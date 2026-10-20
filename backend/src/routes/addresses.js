const router = require('express').Router();
const db = require('../db');
const auth = require('../middleware/auth');

const toAddr = (r) => ({ id: r.id, label: r.label, detail: r.detail });

// Validasi isian label & detail
function readBody(body) {
  const label = String(body.label || '').trim();
  const detail = String(body.detail || '').trim();
  if (!label || !detail) return { error: 'Label dan alamat lengkap wajib diisi' };
  if (label.length > 50) return { error: 'Label maksimal 50 karakter' };
  return { label, detail };
}

const validId = (v) => Number.isInteger(Number(v)) && Number(v) > 0;

router.use(auth); // semua endpoint alamat wajib login

// GET /addresses -> daftar alamat milik user
router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      'SELECT * FROM addresses WHERE user_id = $1 ORDER BY id', [req.userId]);
    res.json(rows.map(toAddr));
  } catch (e) { next(e); }
});

// POST /addresses  { label, detail }
router.post('/', async (req, res, next) => {
  try {
    const b = readBody(req.body);
    if (b.error) return res.status(400).json({ message: b.error });
    const { rows } = await db.query(
      'INSERT INTO addresses (user_id, label, detail) VALUES ($1, $2, $3) RETURNING *',
      [req.userId, b.label, b.detail]);
    res.status(201).json(toAddr(rows[0]));
  } catch (e) { next(e); }
});

// PUT /addresses/:id  { label, detail }
router.put('/:id', async (req, res, next) => {
  try {
    if (!validId(req.params.id)) return res.status(400).json({ message: 'ID tidak valid' });
    const b = readBody(req.body);
    if (b.error) return res.status(400).json({ message: b.error });
    const { rows } = await db.query(
      'UPDATE addresses SET label = $1, detail = $2 WHERE id = $3 AND user_id = $4 RETURNING *',
      [b.label, b.detail, req.params.id, req.userId]);
    if (!rows.length) return res.status(404).json({ message: 'Alamat tidak ditemukan' });
    res.json(toAddr(rows[0]));
  } catch (e) { next(e); }
});

// DELETE /addresses/:id
router.delete('/:id', async (req, res, next) => {
  try {
    if (!validId(req.params.id)) return res.status(400).json({ message: 'ID tidak valid' });
    const { rowCount } = await db.query(
      'DELETE FROM addresses WHERE id = $1 AND user_id = $2', [req.params.id, req.userId]);
    if (!rowCount) return res.status(404).json({ message: 'Alamat tidak ditemukan' });
    res.json({ message: 'Alamat dihapus' });
  } catch (e) { next(e); }
});

module.exports = router;