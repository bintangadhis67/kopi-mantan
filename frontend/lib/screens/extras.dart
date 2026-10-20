import 'package:flutter/material.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';
import 'login.dart';

const privacyText =
    'Kopi Mantan menghargai privasimu.\n\n1. Data yang kami kumpulkan: nama, nomor handphone, email, tanggal lahir, kota, dan riwayat pesanan.\n\n2. Data dipakai untuk memproses pesanan, memberikan promo, dan meningkatkan layanan.\n\n3. Kami tidak menjual data pribadimu ke pihak ketiga.\n\n4. Kamu dapat mengubah atau menghapus akun kapan saja melalui menu Edit Profil.\n\nAplikasi ini dibuat untuk keperluan tugas UTS Pemrograman Aplikasi Bergerak dan bukan aplikasi resmi.';
const termsText =
    'Dengan memakai aplikasi Kopi Mantan, kamu menyetujui ketentuan berikut:\n\n1. Pesanan yang sudah dibayar tidak dapat dibatalkan.\n\n2. Voucher hanya berlaku satu kali per transaksi dan tidak dapat digabung.\n\n3. Mantan Points tidak dapat diuangkan.\n\n4. Harga dan promo dapat berubah sewaktu-waktu.\n\nAplikasi ini adalah proyek pembelajaran (clone UI) dan tidak memproses pembayaran sungguhan.';
const aboutText =
    'Kopi Mantan adalah aplikasi pemesanan kopi hasil replikasi UI/UX untuk tugas UTS Pemrograman Aplikasi Bergerak.\n\nFitur: pilih outlet, pesan menu, voucher, VIP, check-in harian, pembayaran, dan riwayat pesanan.\n\nVersi 126.10.08';

// ====================== PESANAN JUMLAH BESAR ======================
class BulkOrderPage extends StatelessWidget {
  const BulkOrderPage({super.key});

  Widget card(BuildContext context, String title, String desc, IconData icon, Color c, String type) => Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 10, offset: Offset(0, 4))]),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => push(context, BulkFormPage(type: type)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 190,
              decoration: BoxDecoration(color: c.withOpacity(.18), borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
              child: Stack(alignment: Alignment.center, children: [
                Icon(icon, size: 110, color: c),
                const Positioned(right: 24, top: 20, child: Icon(Icons.auto_awesome, color: Colors.white, size: 28)),
                Positioned(left: 24, bottom: 20, child: ProductImage(allProducts[1], size: 60)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(desc, style: const TextStyle(fontSize: 14)),
              ]),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Pesanan Jumlah Besar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          actions: [IconButton(icon: const Icon(Icons.headset_mic_outlined), onPressed: () => info(context, 'Bantuan Pesanan Besar', 'Hubungi tim catering kami di WhatsApp 0812-0000-5678.'))],
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [C.maroon, Color(0xFFA32A2C)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SafeArea(
            child: ListView(padding: const EdgeInsets.fromLTRB(18, 64, 18, 24), children: [
              card(context, 'Big Order Delivery', 'Dikirimkan dengan sempurna sampai di acara Anda', Icons.delivery_dining, C.gold, 'Delivery'),
              card(context, 'Big Order Serve On Site', 'Dihidangkan dengan sempurna oleh baperista', Icons.storefront, C.red, 'Serve On Site'),
            ]),
          ),
        ),
      );
}

class BulkFormPage extends StatefulWidget {
  final String type;
  const BulkFormPage({super.key, required this.type});
  @override
  State<BulkFormPage> createState() => _BulkFormPageState();
}

class _BulkFormPageState extends State<BulkFormPage> {
  late final name = TextEditingController(text: app.loggedIn ? app.user.name : '');
  late final phone = TextEditingController(text: app.user.phone);
  final qty = TextEditingController();
  final loc = TextEditingController();
  final note = TextEditingController();
  DateTime? date;

  @override
  void dispose() {
    for (final c in [name, phone, qty, loc, note]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget f(String l, TextEditingController c, {TextInputType kb = TextInputType.text, int lines = 1, String? hint}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            keyboardType: kb,
            maxLines: lines,
            decoration: InputDecoration(hintText: hint, filled: true, fillColor: C.field, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
          ),
        ]),
      );

  Future<void> submit() async {
    final q = int.tryParse(qty.text.trim()) ?? 0;
    if (name.text.trim().isEmpty || phone.text.trim().length < 9 || loc.text.trim().isEmpty || date == null) {
      toast(context, 'Lengkapi nama, nomor HP, tanggal, dan lokasi acara');
      return;
    }
    if (q < 20) {
      toast(context, 'Minimal pesanan jumlah besar adalah 20 cup');
      return;
    }
    if (!app.loggedIn) {
      final ok = await showLoginSheet(context);
      if (!ok || !mounted) return;
    }
    final code = 'BO-${DateTime.now().millisecondsSinceEpoch % 100000}';
    await app.addNotif('Permintaan ${widget.type} diterima', 'Kode $code. Tim kami akan menghubungi ${phone.text.trim()} dalam 1x24 jam.');
    if (!mounted) return;
    await info(context, 'Permintaan terkirim', 'Kode pesanan: $code\n$q cup - ${widget.type}\nTim kami akan segera menghubungimu.');
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarBack('Big Order ${widget.type}'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          f('Nama penanggung jawab', name),
          f('Nomor handphone', phone, kb: TextInputType.phone),
          const Text('Tanggal acara', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 3)), firstDate: DateTime.now().add(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => date = d);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(8)),
              child: Text(date == null ? 'Pilih tanggal' : '${date!.day}/${date!.month}/${date!.year}', style: TextStyle(color: date == null ? C.grey : C.text)),
            ),
          ),
          f('Jumlah cup (min. 20)', qty, kb: TextInputType.number),
          f(widget.type == 'Delivery' ? 'Alamat pengiriman' : 'Lokasi acara', loc, lines: 2),
          f('Catatan', note, lines: 3, hint: 'Menu favorit, jam acara, dll.'),
          PrimaryBtn('Kirim Permintaan', submit),
        ]),
      );
}

