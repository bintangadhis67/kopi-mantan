const router = require('express').Router();
const db = require('../db');

// GET /outlets -> daftar outlet
router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query('SELECT * FROM outlets ORDER BY sort_order');
    res.json(rows.map((r) => ({
      id: r.id,
      name: r.name,
      address: r.address,
      distance: r.distance,
      hours: r.hours,
      delivery: r.delivery,
      pickup: r.pickup,
      drive: r.drive,
    })));
  } catch (e) { next(e); }
});

module.exports = router;