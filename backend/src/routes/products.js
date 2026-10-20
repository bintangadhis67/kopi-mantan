const router = require('express').Router();
const db = require('../db');

const toProduct = (r) => ({
  id: r.id,
  name: r.name,
  category: r.category,
  price: r.price,
  desc: r.description,
  color: r.color,
  drink: r.is_drink,
  badge: r.badge,
});

// GET /products            -> semua menu (bukan merch)
// GET /products?category=Coffee -> menu per kategori
router.get('/', async (req, res, next) => {
  try {
    const { category } = req.query;
    const params = [];
    let sql = 'SELECT * FROM products WHERE is_merch = FALSE';
    if (category) {
      params.push(category);
      sql += ' AND category = $1';
    }
    sql += ' ORDER BY sort_order';
    const { rows } = await db.query(sql, params);
    res.json(rows.map(toProduct));
  } catch (e) { next(e); }
});

// GET /products/merch -> produk merchandise
router.get('/merch', async (req, res, next) => {
  try {
    const { rows } = await db.query('SELECT * FROM products WHERE is_merch = TRUE ORDER BY sort_order');
    res.json(rows.map(toProduct));
  } catch (e) { next(e); }
});

module.exports = router;