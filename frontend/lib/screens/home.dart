import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';
import 'login.dart';
import 'outlet.dart';
import 'extras.dart';

// ---------- util bersama ----------
void showScanDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text('Scan QR Meja', style: TextStyle(fontWeight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Icon(Icons.qr_code_scanner, color: Colors.white54, size: 90)),
        ),
        const SizedBox(height: 10),
        const Text('Arahkan kamera ke QR di meja outlet.', textAlign: TextAlign.center, style: TextStyle(color: C.grey, fontSize: 12)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        TextButton(
          onPressed: () {
            app.dineInAvailable = true;
            app.selectOutlet(outlets[0]);
            app.setMode('Dine-In');
            Navigator.pop(ctx);
            toast(context, 'Meja 12 - ${outlets[0].name} terdeteksi. Dine-In aktif');
            app.goTab(1);
          },
          child: const Text('Pindai', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
}

void showChooseMethod(BuildContext context) {
  sheet(context, (ctx) {
    Widget card(String title, String desc, Color c, String? chip, VoidCallback on, {String? tag}) => Expanded(
          child: GestureDetector(
            onTap: on,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Stack(children: [
                  Container(width: 62, height: 62, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(.25)), child: Icon(title.startsWith('Ambil') ? Icons.local_cafe : Icons.delivery_dining, color: c, size: 34)),
                  if (tag != null) Positioned(right: 0, top: 0, child: Tag(tag, color: const Color(0xFFA8D88E))),
                ]),
                const SizedBox(height: 14),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Color(0xFF555555), fontSize: 14)),
                const SizedBox(height: 10),
                if (chip != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFE6F0FB), borderRadius: BorderRadius.circular(4)),
                    child: Text(chip, style: const TextStyle(color: C.blue, fontSize: 12)),
                  ),
              ]),
            ),
          ),
        );
    return SheetFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 26),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Choose Method', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              card('Ambil di Outlet', 'Pesanan siap diambil di outlet terdekat.', C.teal, '441.1 M', () {
                Navigator.pop(ctx);
                push(context, const OutletPage(initialTab: 0, goMenu: true));
              }),
              const SizedBox(width: 12),
              card('Antar ke Rumah', 'Pesananmu akan dikirim langsung ke alamatmu dengan cepat.', C.green, null, () {
                Navigator.pop(ctx);
                push(context, const OutletPage(initialTab: 1, goMenu: true));
              }, tag: 'FREE ENGRAVE'),
            ]),
          ),
        ]),
      ),
    );
  });
}

class ClaimCard extends StatelessWidget {
  final String tag, amount, brand, key2;
  final Voucher voucher;
  const ClaimCard({super.key, required this.tag, required this.amount, required this.brand, required this.key2, required this.voucher});
  @override
  Widget build(BuildContext context) {
    final done = app.claimed.contains(key2);
    return Container(
      width: 215,
      margin: const EdgeInsets.only(right: 10, top: 10, bottom: 4),
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 10, 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2))]),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(amount, style: const TextStyle(color: C.green, fontWeight: FontWeight.w800, fontSize: 20)),
                Text(brand, style: const TextStyle(fontSize: 13)),
              ]),
            ),
            GestureDetector(
              onTap: () async {
                if (!app.loggedIn) {
                  final ok = await showLoginSheet(context);
                  if (!ok) return;
                }
                final err = await app.claimVoucher(key2);
                if (context.mounted) toast(context, err ?? 'Voucher berhasil diklaim!');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: done ? C.line : C.gold, width: 2)),
                child: Text(done ? 'Diklaim' : 'Klaim', style: TextStyle(fontWeight: FontWeight.w800, color: done ? C.grey : C.text, fontSize: 15)),
              ),
            ),
          ]),
        ),
        Positioned(left: 0, top: -9, child: Tag(tag)),
      ]),
    );
  }
}

Widget claimStrip() => ListenableBuilder(
      listenable: app,
      builder: (_, __) => SizedBox(
        height: 92,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 16), children: [
          ClaimCard(tag: 'Diskon', amount: '5.000', brand: 'OVO', key2: 'ovo5', voucher: Voucher('OVO5', 'Diskon Rp5.000 OVO', 'Klaim Beranda', 'flat', 5000)),
          ClaimCard(tag: 'Ongkir', amount: '5.000', brand: 'GExpress', key2: 'gex5', voucher: Voucher('GEX5', 'Diskon Ongkir Rp5.000', 'Klaim Beranda', 'ship', 5000)),
          ClaimCard(tag: 'Diskon', amount: '4.000', brand: 'blu', key2: 'blu4', voucher: Voucher('BLU4', 'Diskon Rp4.000 blu', 'Klaim Beranda', 'flat', 4000)),
        ]),
      ),
    );

