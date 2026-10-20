const router = require('express').Router();
const db = require('../db');
const auth = require('../middleware/auth');
const notify = require('../notify');

// Hadiah per hari dalam siklus 7 hari
const REWARDS = ['+25', '+25', 'Voucher', '+25', '+25', 'Voucher', '+50'];

// Tanggal hari ini (zona waktu server) dalam format YYYY-MM-DD
function todayStr() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
}

router.use(auth); // wajib login

// GET /checkin -> jumlah check-in dan apakah hari ini sudah check-in
router.get('/', async (req, res, next) => {
  try {
    const total = await db.query('SELECT COUNT(*) AS n FROM checkins WHERE user_id = $1', [req.userId]);
    const today = await db.query(
      'SELECT 1 FROM checkins WHERE user_id = $1 AND checkin_date = $2::date', [req.userId, todayStr()]);
    res.json({ checkedDays: Number(total.rows[0].n), checkedToday: today.rows.length > 0 });
  } catch (e) { next(e); }
});

// POST /checkin -> check-in hari ini (sekali per hari) dan terima hadiah
router.post('/', async (req, res, next) => {
  const client = await db.connect();
  try {
    await client.query('BEGIN');

    const total = await client.query('SELECT COUNT(*) AS n FROM checkins WHERE user_id = $1', [req.userId]);
    const count = Number(total.rows[0].n);

    const day = todayStr();
    const today = await client.query(
      'SELECT 1 FROM checkins WHERE user_id = $1 AND checkin_date = $2::date', [req.userId, day]);
    if (today.rows.length) {
      await client.query('ROLLBACK');
      return res.status(409).json({ message: 'Kamu sudah check-in hari ini' });
    }

    const dayNo = count + 1;
    const reward = REWARDS[count % 7];
    await client.query(
      'INSERT INTO checkins (user_id, day_no, reward, checkin_date) VALUES ($1, $2, $3, $4::date)',
      [req.userId, dayNo, reward, day]);

    let points;
    if (reward === 'Voucher') {
      await client.query(
        `INSERT INTO user_vouchers (user_id, voucher_code, description) VALUES ($1, 'CHECKIN10', $2)`,
        [req.userId, `Hadiah check-in hari ke-${dayNo}`]);
      const u = await client.query('SELECT points FROM users WHERE id = $1', [req.userId]);
      points = u.rows[0].points;
    } else {
      const u = await client.query(
        'UPDATE users SET points = points + $1 WHERE id = $2 RETURNING points',
        [Number(reward.replace('+', '')), req.userId]);
      points = u.rows[0].points;
    }

    await notify(client, req.userId, 'Check-in berhasil',
      reward === 'Voucher'
        ? `Hadiah hari ke-${dayNo}: voucher Diskon 10% masuk ke akunmu.`
        : `Hadiah hari ke-${dayNo}: ${reward} Mantan Points.`);

    await client.query('COMMIT');
    res.status(201).json({ day: dayNo, reward, checkedDays: dayNo, points });
  } catch (e) {
    await client.query('ROLLBACK');
    if (e.code === '23505') return res.status(409).json({ message: 'Kamu sudah check-in hari ini' });
    next(e);
  } finally {
    client.release();
  }
});

module.exports = router;