// ====================== RIWAYAT PESANAN ======================
class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  void detail(BuildContext context, OrderRec o) {
    sheet(context, (ctx) => SheetFrame(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.id, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text('${o.date} - ${o.mode} - ${o.outlet}', style: const TextStyle(color: C.grey)),
              const Divider(height: 24),
              for (final c in o.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [Text('${c.qty}x ', style: const TextStyle(fontWeight: FontWeight.w700)), Expanded(child: Text(c.title)), Text(rp(c.total))]),
                ),
              const Divider(height: 24),
              Row(children: [const Text('Total', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Text(rp(o.total), style: const TextStyle(fontWeight: FontWeight.w800))]),
              Text('Dibayar dengan ${o.payment}', style: const TextStyle(color: C.grey, fontSize: 12)),
              const SizedBox(height: 14),
              PrimaryBtn('Pesan Lagi', () {
                for (final c in o.items) {
                  app.addToCart(CartItem(c.p, size: c.size, ice: c.ice, sugar: c.sugar, note: c.note, qty: c.qty));
                }
                Navigator.pop(ctx);
                Navigator.popUntil(context, (r) => r.isFirst);
                app.goTab(1);
                toast(context, 'Pesanan ditambahkan ke keranjang');
              }),
            ]),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Scaffold(
          backgroundColor: C.bg,
          appBar: const AppBarBack('Riwayat Pesanan'),
          body: app.orders.isEmpty
              ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_long_outlined, size: 70, color: C.line), SizedBox(height: 8), Text('Belum ada pesanan', style: TextStyle(color: C.grey))]))
              : ListView(padding: const EdgeInsets.all(16), children: [
                  for (final o in app.orders)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () => detail(context, o),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(o.id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          const Spacer(),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFD7EEDD), borderRadius: BorderRadius.circular(4)), child: Text(o.status, style: const TextStyle(color: C.green, fontSize: 12, fontWeight: FontWeight.w700))),
                        ]),
                        Text('${o.date} - ${o.mode}', style: const TextStyle(color: C.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(o.items.map((e) => '${e.qty}x ${e.p.name}').join(', '), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(rp(o.total), style: const TextStyle(fontWeight: FontWeight.w800, color: C.red)),
                      ]),
                    ),
                ]),
        ),
      );
}

// ====================== KOTAK MASUK ======================
class InboxPage extends StatelessWidget {
  const InboxPage({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Scaffold(
          backgroundColor: C.bg,
          appBar: AppBarBack('Kotak Masuk', actions: [
            TextButton(
                onPressed: () => app.markAllRead(),
                child: const Text('Baca semua', style: TextStyle(color: C.blue, fontWeight: FontWeight.w700))),
          ]),
          body: app.inbox.isEmpty
              ? const Center(child: Text('Belum ada pesan', style: TextStyle(color: C.grey)))
              : ListView(padding: const EdgeInsets.all(16), children: [
                  for (final n in app.inbox)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      onTap: () => app.markNotifRead(n),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(margin: const EdgeInsets.only(top: 6, right: 10), width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: n.read ? Colors.transparent : C.red)),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(n.body, style: const TextStyle(color: Color(0xFF555555), fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(n.time, style: const TextStyle(color: C.grey, fontSize: 11)),
                          ]),
                        ),
                      ]),
                    ),
                ]),
        ),
      );
}

