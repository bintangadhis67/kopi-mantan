require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());
app.use((req, res, next) => {
  req.body = req.body || {};
  next();
});

app.get('/health', (_, res) => res.json({ ok: true, app: 'Kopi Mantan API' }));

app.use('/auth', require('./routes/auth'));
app.use('/me', require('./routes/me'));
app.use('/products', require('./routes/products'));
app.use('/outlets', require('./routes/outlets'));
app.use('/addresses', require('./routes/addresses'));
app.use('/vouchers', require('./routes/vouchers'));
app.use('/orders', require('./routes/orders'));
app.use('/notifications', require('./routes/notifications'));
app.use('/checkin', require('./routes/checkin'));

app.use((req, res) => res.status(404).json({ message: 'Endpoint tidak ditemukan' }));
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ message: 'Terjadi kesalahan pada server' });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`API Kopi Mantan jalan di http://localhost:${port}`));