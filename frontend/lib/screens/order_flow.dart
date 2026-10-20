import 'dart:math';
import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';
import 'login.dart';
import 'outlet.dart';

// ====================== KONFIRMASI PESANAN ======================
class ConfirmOrderPage extends StatelessWidget {
  const ConfirmOrderPage({super.key});

  Widget modeTab(BuildContext context, String label, String sub, bool enabled) {
    final sel = app.orderMode == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!enabled) {
            toast(context, '$label tidak tersedia. Scan QR meja di outlet untuk Dine-In.');
            return;
          }
          if (label == 'Delivery' && app.address == null) {
            push(context, const OutletPage(initialTab: 1));
            return;
          }
          app.setMode(label);
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
          decoration: BoxDecoration(
            color: sel ? Colors.white : const Color(0xFFEFF6F5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: sel ? const Border(top: BorderSide(color: C.teal, width: 3)) : null,
          ),
          child: Column(children: [
            Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: sel ? C.teal : (enabled ? C.text : C.grey))),
            Text(sub, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: sel ? C.teal : C.grey)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(children: [
                Container(
                  color: C.tealSoft,
                  child: Column(children: [
                    SizedBox(
                      height: 56,
                      child: Row(children: [
                        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                        const Expanded(child: Center(child: Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)))),
                        const SizedBox(width: 48),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      modeTab(context, 'Pickup', 'Order dan pickup di outlet', true),
                      modeTab(context, 'Dine-In', app.dineInAvailable ? 'Dine-in di outlet' : 'Tidak tersedia di store ini', app.dineInAvailable),
                      modeTab(context, 'Delivery', 'Pesanan diantar ke alamat', true),
                    ]),
                  ]),
                ),
                Expanded(
                  child: app.cart.isEmpty
                      ? Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.shopping_cart_outlined, size: 64, color: C.line),
                            const SizedBox(height: 8),
                            const Text('Keranjang masih kosong', style: TextStyle(color: C.grey)),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  app.goTab(1);
                                },
                                child: const Text('Pilih menu')),
                          ]),
                        )
                      : ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 20), children: [
                          OutlineBox(
                            border: C.line,
                            onTap: () => push(context, OutletPage(initialTab: app.orderMode == 'Delivery' ? 1 : 0)),
                            child: Row(children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(app.orderMode == 'Delivery' ? 'Alamat: ${app.address?.label ?? '-'}' : 'Outlet: ${app.outlet.name}',
                                      style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text(app.orderMode == 'Delivery' ? (app.address?.detail ?? 'Pilih alamat') : app.outlet.address,
                                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.grey, fontSize: 12)),
                                ]),
                              ),
                              const Text('Ubah', style: TextStyle(color: C.blue, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                          const SizedBox(height: 14),
                          Row(children: [
                            const Text('Pesan', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                            const Spacer(),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: C.blue), shape: const StadiumBorder()),
                              onPressed: () {
                                Navigator.pop(context);
                                app.goTab(1);
                              },
                              child: const Text('Tambah Pesanan +', style: TextStyle(color: C.blue, fontWeight: FontWeight.w700)),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          for (final c in List<CartItem>.from(app.cart))
                            AppCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                    if (c.variant.isNotEmpty) Text(c.variant, style: const TextStyle(color: C.grey)),
                                    if (c.note.isNotEmpty) Text('Catatan: ${c.note}', style: const TextStyle(color: C.grey, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Text(rp(c.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(side: const BorderSide(color: C.line), shape: const StadiumBorder(), visualDensity: VisualDensity.compact),
                                        onPressed: () => showProductSheet(context, c.p, edit: c),
                                        icon: const Icon(Icons.edit_outlined, size: 16, color: C.text),
                                        label: const Text('Ganti', style: TextStyle(color: C.text, fontWeight: FontWeight.w700)),
                                      ),
                                      const Spacer(),
                                      GestureDetector(onTap: () => app.changeQty(c, -1), child: const Icon(Icons.remove_circle_outline, color: C.gold, size: 32)),
                                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${c.qty}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17))),
                                      GestureDetector(onTap: () => app.changeQty(c, 1), child: const Icon(Icons.add_circle_outline, color: C.gold, size: 32)),
                                    ]),
                                  ]),
                                ),
                                const SizedBox(width: 8),
                                ProductImage(c.p, size: 70),
                              ]),
                            ),
                          const SizedBox(height: 4),
                          _VoucherEntry(),
                        ]),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2))]),
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total', style: TextStyle(color: C.grey)),
                      Text(rp(app.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    ]),
                    const Spacer(),
                    SizedBox(
                      width: 190,
                      child: PrimaryBtn('Pilih Pembayaran', app.cart.isEmpty
                          ? null
                          : () async {
                              if (!app.loggedIn) {
                                final ok = await showLoginSheet(context);
                                if (!ok) return;
                              }
                              if (app.orderMode == 'Delivery' && app.address == null) {
                                if (context.mounted) toast(context, 'Pilih alamat pengiriman terlebih dulu');
                                return;
                              }
                              if (context.mounted) push(context, const CheckoutPage());
                            }),
                    ),
                  ]),
                ),
              ]),
            ),
          );
        },
      );
}