// ====================== HOME ======================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _Banner {
  final List<Color> colors;
  final String l1, l2, l3;
  final Color textColor;
  final String p1, p2; // id produk untuk foto di banner
  const _Banner(this.colors, this.l1, this.l2, this.l3, this.textColor, this.p1, this.p2);
}

Product _byId(String id) => [...allProducts, ...merchProducts].firstWhere((p) => p.id == id, orElse: () => allProducts.first);

/// Foto produk di banner: kotak membulat dengan bingkai putih dan bayangan.
Widget _bannerPic(Product p, double s) {
  if (ProductAssets.pathFor(p.name) == null) return ProductImage(p, size: s);
  return Container(
    width: s,
    height: s,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
    ),
    child: ProductImage(p, size: s - 6, radius: 13),
  );
}

class _HomePageState extends State<HomePage> {
  final pc = PageController();
  int page = 0;
  Timer? timer;
  static const banners = [
    _Banner([Color(0xFFBFE3F5), Color(0xFFC9A8F0)], 'NEW', 'PURPLE CLOUD', 'BELI 2 DISKON 25%', Color(0xFF9B5DE5), 'n1', 'n3'),
    _Banner([Color(0xFF5A1C12), Color(0xFFB4532A)], 'Everyday Double Cashback', 'UP TO 70%', '40% blu + 30% Mantan Points', Colors.white, 'c2', 'c4'),
    _Banner([Color(0xFF9FD8F0), Color(0xFFBBA2F2)], 'Gratis Minuman &', 'Beli 1 Gratis 1', 'SETIAP HARI* - hanya di aplikasi', Color(0xFF8E3FD0), 'n2', 'c6'),
    _Banner([Color(0xFF7A1F23), Color(0xFFBD1E26)], 'Merch Terbaru', 'Tumbler Mantan', 'Mulai Rp89.000', Colors.white, 'm1', 'm4'),
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!pc.hasClients) return;
      final n = (page + 1) % banners.length;
      pc.animateToPage(n, duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    pc.dispose();
    super.dispose();
  }

  void bannerTap(int i) {
    if (i == 3) {
      app.goTab(3);
    } else {
      app.goTab(1);
    }
  }