// ====================== BANTUAN & INFO ======================
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) {
    const faq = [
      ['Bagaimana cara memesan?', 'Pilih outlet atau alamat di Beranda, pilih menu, lalu tekan keranjang dan Pilih Pembayaran.'],
      ['Bagaimana memakai voucher?', 'Di halaman Konfirmasi Pesanan tekan "Pakai Kode Voucher", pilih voucher atau masukkan kode (coba MANTAN10).'],
      ['Bagaimana cara naik level VIP?', 'Level naik otomatis sesuai total belanja: Gold Rp700.000, Platinum Rp2.000.000.'],
      ['Metode pembayaran apa saja?', 'QRIS, e-wallet (GoPay, ShopeePay, OVO, DANA, dll), dan kartu debit/kredit.'],
      ['Pesanan saya salah, apa yang harus dilakukan?', 'Hubungi layanan WhatsApp atau gunakan menu Lapor Masalah.'],
    ];
    return Scaffold(
      backgroundColor: C.bg,
      appBar: const AppBarBack('Bantuan'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final q in faq)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(q[0], style: const TextStyle(fontWeight: FontWeight.w700)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(q[1], style: const TextStyle(color: Color(0xFF555555)))],
              ),
            ),
          ),
      ]),
    );
  }
}

class InfoTextPage extends StatelessWidget {
  final String title, text;
  const InfoTextPage(this.title, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarBack(title),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          if (title.startsWith('Tentang')) const Center(child: Padding(padding: EdgeInsets.only(bottom: 20), child: HeartLogo(size: 80))),
          Text(text, style: const TextStyle(height: 1.5, fontSize: 15)),
        ]),
      );
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String cat = 'Aplikasi error';
  final msg = TextEditingController();
  @override
  void dispose() {
    msg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppBarBack('Lapor Masalah'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Jenis masalah', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(8)),
            child: DropdownButton<String>(
              value: cat,
              isExpanded: true,
              underline: const SizedBox(),
              items: ['Aplikasi error', 'Masalah pesanan', 'Masalah pembayaran', 'Lainnya'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => cat = v ?? cat),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: msg,
            maxLines: 6,
            decoration: InputDecoration(hintText: 'Ceritakan masalahmu...', filled: true, fillColor: C.field, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 20),
          PrimaryBtn('Kirim Laporan', () async {
            if (msg.text.trim().length < 10) {
              toast(context, 'Deskripsi minimal 10 karakter');
              return;
            }
            await app.addNotif('Laporan terkirim', 'Laporan "$cat" kami terima. Terima kasih!');
            if (!context.mounted) return;
            Navigator.pop(context);
            toast(context, 'Laporan terkirim. Terima kasih!');
          }),
        ]),
      );
}

// ====================== DIALOG-DIALOG ======================
final Set<String> _usedMerch = {};

void showScanMerch(BuildContext context) {
  final c = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text('Scan Merchandise', style: TextStyle(fontWeight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Icon(Icons.qr_code_scanner, color: Colors.white54, size: 70)),
        ),
        const SizedBox(height: 10),
        TextField(controller: c, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(hintText: 'Atau ketik kode (mis. MERCH123)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        TextButton(
          onPressed: () async {
            final code = c.text.trim().toUpperCase();
            if (code.length < 6) {
              toast(context, 'Kode minimal 6 karakter');
              return;
            }
            Navigator.pop(ctx);
            if (!app.loggedIn) {
              final ok = await showLoginSheet(context);
              if (!ok || !context.mounted) return;
            }
            if (_usedMerch.contains(code)) {
              if (context.mounted) toast(context, 'Kode sudah pernah dipakai');
              return;
            }
            _usedMerch.add(code);
            app.points += 50;
            app.touch();
            if (context.mounted) toast(context, 'Merchandise terverifikasi! +50 Mantan Points');
          },
          child: const Text('Klaim', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
}

void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => SimpleDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(t('Ubah Bahasa Aplikasi', 'Change App Language'), style: const TextStyle(fontWeight: FontWeight.w800)),
      children: [
        for (final l in [['id', 'Bahasa Indonesia'], ['en', 'English']])
          ListTile(
            title: Text(l[1]),
            trailing: Icon(app.lang == l[0] ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: C.gold),
            onTap: () {
              app.setLang(l[0]);
              Navigator.pop(ctx);
              toast(context, l[0] == 'id' ? 'Bahasa diubah ke Indonesia' : 'Language changed to English');
            },
          ),
      ],
    ),
  );
}

void showTutorial(BuildContext context) {
  const steps = [
    ['1. Pilih lokasi', 'Tekan kartu outlet di Beranda untuk memilih outlet (Pickup) atau alamat (Delivery).'],
    ['2. Pilih menu', 'Buka tab Menu, pilih produk, atur ukuran, es, dan gula, lalu tambahkan ke keranjang.'],
    ['3. Konfirmasi', 'Tekan bar merah di bawah untuk melihat pesanan, pakai voucher, lalu Pilih Pembayaran.'],
    ['4. Bayar', 'Pilih QRIS atau e-wallet, lalu selesaikan pembayaran. Ambil pesananmu di outlet!'],
  ];
  int i = 0;
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(steps[i][0], style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(steps[i][1]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Lewati')),
          TextButton(
            onPressed: () {
              if (i < steps.length - 1) {
                setS(() => i++);
              } else {
                Navigator.pop(ctx);
              }
            },
            child: Text(i < steps.length - 1 ? 'Lanjut' : 'Selesai', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    ),
  );
}