class _VoucherEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final applied = app.voucher;
    final avail = app.vouchers.length;
    return Column(children: [
      if (applied != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(color: Color(0xFFD7EEDD), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          child: Row(children: [
            const Icon(Icons.check_circle_outline, size: 16, color: C.green),
            const SizedBox(width: 8),
            Expanded(child: Text('${applied.title} diterapkan (-${rp(app.discount + app.shipDiscount)})', style: const TextStyle(color: C.green))),
            GestureDetector(
                onTap: () {
                  app.voucher = null;
                  app.touch();
                },
                child: const Icon(Icons.close, size: 18, color: C.green)),
          ]),
        )
      else if (avail > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(color: Color(0xFFD7EEDD), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 16, color: C.green),
            const SizedBox(width: 8),
            Text('$avail voucher siap dipakai', style: const TextStyle(color: C.green)),
          ]),
        ),
      OutlineBox(
        fill: C.goldSoft,
        border: const Color(0xFFE8B960),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        onTap: () => push(context, const VoucherPage()),
        child: const Row(children: [
          Icon(Icons.local_offer_outlined, color: C.red),
          SizedBox(width: 18),
          Expanded(child: Text('Pakai Kode Voucher', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
          Icon(Icons.chevron_right, color: C.gold),
        ]),
      ),
    ]);
  }
}

// ====================== VOUCHER ======================
class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});
  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final c = TextEditingController();

  void use(Voucher v) {
    if (app.cart.isEmpty) {
      toast(context, 'Tambahkan produk ke keranjang dulu');
      return;
    }
    if (v.type == 'b1g1' && app.cartCount < 2) {
      toast(context, 'Voucher ini butuh minimal 2 produk');
      return;
    }
    if (v.type == 'ship' && app.orderMode != 'Delivery') {
      toast(context, 'Voucher ongkir hanya untuk Delivery');
      return;
    }
    app.voucher = v;
    app.touch();
    Navigator.pop(context);
    toast(context, 'Voucher ${v.title} diterapkan');
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Scaffold(
          backgroundColor: C.bg,
          appBar: const AppBarBack('Voucher'),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: c,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kode voucher (coba MANTAN10)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SmallBtn('Pakai', () async {
                final v = await app.findVoucher(c.text);
                if (!mounted) return;
                if (v == null) {
                  toast(context, 'Kode voucher tidak valid');
                } else {
                  use(v);
                }
              }),
            ]),
            const H('Voucher saya', size: 17, pad: EdgeInsets.only(top: 20, bottom: 8)),
            if (app.vouchers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: Text('Belum ada voucher.\nKlaim promo di Beranda atau beli Voucher Pack di VIP.', textAlign: TextAlign.center, style: TextStyle(color: C.grey))),
              ),
            for (final v in app.vouchers)
              AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  const Icon(Icons.confirmation_number_outlined, color: C.red, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(v.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(v.desc, style: const TextStyle(color: C.grey, fontSize: 12)),
                    ]),
                  ),
                  SmallBtn('Pakai', () => use(v)),
                ]),
              ),
          ]),
        ),
      );
}

