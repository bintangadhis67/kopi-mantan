const router = require('express').Router();
const db = require('../db');
const auth = require('../middleware/auth');
const notify = require('../notify');

const MODES = ['Pickup', 'Dine-In', 'Delivery'];
const SIZES = ['Regular', 'Large'];
const LARGE_FEE = 4000; // tambahan harga ukuran Large (khusus minuman)
const BAG_FEE = 4000;   // kantung belanja
const SHIP_FEE = 8000;  // ongkir Delivery

const fmtId = (id) => `KM-${1000 + id}`;

// Error yang membawa kode HTTP
function fail(status, message) {
  const e = new Error(message);
  e.status = status;
  return e;
}

const text = (v, max, def = '') => String(v ?? def).trim().slice(0, max);

// Hitung potongan harga barang dari voucher (sama persis dengan hitungan di aplikasi)
function itemDiscount(v, units, subtotal) {
  switch (v.type) {
    case 'pct':
      return Math.floor((subtotal * v.value) / 100);
    case 'flat':
      return Math.min(v.value, subtotal);
    case 'b1g1':
      return units.length >= 2 ? units[0] : 0;
    case 'free':
      return units[0];
    default:
      return 0; // 'ship' tidak memotong harga barang
  }
}

function toOrder(o, items) {
  return {
    id: fmtId(o.id),
    date: o.created_at,
    mode: o.mode,
    outlet: o.place,
    payment: o.payment,
    status: o.status,
    subtotal: o.subtotal,
    discount: o.discount,
    shipFee: o.ship_fee,
    shipDiscount: o.ship_discount,
    bagFee: o.bag_fee,
    total: o.total,
    pointsEarned: o.points_earned,
    items: items.map((i) => ({
      productId: i.product_id,
      name: i.product_name,
      size: i.size,
      ice: i.ice,
      sugar: i.sugar,
      note: i.note,
      qty: i.qty,
      unit: i.unit_price,
    })),
  };
}

router.use(auth); // semua endpoint pesanan wajib login

// GET /orders -> riwayat pesanan milik user (terbaru dulu)
router.get('/', async (req, res, next) => {
  try {
    const { rows: orders } = await db.query(
      'SELECT * FROM orders WHERE user_id = $1 ORDER BY id DESC LIMIT 100', [req.userId]);
    if (!orders.length) return res.json([]);
    const ids = orders.map((o) => o.id);
    const marks = ids.map((_, i) => `$${i + 1}`).join(',');
    const { rows: items } = await db.query(
      `SELECT * FROM order_items WHERE order_id IN (${marks}) ORDER BY id`, ids);
    res.json(orders.map((o) => toOrder(o, items.filter((i) => i.order_id === o.id))));
  } catch (e) { next(e); }
});

