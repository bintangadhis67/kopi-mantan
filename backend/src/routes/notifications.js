const router = require('express').Router();
const db = require('../db');
const auth = require('../middleware/auth');
const notify = require('../notify');

const toNotif = (r) => ({
  id: r.id,
  title: r.title,
  body: r.body,
  read: r.is_read,
  date: r.created_at,
});

router.use(auth); // semua endpoint notifikasi wajib login

// GET /notifications -> kotak masuk milik user (terbaru dulu)
router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      'SELECT * FROM notifications WHERE user_id = $1 ORDER BY id DESC LIMIT 100', [req.userId]);
    res.json(rows.map(toNotif));
  } catch (e) { next(e); }
});

// POST /notifications  { title, body } -> notifikasi untuk diri sendiri
// (dipakai fitur simulasi seperti "Permintaan catering" dan "Laporan masalah")
router.post('/', async (req, res, next) => {
  try {
    const title = String(req.body.title || '').trim().slice(0, 150);
    const body = String(req.body.body || '').trim().slice(0, 1000);
    if (!title) return res.status(400).json({ message: 'Judul notifikasi wajib diisi' });
    await notify(db, req.userId, title, body);
    res.status(201).json({ message: 'Notifikasi dibuat' });
  } catch (e) { next(e); }
});

// PUT /notifications/read-all -> tandai semua sudah dibaca
router.put('/read-all', async (req, res, next) => {
  try {
    await db.query('UPDATE notifications SET is_read = TRUE WHERE user_id = $1', [req.userId]);
    res.json({ message: 'Semua notifikasi dibaca' });
  } catch (e) { next(e); }
});

// PUT /notifications/:id/read -> tandai satu notifikasi sudah dibaca
router.put('/:id/read', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id < 1) return res.status(400).json({ message: 'ID tidak valid' });
    const { rowCount } = await db.query(
      'UPDATE notifications SET is_read = TRUE WHERE id = $1 AND user_id = $2', [id, req.userId]);
    if (!rowCount) return res.status(404).json({ message: 'Notifikasi tidak ditemukan' });
    res.json({ message: 'Notifikasi dibaca' });
  } catch (e) { next(e); }
});

module.exports = router;