// ====================== CHECKOUT ======================
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  Widget methodCard(BuildContext context, PayMethod m) {
    final sel = app.payId == m.id;
    final locked = m.needsLink && !m.linked;
    return GestureDetector(
      onTap: () {
        if (locked) {
          toast(context, 'Hubungkan ${m.name} terlebih dulu');
        } else {
          app.payId = m.id;
          app.touch();
        }
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8, bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? C.gold : C.line, width: 2),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          PayIcon(m, 34),
          const SizedBox(height: 6),
          Text(m.name, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 4),
          if (locked)
            GestureDetector(
              onTap: () => linkPay(context, m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(5)),
                child: const Text('Hubungkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            )
          else
            Text(m.sub, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: C.grey, fontSize: 11)),
        ]),
      ),
    );
  }

  Future<void> pay(BuildContext context) async {
    final m = app.selectedPay;
    if (m.needsLink && !m.linked) {
      toast(context, 'Hubungkan ${m.name} terlebih dulu');
      return;
    }
    if (app.payId.startsWith('card:') && app.total < 50000) {
      toast(context, 'Pembayaran kartu minimal pembelian Rp50.000');
      return;
    }
    push(context, PayPage(method: m, amount: app.total));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final isDel = app.orderMode == 'Delivery';
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const AppBarBack('Checkout'),
            body: Column(children: [
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(14, 8, 14, 16), children: [
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          Container(width: 30, height: 30, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.teal, width: 6))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(isDel ? 'Alamat' : 'Outlet', style: const TextStyle(fontSize: 11, color: C.grey)),
                              Text(isDel ? (app.address?.label ?? '-') : app.outlet.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            ]),
                          ),
                        ]),
                      ),
                      Container(
                        color: C.bg,
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          const Icon(Icons.store, color: C.teal, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(isDel ? 'Opsi Pengiriman' : 'Opsi Pickup', style: const TextStyle(fontSize: 11, color: C.grey)),
                              Text(isDel ? 'Diantar ke alamat (Rp8.000)' : (app.orderMode == 'Dine-In' ? 'Dine-In di outlet' : 'Pickup di Counter'), style: const TextStyle(fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 8),
                    child: Row(children: [
                      const Text('Pembayaran Langsung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      GestureDetector(
                          onTap: () => push(context, const PaymentMethodsPage(showTotal: true)),
                          child: const Text('Lihat Semua', style: TextStyle(color: C.blue, fontWeight: FontWeight.w800))),
                    ]),
                  ),
                  SizedBox(
                    height: 156,
                    child: ListView(scrollDirection: Axis.horizontal, children: [
                      for (final m in app.pay.take(4)) methodCard(context, m),
                    ]),
                  ),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: Row(children: [
                          const Icon(Icons.shopping_cart, color: C.gold, size: 20),
                          const SizedBox(width: 10),
                          const Text('Pesan', style: TextStyle(fontWeight: FontWeight.w800)),
                          const Spacer(),
                          Text('Total ${app.cartCount} Items', style: const TextStyle(color: C.grey)),
                        ]),
                      ),
                      const Divider(height: 1),
                      for (final c in app.cart)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${c.qty} x', style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                                if (c.variant.isNotEmpty) Text(c.variant, style: const TextStyle(color: C.grey, fontSize: 12)),
                              ]),
                            ),
                            Text(rp(c.total), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ]),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    onTap: () {
                      app.bag = !app.bag;
                      app.touch();
                    },
                    child: Row(children: [
                      Icon(app.bag ? Icons.check_box : Icons.check_box_outline_blank, color: app.bag ? C.red : C.grey, size: 30),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Kantung Belanja', style: TextStyle(fontWeight: FontWeight.w600))),
                      const Text('Rp4.000', style: TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  _VoucherEntry(),
                  const H('Beli Paket Voucher, Langsung Hemat', size: 17, pad: EdgeInsets.only(top: 18, bottom: 8)),
                  VipPackCard(vipPacks[1]),
                  const H('Rincian Pembayaran', size: 17, pad: EdgeInsets.only(top: 18, bottom: 8)),
                  _row('Subtotal', rp(app.subtotal)),
                  if (app.discount > 0) _row('Diskon voucher', '-${rp(app.discount)}', color: C.green),
                  if (app.bag) _row('Kantung belanja', 'Rp4.000'),
                  if (isDel) _row('Ongkos kirim', rp(app.shipFee)),
                  if (app.shipDiscount > 0) _row('Diskon ongkir', '-${rp(app.shipDiscount)}', color: C.green),
                  const Divider(),
                  _row('Total', rp(app.total), bold: true),
                ]),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                color: Colors.white,
                child: SafeArea(top: false, child: PrimaryBtn('Bayar - ${rp(app.total)}', app.cart.isEmpty ? null : () => pay(context))),
              ),
            ]),
          );
        },
      );

  Widget _row(String a, String b, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(a, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 17 : 14)),
          const Spacer(),
          Text(b, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: bold ? 17 : 14, color: color)),
        ]),
      );
}

