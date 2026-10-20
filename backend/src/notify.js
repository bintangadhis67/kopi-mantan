// Membuat satu notifikasi untuk user.
// executor = pool (db) atau client transaksi.
module.exports = function notify(executor, userId, title, body) {
  return executor.query(
    'INSERT INTO notifications (user_id, title, body) VALUES ($1, $2, $3)',
    [userId, title, body]);
};