  Widget quick(String label, Widget icon, VoidCallback on, {String? badge}) => Expanded(
        child: GestureDetector(
          onTap: on,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2))]),
            child: Column(children: [
              Stack(clipBehavior: Clip.none, children: [
                icon,
                if (badge != null) Positioned(left: -10, top: -14, child: Tag(badge, color: C.red)),
              ]),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );

  Widget circ(IconData i, Color c) => Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(.22)), child: Icon(i, color: c, size: 32));

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final night = hour >= 18 || hour < 5;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => ListView(padding: EdgeInsets.zero, children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFDDE3F6), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: app.loggedIn
                        ? Row(children: [
                            const Icon(Icons.shield, size: 22, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text('${app.level} ', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            Text('${app.levelPct}%', style: const TextStyle(fontSize: 11, color: C.grey)),
                            const SizedBox(width: 10),
                            const CircleAvatar(radius: 10, backgroundColor: C.gold, child: Text('K', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))),
                            const SizedBox(width: 6),
                            Text('${app.points}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                            const Text(' pts', style: TextStyle(fontSize: 12, color: C.grey)),
                          ])
                        : const Text.rich(TextSpan(children: [TextSpan(text: 'Hai, ', style: TextStyle(color: C.grey, fontSize: 16)), TextSpan(text: 'Guest', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))])),
                  ),
                  Icon(night ? Icons.nights_stay : Icons.wb_sunny, color: night ? const Color(0xFFF2C94C) : Colors.orange, size: 38),
                ]),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))]),
                  child: Row(children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                        onTap: () => push(context, OutletPage(initialTab: app.orderMode == 'Delivery' ? 1 : 0)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(app.locationTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                if (app.outletChosen || app.orderMode == 'Delivery')
                                  Text(app.locationSub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.grey, fontSize: 12)),
                              ]),
                            ),
                            const Icon(Icons.expand_circle_down_outlined, color: C.red, size: 24),
                          ]),
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                      onTap: () => showScanDialog(context),
                      child: Container(
                        width: 60,
                        height: 54,
                        decoration: const BoxDecoration(color: C.redSoft, borderRadius: BorderRadius.horizontal(right: Radius.circular(10))),
                        child: const Icon(Icons.qr_code_scanner, color: C.red, size: 28),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Melayani  ', style: TextStyle(color: C.grey, fontSize: 12)),
                  Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.green, width: 2.5))),
                  const Text(' Delivery  ', style: TextStyle(fontSize: 12)),
                  Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.teal, width: 2.5))),
                  const Text(' Pickup', style: TextStyle(fontSize: 12)),
                ]),
              ]),
            ),
          ),
        ),
        // banner
        SizedBox(
          height: 215,
          child: Stack(alignment: Alignment.bottomCenter, children: [
            PageView.builder(
              controller: pc,
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => page = i),
              itemBuilder: (_, i) {
                final b = banners[i];
                return GestureDetector(
                  onTap: () => bannerTap(i),
                  child: Container(
                    decoration: BoxDecoration(gradient: LinearGradient(colors: b.colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
                    padding: const EdgeInsets.fromLTRB(20, 16, 10, 24),
                    child: Row(children: [
                      Expanded(
                        flex: 5,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Row(children: [const HeartLogo(size: 22, color: Colors.white), const SizedBox(width: 6), const Text('kopi mantan', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700))]),
                          const Spacer(),
                          Text(b.l1, style: TextStyle(color: b.textColor, fontWeight: FontWeight.w800, fontSize: 16)),
                          Text(b.l2, style: TextStyle(color: b.textColor, fontWeight: FontWeight.w900, fontSize: 27, height: 1.05)),
                          const SizedBox(height: 4),
                          Text(b.l3, style: TextStyle(color: b.textColor, fontWeight: FontWeight.w800, fontSize: 14)),
                        ]),
                      ),
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: 175,
                              height: 150,
                              child: Stack(children: [
                                Positioned(left: 0, bottom: 0, child: _bannerPic(_byId(b.p1), 92)),
                                Positioned(right: 0, top: 0, child: _bannerPic(_byId(b.p2), 110)),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                for (int i = 0; i < banners.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == page ? 24 : 8,
                    height: 5,
                    decoration: BoxDecoration(color: i == page ? Colors.white : Colors.white60, borderRadius: BorderRadius.circular(5)),
                  ),
              ]),
            ),
          ]),
        ),
        // quick menu
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              quick('Order', Stack(clipBehavior: Clip.none, children: [circ(Icons.phone_android, C.red), const Positioned(right: -2, bottom: -2, child: CircleAvatar(radius: 11, backgroundColor: C.green, child: Icon(Icons.add, color: Colors.white, size: 16)))]), () => showChooseMethod(context)),
              quick('Delivery Hemat', circ(Icons.delivery_dining, C.gold), () => push(context, const OutletPage(initialTab: 1, goMenu: true)), badge: 'DISC 40%'),
              quick('Chicken &\nBurger', circ(Icons.lunch_dining, const Color(0xFFE08A2E)), () {
                app.menuJump = 'Chicken & Burger';
                app.goTab(1);
              }),
              quick('Catering &\nWedding', circ(Icons.cake, const Color(0xFFD9A441)), () => push(context, const BulkOrderPage())),
            ]),
          ),
        ),
        // voucher b1g1
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: OutlineBox(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(children: [
              const Icon(Icons.mark_email_unread, color: C.red, size: 44),
              const SizedBox(width: 12),
              const Expanded(child: Text('Voucher Buy 1 Get 1\nSEPUASNYA!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
              ListenableBuilder(
                listenable: app,
                builder: (_, __) {
                  final done = app.claimed.contains('b1g1home');
                  return SmallBtn(
                    done ? 'Diklaim' : 'Klaim',
                    done
                        ? () => toast(context, 'Voucher sudah pernah diklaim')
                        : () async {
                            if (!app.loggedIn) {
                              final ok = await showLoginSheet(context);
                              if (!ok) return;
                            }
                            final err = await app.claimVoucher('b1g1home');
                            if (context.mounted) toast(context, err ?? 'Voucher Buy 1 Get 1 diklaim!');
                          },
                    color: done ? C.grey : C.red,
                  );
                },
              ),
            ]),
          ),
        ),
        // spesial hari ini
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(children: [
            const Text('Spesial Hari Ini', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const Spacer(),
            GestureDetector(onTap: () => app.goTab(1), child: const Icon(Icons.chevron_right, size: 28, color: C.grey)),
          ]),
        ),
        SizedBox(
          height: 190,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 16), children: [
            for (final p in allProducts.take(3))
              Padding(padding: const EdgeInsets.only(right: 14), child: ProductCard(p, pill: true, onTap: () => showProductSheet(context, p))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            const Icon(Icons.discount, color: C.green, size: 26),
            const SizedBox(width: 8),
            const Text('Diskon & Cashback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
        ),
        claimStrip(),
        const SizedBox(height: 24),
      ]),
    );
  }
}