// POST /orders -> buat pesanan. Harga dihitung ulang di server, bukan dari aplikasi.
router.post('/', async (req, res, next) => {
  const b = req.body;

  // --- validasi isian ---
  if (!MODES.includes(b.mode)) return res.status(400).json({ message: 'Mode pesanan tidak valid' });
  const place = text(b.place, 200);
  if (!place) return res.status(400).json({ message: 'Outlet atau alamat wajib diisi' });
  const payment = text(b.payment, 50);
  if (!payment) return res.status(400).json({ message: 'Metode pembayaran wajib diisi' });
  if (!Array.isArray(b.items) || b.items.length === 0)
    return res.status(400).json({ message: 'Keranjang kosong' });
  if (b.items.length > 50) return res.status(400).json({ message: 'Terlalu banyak item' });

  const lines = [];
  for (const it of b.items) {
    const qty = Number(it.qty);
    const size = text(it.size, 20, 'Regular');
    if (!it.productId || !Number.isInteger(qty) || qty < 1 || qty > 99)
      return res.status(400).json({ message: 'Item pesanan tidak valid' });
    if (!SIZES.includes(size)) return res.status(400).json({ message: 'Ukuran tidak valid' });
    lines.push({
      productId: String(it.productId),
      qty,
      size,
      ice: text(it.ice, 30),
      sugar: text(it.sugar, 30),
      note: text(it.note, 200),
    });
  }

  const isDelivery = b.mode === 'Delivery';
  const client = await db.connect();
  try {
    await client.query('BEGIN');

    // --- harga produk diambil dari database ---
    const pids = [...new Set(lines.map((l) => l.productId))];
    const marks = pids.map((_, i) => `$${i + 1}`).join(',');
    const prod = await client.query(
      `SELECT id, name, price, is_drink FROM products WHERE id IN (${marks})`, pids);
    const byId = new Map(prod.rows.map((p) => [p.id, p]));

    const units = []; // harga satuan per cangkir/porsi (untuk voucher b1g1/free)
    let subtotal = 0;
    for (const l of lines) {
      const p = byId.get(l.productId);
      if (!p) throw fail(400, 'Produk tidak ditemukan');
      l.name = p.name;
      l.unit = p.price + (p.is_drink && l.size === 'Large' ? LARGE_FEE : 0);
      subtotal += l.unit * l.qty;
      for (let i = 0; i < l.qty; i++) units.push(l.unit);
    }
    units.sort((a, c) => a - c);

    // --- voucher ---
    let voucher = null;
    let userVoucherId = null;
    if (b.voucherId) {
      const r = await client.query(
        `SELECT uv.id AS uv_id, v.* FROM user_vouchers uv
         JOIN vouchers v ON v.code = uv.voucher_code
         WHERE uv.id = $1 AND uv.user_id = $2 AND uv.used = FALSE`, [b.voucherId, req.userId]);
      if (!r.rows.length) throw fail(400, 'Voucher tidak valid atau sudah dipakai');
      voucher = r.rows[0];
      userVoucherId = voucher.uv_id;
    } else if (b.voucherCode) {
      const r = await client.query(
        'SELECT * FROM vouchers WHERE code = $1 AND is_promo = TRUE',
        [text(b.voucherCode, 30).toUpperCase()]);
      if (!r.rows.length) throw fail(400, 'Kode voucher tidak valid');
      voucher = r.rows[0];
    }
    if (voucher) {
      if (voucher.type === 'ship' && !isDelivery)
        throw fail(400, 'Voucher ongkir hanya untuk Delivery');
      if (voucher.type === 'b1g1' && units.length < 2)
        throw fail(400, 'Voucher ini butuh minimal 2 produk');
    }

    // --- total ---
    const shipFee = isDelivery ? SHIP_FEE : 0;
    const bagFee = b.bag ? BAG_FEE : 0;
    const discount = voucher ? itemDiscount(voucher, units, subtotal) : 0;
    const shipDiscount = voucher && voucher.type === 'ship' ? Math.min(voucher.value, shipFee) : 0;
    const total = Math.max(0, subtotal - discount + bagFee + shipFee - shipDiscount);
    const pointsEarned = Math.floor(total / 1000);

    // --- simpan pesanan ---
    const ins = await client.query(
      `INSERT INTO orders (user_id, mode, place, address_detail, payment, subtotal, discount,
                           ship_fee, ship_discount, bag_fee, total, points_earned, voucher_code)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) RETURNING *`,
      [req.userId, b.mode, place, isDelivery ? text(b.addressDetail, 1000) || null : null, payment,
       subtotal, discount, shipFee, shipDiscount, bagFee, total, pointsEarned,
       voucher ? voucher.code : null]);
    const order = ins.rows[0];

    for (const l of lines) {
      await client.query(
        `INSERT INTO order_items (order_id, product_id, product_name, size, ice, sugar, note, qty, unit_price)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
        [order.id, l.productId, l.name, l.size, l.ice, l.sugar, l.note, l.qty, l.unit]);
    }

    // --- poin & total belanja ---
    const u = await client.query(
      'UPDATE users SET points = points + $1, spend = spend + $2 WHERE id = $3 RETURNING points, spend',
      [pointsEarned, total, req.userId]);

    // --- voucher milik user dihabiskan (hanya berhasil bila belum terpakai) ---
    if (userVoucherId) {
      const used = await client.query(
        'UPDATE user_vouchers SET used = TRUE WHERE id = $1 AND user_id = $2 AND used = FALSE RETURNING id',
        [userVoucherId, req.userId]);
      if (!used.rows.length) throw fail(409, 'Voucher sudah dipakai');
    }

    await notify(client, req.userId, `Pesanan ${fmtId(order.id)} berhasil`,
      `Terima kasih! Kamu mendapat ${pointsEarned} Mantan Points.`);

    await client.query('COMMIT');
    res.status(201).json({
      ...toOrder(order, lines.map((l) => ({
        product_id: l.productId, product_name: l.name, size: l.size, ice: l.ice,
        sugar: l.sugar, note: l.note, qty: l.qty, unit_price: l.unit,
      }))),
      points: u.rows[0].points,
      spend: Number(u.rows[0].spend),
    });
  } catch (e) {
    await client.query('ROLLBACK');
    if (e.status) return res.status(e.status).json({ message: e.message });
    next(e);
  } finally {
    client.release();
  }
});

module.exports = router;