// ---------- paket voucher card (dipakai di checkout & VIP) ----------
class VipPackCard extends StatelessWidget {
  final VipPack p;
  const VipPackCard(this.p, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: C.line),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(p.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.grey, fontSize: 12.5)),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(6)),
                child: Column(children: [
                  Text('${p.count}×', style: const TextStyle(color: C.red, fontWeight: FontWeight.w800, fontSize: 12)),
                  const Icon(Icons.local_activity, color: C.red),
                ]),
              ),
            ]),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(rp(p.normal), style: const TextStyle(decoration: TextDecoration.lineThrough, color: C.grey, fontSize: 12)),
                  const SizedBox(width: 6),
                  Tag('Save ${100 - (p.price * 100 ~/ p.normal)}%'),
                ]),
                Text(rp(p.price), style: const TextStyle(color: C.green, fontWeight: FontWeight.w800, fontSize: 26)),
              ]),
              const Spacer(),
              SmallBtn('Buy Pack', () => buyPack(context, p)),
            ]),
          ),
        ]),
      );
}

Future<void> buyPack(BuildContext context, VipPack p) async {
  if (!app.loggedIn) {
    final ok = await showLoginSheet(context);
    if (!ok) return;
  }
  if (!context.mounted) return;
  final ok = await confirm(context, 'Beli ${p.title}?', 'Kamu akan membayar ${rp(p.price)} dan mendapat ${p.count} voucher.', ok: 'Beli');
  if (!ok || !context.mounted) return;
  try {
    await app.buyPack(p.price, p.title);
  } on ApiException catch (e) {
    if (context.mounted) toast(context, e.message);
    return;
  }
  if (!context.mounted) return;
  toast(context, 'Voucher Pack berhasil dibeli!');
}

// ====================== METODE PEMBAYARAN ======================
class PayIcon extends StatelessWidget {
  final PayMethod m;
  final double size;
  const PayIcon(this.m, this.size, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: m.id == 'qris' ? Colors.white : m.color, border: m.id == 'qris' ? Border.all(color: C.line) : null),
        child: Icon(m.icon, color: m.id == 'qris' ? Colors.black : Colors.white, size: size * .55),
      );
}

