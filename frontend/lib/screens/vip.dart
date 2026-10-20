import 'package:flutter/material.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';
import 'login.dart';
import 'order_flow.dart';

class VipPage extends StatefulWidget {
  const VipPage({super.key});
  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {
  int seg = 1; // 0 voucher, 1 pack, 2 benefits
  int page = 0;
  final pageC = PageController();

  @override
  void dispose() {
    pageC.dispose();
    super.dispose();
  }

  static const levels = [
    ['SILVER', '0', '699.999', 'Gold', '700000'],
    ['GOLD', '700.000', '1.999.999', 'Platinum', '2000000'],
    ['PLATINUM', '2.000.000', '∞', 'Platinum', '2000000'],
  ];

  Widget levelCard(int i) {
    final l = levels[i];
    final colors = [
      [const Color(0xFFF4F6FA), const Color(0xFFD9DEE8)],
      [const Color(0xFFFFF3D6), const Color(0xFFE8C772)],
      [const Color(0xFFEDE6F7), const Color(0xFFB9A4DB)],
    ][i];
    final current = app.level.toUpperCase() == l[0];
    final target = int.parse(l[4]);
    final double pct = i == 0 ? (app.spend / 699999).clamp(0.0, 1.0).toDouble() : (i == 1 ? ((app.spend - 700000) / 1300000).clamp(0.0, 1.0).toDouble() : (app.spend >= 2000000 ? 1.0 : 0.0));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(children: [
        Expanded(
          flex: 6,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Text(l[0], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              if (current)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                  child: Text('${app.levelPct}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 6),
            Text('Hai, ${app.loggedIn ? app.user.name : 'Guest'}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              TextSpan(text: current ? num3(app.spend) : l[1], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              TextSpan(text: ' / ${l[2]}', style: const TextStyle(color: C.grey)),
            ])),
            const SizedBox(height: 6),
            Stack(alignment: Alignment.centerRight, children: [
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: (current || i == 0) ? pct : 0.0, minHeight: 6, backgroundColor: Colors.white, color: C.gold)),
              const CircleAvatar(radius: 8, backgroundColor: C.gold, child: Icon(Icons.favorite, size: 10, color: Colors.white)),
            ]),
            const SizedBox(height: 6),
            Text(
              i == 2 ? 'Level tertinggi Mantan VIP' : (current ? 'Belanja ${rp((target - app.spend).clamp(0, target).toInt())} lagi untuk naik ke Level ${l[3]}' : 'Minimal belanja ${rp(i == 1 ? 700000 : 2000000)} untuk mencapai level ini'),
              style: const TextStyle(fontSize: 12),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Icon(Icons.workspace_premium, size: 92, color: [Colors.blueGrey.shade300, C.gold, C.purple][i])),
      ]),
    );
  }

  Widget segBtn(String label, int i) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => seg = i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: seg == i ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: seg == i ? Colors.transparent : const Color(0xFFC9D0DC)),
            ),
            child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          ),
        ),
      );

  Widget body() {
    if (seg == 0) {
      if (!app.loggedIn) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Icon(Icons.confirmation_number_outlined, size: 56, color: C.line),
            const SizedBox(height: 8),
            const Text('Masuk untuk melihat voucher kamu', style: TextStyle(color: C.grey)),
            const SizedBox(height: 12),
            SmallBtn('Masuk', () => showLoginSheet(context)),
          ]),
        );
      }
      if (app.vouchers.isEmpty) {
        return const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Belum ada voucher.', style: TextStyle(color: C.grey))));
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const H('Voucher Saya', size: 18, pad: EdgeInsets.fromLTRB(4, 14, 4, 8)),
        for (final v in app.vouchers)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.line)),
            child: Row(children: [
              const Icon(Icons.local_activity, color: C.red, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(v.desc, style: const TextStyle(color: C.grey, fontSize: 12)),
                ]),
              ),
              SmallBtn('Pakai', () {
                app.voucher = v;
                app.touch();
                toast(context, 'Voucher dipilih. Lanjut pesan untuk memakainya.');
                app.goTab(1);
              }),
            ]),
          ),
      ]);
    }
    if (seg == 1) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const H('Tersedia', size: 18, pad: EdgeInsets.fromLTRB(4, 14, 4, 8)),
        for (final p in vipPacks) VipPackCard(p),
      ]);
    }
    final perks = {
      'Silver': ['Kumpulkan Mantan Points tiap transaksi', 'Voucher ulang tahun', 'Akses promo aplikasi'],
      'Gold': ['Semua benefit Silver', 'Poin 1.5x lebih banyak', 'Gratis upsize 2x tiap bulan'],
      'Platinum': ['Semua benefit Gold', 'Poin 2x lebih banyak', 'Voucher B1G1 tiap bulan', 'Prioritas layanan'],
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final e in perks.entries) ...[
        H('Level ${e.key}', size: 17, pad: const EdgeInsets.fromLTRB(4, 14, 4, 6)),
        for (final t in e.value)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
            child: Row(children: [const Icon(Icons.check_circle, size: 18, color: C.green), const SizedBox(width: 8), Expanded(child: Text(t))]),
          ),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Container(
          color: const Color(0xFFE4E9F1),
          child: SafeArea(
            bottom: false,
            child: Column(children: [
              SizedBox(
                height: 56,
                child: Row(children: [
                  const SizedBox(width: 48),
                  const Expanded(child: Center(child: Text('Mantan VIP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)))),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () => info(context, 'Tentang Mantan VIP', 'Belanja untuk naik level:\n• Silver: awal\n• Gold: belanja Rp700.000\n• Platinum: belanja Rp2.000.000\n\nSemakin tinggi level, semakin banyak benefit.'),
                  ),
                ]),
              ),
              Expanded(
                child: ListView(padding: const EdgeInsets.only(bottom: 20), children: [
                  SizedBox(
                    height: 210,
                    child: PageView.builder(
                      itemCount: 3,
                      controller: pageC,
                      onPageChanged: (i) => setState(() => page = i),
                      itemBuilder: (_, i) => levelCard(i),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (int i = 0; i < 3; i++)
                        Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: i == page ? 22 : 8, height: 5, decoration: BoxDecoration(color: i == page ? C.gold : const Color(0xFFBFC6D2), borderRadius: BorderRadius.circular(5))),
                    ]),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(minHeight: 380),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFFE4E9F1), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [segBtn('Voucher', 0), const SizedBox(width: 4), segBtn('Voucher Pack', 1), const SizedBox(width: 4), segBtn('Benefits', 2)]),
                      ),
                      body(),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      );
}