void linkPay(BuildContext context, PayMethod m) async {
  final ok = await confirm(context, 'Hubungkan ${m.name}?', 'Kamu akan diarahkan ke aplikasi ${m.name} untuk menyetujui koneksi.', ok: 'Hubungkan');
  if (ok) {
    m.linked = true;
    app.touch();
    if (context.mounted) toast(context, '${m.name} berhasil terhubung');
  }
}

class PaymentMethodsPage extends StatelessWidget {
  final bool showTotal;
  const PaymentMethodsPage({super.key, this.showTotal = false});

  void addCard(BuildContext context) {
    final n = TextEditingController();
    final nm = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Tambah Kartu', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: n, keyboardType: TextInputType.number, maxLength: 16, decoration: const InputDecoration(labelText: 'Nomor kartu (16 digit)', counterText: '')),
          TextField(controller: nm, decoration: const InputDecoration(labelText: 'Nama pemilik kartu')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
              onPressed: () {
                if (n.text.length < 16 || nm.text.trim().isEmpty) {
                  toast(context, 'Lengkapi nomor kartu (16 digit) dan nama');
                  return;
                }
                app.cards.add('•••• ${n.text.substring(12)}');
                app.touch();
                Navigator.pop(ctx);
              },
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Scaffold(
          backgroundColor: C.bg,
          appBar: const AppBarBack('Metode Pembayaran'),
          body: ListView(children: [
            if (showTotal)
              Container(
                color: const Color(0xFFF3E9DD),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  const Icon(Icons.shopping_cart, color: C.gold),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Total', style: TextStyle(fontSize: 11, color: C.grey)),
                    Text(num3(app.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ]),
                  const Spacer(),
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Detail Pesanan', style: TextStyle(color: C.blue, fontWeight: FontWeight.w800))),
                ]),
              ),
            AppCard(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Pembayaran Langsung', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (final m in app.pay)
                  InkWell(
                    onTap: () {
                      if (m.needsLink && !m.linked) {
                        linkPay(context, m);
                      } else if (showTotal) {
                        app.payId = m.id;
                        app.touch();
                      } else {
                        toast(context, '${m.name} siap dipakai');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(children: [
                        PayIcon(m, 46),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            if (m.needsLink && !m.linked) const Text('Belum terhubung', style: TextStyle(color: C.red, fontSize: 13)),
                            Text(m.sub, style: const TextStyle(color: C.grey, fontSize: 13)),
                          ]),
                        ),
                        if (m.needsLink && !m.linked)
                          SmallBtn('Hubungkan', () => linkPay(context, m))
                        else
                          Icon(app.payId == m.id ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: app.payId == m.id ? C.gold : C.grey, size: 30),
                      ]),
                    ),
                  ),
              ]),
            ),
            AppCard(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Kartu Debit / Kredit', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      Text('Min. Pembelian Rp 50.000', style: TextStyle(color: C.grey.withOpacity(.9), fontSize: 12)),
                    ]),
                  ),
                  TextButton(onPressed: () => addCard(context), child: const Text('+ Tambah Kartu', style: TextStyle(color: C.grey, fontWeight: FontWeight.w800))),
                ]),
                for (final c in app.cards)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.credit_card, size: 30),
                    title: Text(c, style: const TextStyle(fontWeight: FontWeight.w700)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          icon: const Icon(Icons.delete_outline, color: C.grey),
                          onPressed: () {
                            app.cards.remove(c);
                            if (app.payId == 'card:$c') app.payId = 'qris';
                            app.touch();
                          }),
                      if (showTotal)
                        GestureDetector(
                            onTap: () {
                              app.payId = 'card:$c';
                              app.touch();
                            },
                            child: Icon(app.payId == 'card:$c' ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: C.gold)),
                    ]),
                  ),
              ]),
            ),
          ]),
          bottomNavigationBar: showTotal
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  child: SafeArea(top: false, child: PrimaryBtn('Gunakan ${app.selectedPay.name}', () => Navigator.pop(context))),
                )
              : null,
        ),
      );
}

// ====================== PEMBAYARAN ======================
class PayPage extends StatefulWidget {
  final PayMethod method;
  final int amount;
  const PayPage({super.key, required this.method, required this.amount});
  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  bool busy = false;

  Future<void> finish() async {
    setState(() => busy = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    try {
      final o = await app.placeOrder(widget.method.name);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => OrderSuccessPage(order: o)), (r) => r.isFirst);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => busy = false);
      toast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isQr = widget.method.id == 'qris';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarBack('Pembayaran'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Text('Bayar dengan ${widget.method.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(rp(widget.amount), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: C.red)),
            const SizedBox(height: 20),
            if (isQr)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: C.line, width: 2), borderRadius: BorderRadius.circular(12)),
                child: CustomPaint(size: const Size(220, 220), painter: _QrPainter(widget.amount)),
              )
            else
              Column(children: [
                PayIcon(widget.method, 90),
                const SizedBox(height: 14),
                Text('Selesaikan pembayaran di aplikasi ${widget.method.name}', textAlign: TextAlign.center, style: const TextStyle(color: C.grey)),
              ]),
            const SizedBox(height: 16),
            const Text('Selesaikan dalam 14:59 menit', style: TextStyle(color: C.grey)),
            const SizedBox(height: 24),
            PrimaryBtn(busy ? 'Memproses...' : (isQr ? 'Saya Sudah Bayar' : 'Bayar Sekarang'), busy ? null : finish),
            const SizedBox(height: 10),
            TextButton(onPressed: busy ? null : () => Navigator.pop(context), child: const Text('Ganti metode pembayaran')),
          ]),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final int seed;
  _QrPainter(this.seed);
  @override
  void paint(Canvas c, Size s) {
    const n = 25;
    final cell = s.width / n;
    final r = Random(seed);
    final p = Paint()..color = Colors.black;
    bool finder(int x, int y) => (x < 8 && y < 8) || (x >= n - 8 && y < 8) || (x < 8 && y >= n - 8);
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        if (r.nextBool()) c.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
      }
    }
    void eye(int ox, int oy) {
      c.drawRect(Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell), p);
      c.drawRect(Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell), Paint()..color = Colors.white);
      c.drawRect(Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell), p);
    }

    eye(0, 0);
    eye(n - 7, 0);
    eye(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter o) => o.seed != seed;
}

// ====================== SUKSES ======================
class OrderSuccessPage extends StatelessWidget {
  final OrderRec order;
  const OrderSuccessPage({super.key, required this.order});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(color: Color(0xFFD7EEDD), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: C.green, size: 70),
              ),
              const SizedBox(height: 20),
              const Text('Pembayaran Berhasil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Nomor pesanan ${order.id}', style: const TextStyle(color: C.grey)),
              const SizedBox(height: 18),
              AppCard(
                child: Column(children: [
                  _l('Metode', order.mode),
                  _l(order.mode == 'Delivery' ? 'Alamat' : 'Outlet', order.outlet),
                  _l('Pembayaran', order.payment),
                  _l('Total', rp(order.total), strong: true),
                  _l('Mantan Points', '+${order.total ~/ 1000} pts'),
                ]),
              ),
              const Spacer(),
              PrimaryBtn('Kembali ke Beranda', () {
                Navigator.popUntil(context, (r) => r.isFirst);
                app.goTab(0);
              }),
              TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (r) => r.isFirst);
                    app.goTab(4);
                  },
                  child: const Text('Lihat Riwayat Pesanan')),
            ]),
          ),
        ),
      );

  Widget _l(String a, String b, {bool strong = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a, style: const TextStyle(color: C.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              b,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
                fontSize: strong ? 16 : 14,
                color: strong ? C.red : null,
              ),
            ),
          ),
        ]),
      );
}