import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';
import 'login.dart';
import 'outlet.dart';
import 'order_flow.dart';
import 'extras.dart';

Future<String?> promptText(BuildContext context, String title, String initial,
    {TextInputType kb = TextInputType.text, String hint = '', bool obscure = false, int? maxLen}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      content: TextField(controller: c, keyboardType: kb, obscureText: obscure, maxLength: maxLen, autofocus: true, decoration: InputDecoration(hintText: hint, counterText: '')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        TextButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w800))),
      ],
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget row(BuildContext context, IconData icon, String label, VoidCallback on, {bool badge = false}) => InkWell(
        onTap: on,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(children: [
            Icon(icon, size: 26, color: C.text),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            if (badge)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: C.green, borderRadius: BorderRadius.circular(6)),
                child: const Text('Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            const Icon(Icons.chevron_right, color: C.gold),
          ]),
        ),
      );

  Widget group(List<Widget> rows) => AppCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          for (int i = 0; i < rows.length; i++) ...[rows[i], if (i < rows.length - 1) const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF0F0F0))],
        ]),
      );

  Widget dayTile(BuildContext context, int i) {
    final cycleDone = app.checkedDays % 7;
    final doneCount = app.checkedToday ? (((app.checkedDays - 1) % 7) + 1) : cycleDone;
    final done = i < doneCount;
    final current = !app.checkedToday && i == cycleDone;
    final r = dailyRewards[i];
    return GestureDetector(
      onTap: current
          ? () async {
              if (!app.loggedIn) {
                final ok = await showLoginSheet(context);
                if (!ok) return;
              }
              final err = await app.checkIn();
              if (context.mounted) toast(context, err ?? 'Check-in berhasil! Hadiah hari ke-${i + 1}: $r');
            }
          : () => toast(context, done ? 'Hari ke-${i + 1} sudah diambil' : (app.checkedToday ? 'Kembali lagi besok!' : 'Selesaikan check-in hari sebelumnya')),
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: done ? const Color(0xFFF3E9DD) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: current ? C.gold : C.line, width: 2),
        ),
        child: Column(children: [
          done
              ? const CircleAvatar(radius: 15, backgroundColor: C.gold, child: Icon(Icons.check, color: Colors.white, size: 18))
              : CircleAvatar(radius: 15, backgroundColor: current ? C.gold : const Color(0xFFE8E8E8), child: Icon(r == 'Voucher' ? Icons.confirmation_number : Icons.monetization_on, color: current ? Colors.white : Colors.grey, size: 18)),
          const SizedBox(height: 6),
          Text(r, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: done ? C.gold : C.text, decoration: done ? TextDecoration.lineThrough : null)),
          Text(current ? 'Check-In' : 'Hari ke-${i + 1}', style: TextStyle(fontSize: 11, color: done || current ? C.gold : C.grey)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final li = app.loggedIn;
          return Column(children: [
            Expanded(
              child: ListView(padding: EdgeInsets.zero, children: [
                Stack(children: [
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD9DFEA), Color(0xFFEFF1F6)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                    child: Stack(children: [
                      Positioned(left: -20, top: -10, child: Opacity(opacity: .5, child: HeartLogo(size: 130, color: Colors.grey.shade400))),
                      Positioned(
                        right: 16,
                        top: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: GestureDetector(
                              onTap: () => li ? push(context, const EditProfilePage()) : showLoginSheet(context),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(li ? 'Edit Profil ' : 'Masuk ', style: const TextStyle(fontWeight: FontWeight.w600, color: C.gold)),
                                Icon(li ? Icons.edit_note : Icons.chevron_right, size: 20, color: C.text),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 84),
                    child: Stack(clipBehavior: Clip.none, children: [
                      AppCard(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.fromLTRB(12, 24, 12, 10),
                        child: IntrinsicHeight(
                          child: Row(children: [
                            Expanded(
                              flex: 5,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                                const Text('Hai,', style: TextStyle(color: C.grey)),
                                Text(li ? app.user.name : 'Guest', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              ]),
                            ),
                            const VerticalDivider(width: 14),
                            Expanded(
                              flex: 4,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                const Text('Level', style: TextStyle(color: C.gold, fontWeight: FontWeight.w700, fontSize: 13)),
                                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  const Icon(Icons.shield, size: 20, color: Colors.blueGrey),
                                  const SizedBox(width: 4),
                                  Text(app.level, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                  Text(li ? ' ${app.levelPct}%' : ' -%', style: const TextStyle(fontSize: 10, color: C.grey)),
                                ]),
                              ]),
                            ),
                            const VerticalDivider(width: 14),
                            Expanded(
                              flex: 5,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                const Text('Mantan Points', style: TextStyle(color: C.gold, fontWeight: FontWeight.w700, fontSize: 13)),
                                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  const CircleAvatar(radius: 9, backgroundColor: C.gold, child: Text('K', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                                  const SizedBox(width: 6),
                                  Text(li ? '${app.points}' : '-', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                                  const Text(' pts', style: TextStyle(fontSize: 11, color: C.grey)),
                                ]),
                              ]),
                            ),
                          ]),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        top: -48,
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade600, width: 3),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40), bottomRight: Radius.circular(40), bottomLeft: Radius.circular(6)),
                          ),
                          child: Icon(li ? Icons.face_3 : Icons.coffee, size: 52, color: li ? C.red : const Color(0xFF8B2E2E)),
                        ),
                      ),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                // WA promo
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    Row(children: [
                      const Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('✨ Promo Spesial Buat Kamu!', style: TextStyle(color: C.green, fontWeight: FontWeight.w800, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Ikuti channel kami dan jangan lewatkan penawaran menarik setiap saat.', style: TextStyle(fontSize: 12)),
                        ]),
                      ),
                      Icon(Icons.chat, color: C.wa.withOpacity(.9), size: 64),
                    ]),
                    const SizedBox(height: 12),
                    PrimaryBtn('Ikuti Sekarang', () => info(context, 'Channel WhatsApp', 'Kamu akan diarahkan ke channel WhatsApp Kopi Mantan.'), color: C.wa, leading: const Icon(Icons.chat, color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 14),
                // check-in
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('Daily Check-In', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      GestureDetector(
                          onTap: () => info(context, 'Daily Check-In', 'Check-in setiap hari untuk mendapat poin dan voucher.\nHari 1,2,4,5: +25 poin\nHari 3 dan 6: Voucher\nHari 7: +50 poin'),
                          child: const Text('Detail', style: TextStyle(color: C.blue, fontWeight: FontWeight.w800))),
                    ]),
                    const Text('Berakhir 31 Oct 2026', style: TextStyle(color: C.grey, fontSize: 12)),
                    const SizedBox(height: 10),
                    SizedBox(height: 98, child: ListView(scrollDirection: Axis.horizontal, children: [for (int i = 0; i < 7; i++) dayTile(context, i)])),
                  ]),
                ),
                const H('Akun', size: 19, pad: EdgeInsets.fromLTRB(16, 16, 16, 8)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: group([
                    row(context, Icons.inbox_outlined, 'Kotak Masuk', () => push(context, const InboxPage())),
                    row(context, Icons.edit_location_alt_outlined, 'Alamat Pengiriman', () => push(context, const OutletPage(initialTab: 1))),
                    row(context, Icons.shopping_bag_outlined, 'Scan Merchandise', () => showScanMerch(context)),
                    row(context, Icons.language, 'Ubah Bahasa Aplikasi', () => showLanguageDialog(context)),
                  ]),
                ),
                if (li) ...[
                  const H('Pesan', size: 19, pad: EdgeInsets.fromLTRB(16, 16, 16, 8)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: group([
                      row(context, Icons.receipt_long_outlined, 'Riwayat Pesanan', () => push(context, const OrderHistoryPage())),
                      row(context, Icons.account_balance_wallet_outlined, 'Metode Pembayaran', () => push(context, const PaymentMethodsPage())),
                      row(context, Icons.local_drink_outlined, 'Pesanan Jumlah Besar', () => push(context, const BulkOrderPage()), badge: true),
                    ]),
                  ),
                ],
                const H('Kopi Mantan', size: 19, pad: EdgeInsets.fromLTRB(16, 16, 16, 8)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: group([
                    row(context, Icons.help_outline, 'Bantuan', () => push(context, const HelpPage())),
                    row(context, Icons.menu_book_outlined, 'Kebijakan Privasi', () => push(context, InfoTextPage('Kebijakan Privasi', privacyText))),
                    row(context, Icons.info_outline, 'Ketentuan Layanan', () => push(context, InfoTextPage('Ketentuan Layanan', termsText))),
                    row(context, Icons.mail_outline, 'Lapor Masalah', () => push(context, const ReportPage())),
                    row(context, Icons.chat_outlined, 'Layanan WhatsApp', () => info(context, 'Layanan WhatsApp', 'Hubungi kami di WhatsApp 0812-0000-1234, setiap hari 08.00 - 22.00 WIB.')),
                    InkWell(
                      onTap: () => push(context, InfoTextPage('Tentang Kopi Mantan', aboutText)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                        child: Row(children: [HeartLogo(size: 26), SizedBox(width: 14), Expanded(child: Text('Tentang Kopi Mantan', style: TextStyle(fontSize: 16))), Icon(Icons.chevron_right, color: C.gold)]),
                      ),
                    ),
                  ]),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Center(child: Text('Versi Aplikasi 126.10.08', style: TextStyle(color: C.grey, fontWeight: FontWeight.w700)))),
              ]),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.line))),
              child: Row(children: [
                const Icon(Icons.keyboard_double_arrow_right, color: C.gold),
                const SizedBox(width: 12),
                const Expanded(child: Text('Order menggunakan apps')),
                SmallBtn('Ulangi Tutorial', () => showTutorial(context)),
              ]),
            ),
          ]);
        },
      );
}

// ====================== EDIT PROFIL ======================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final nameC = TextEditingController(text: app.user.name);
  late final cityC = TextEditingController(text: app.user.city);
  late String gender = app.user.gender;
  late DateTime? birth = app.user.birth;

  @override
  void dispose() {
    nameC.dispose();
    cityC.dispose();
    super.dispose();
  }

  String fmt(DateTime? d) => d == null ? 'DD / MM / YYYY' : '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}';

  Widget label(String t) => Padding(padding: const EdgeInsets.only(top: 16, bottom: 6), child: Text(t, style: const TextStyle(fontSize: 15)));

  Widget field(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        constraints: const BoxConstraints(minHeight: 54),
        decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.centerLeft,
        child: child,
      );

  Future<void> changePin() async {
    final a = await promptText(context, 'PIN baru (6 digit)', '', kb: TextInputType.number, obscure: true, maxLen: 6);
    if (a == null || !mounted) return;
    if (a.length != 6) {
      toast(context, 'PIN harus 6 digit');
      return;
    }
    final b = await promptText(context, 'Ulangi PIN baru', '', kb: TextInputType.number, obscure: true, maxLen: 6);
    if (b == null || !mounted) return;
    if (a != b) {
      toast(context, 'PIN tidak sama');
      return;
    }
    try {
      await app.changePin(a);
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
      return;
    }
    if (!mounted) return;
    toast(context, 'PIN berhasil diganti');
  }

  @override
  Widget build(BuildContext context) {
    final u = app.user;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarBack('Edit Profil', close: true),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), children: [
            label('Nama'),
            field(TextField(controller: nameC, style: const TextStyle(fontSize: 16), decoration: const InputDecoration(border: InputBorder.none))),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 6),
              child: Row(children: [
                const Text('Email', style: TextStyle(fontSize: 15)),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final v = await promptText(context, 'Ganti Email', u.email, kb: TextInputType.emailAddress, hint: 'nama@email.com');
                    if (v == null) return;
                    final email = v.trim();
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                      if (mounted) toast(context, 'Format email tidak valid');
                      return;
                    }
                    setState(() {
                      u.email = email;
                    });
                  },
                  child: const Text('Ganti Email', style: TextStyle(color: C.red, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            field(Row(children: [
              Expanded(child: Text(u.email.isEmpty ? 'Belum diisi' : u.email, style: TextStyle(fontSize: 16, color: u.email.isEmpty ? C.grey : C.text))),
              if (u.emailVerified) const Icon(Icons.verified, color: Color(0xFF4F9BF0)),
            ])),
            label('Nomor Handphone'),
            field(Row(children: [
              const Icon(Icons.smartphone, size: 24),
              const SizedBox(width: 14),
              Expanded(child: Text(u.phone.isEmpty ? 'Belum diisi' : u.phone, style: TextStyle(fontSize: 16, color: u.phone.isEmpty ? C.grey : C.text))),
              OutlineBox(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                onTap: () async {
                  final v = await promptText(context, 'Ganti Nomor Handphone', u.phone, kb: TextInputType.phone, hint: '08xxxxxxxxxx');
                  if (v == null) return;
                  if (v.length < 9) {
                    if (mounted) toast(context, 'Nomor tidak valid');
                    return;
                  }
                  setState(() => u.phone = v);
                },
                child: const Text('Ganti', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ])),
            const SizedBox(height: 8),
            InkWell(
              onTap: changePin,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
                child: const Row(children: [Icon(Icons.vpn_key_outlined, size: 26), SizedBox(width: 18), Text('Ganti PIN', style: TextStyle(color: C.blue, fontSize: 16))]),
              ),
            ),
            label('Jenis Kelamin'),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                for (final g in ['Wanita', 'Pria', 'Rahasia'])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => gender = g),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(color: gender == g ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: gender == g ? const [BoxShadow(color: Color(0x22000000), blurRadius: 3)] : null),
                        child: Center(child: Text(g, style: const TextStyle(fontWeight: FontWeight.w800))),
                      ),
                    ),
                  ),
              ]),
            ),
            label('Tanggal Lahir'),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: birth ?? DateTime(2000, 1, 1), firstDate: DateTime(1940), lastDate: DateTime.now());
                if (d != null) setState(() => birth = d);
              },
              child: field(Text(fmt(birth), style: TextStyle(fontSize: 16, color: birth == null ? C.grey : C.text))),
            ),
            label('Kota'),
            field(TextField(controller: cityC, style: const TextStyle(fontSize: 16), decoration: const InputDecoration(border: InputBorder.none, hintText: 'Kota domisili'))),
            const Padding(padding: EdgeInsets.only(top: 20), child: Divider()),
            label('Hubungkan akun'),
            Row(children: [
              const CircleAvatar(radius: 30, backgroundColor: Color(0xFFE2E2E2), child: Text('G', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900))),
              const SizedBox(width: 14),
              Text('Google', style: TextStyle(color: u.googleLinked ? C.text : C.grey, fontWeight: FontWeight.w700)),
              const Spacer(),
              SmallBtn(u.googleLinked ? 'Putuskan' : 'Hubungkan', () => setState(() => u.googleLinked = !u.googleLinked), color: u.googleLinked ? C.grey : C.blue),
            ]),
            const SizedBox(height: 26),
            InkWell(
              onTap: () async {
                final ok = await confirm(context, 'Hapus Akun?', 'Semua data, poin, dan voucher akan dihapus permanen.', ok: 'Hapus', danger: true);
                if (!ok || !mounted) return;
                try {
                  await app.deleteAccount();
                } on ApiException catch (e) {
                  if (mounted) toast(context, e.message);
                  return;
                }
                if (!mounted) return;
                Navigator.popUntil(context, (r) => r.isFirst);
                toast(context, 'Akun berhasil dihapus');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
                child: const Row(children: [Icon(Icons.cancel_outlined, color: C.red, size: 28), SizedBox(width: 14), Text('Hapus Akun Kopi Mantan', style: TextStyle(color: C.red, fontSize: 16))]),
              ),
            ),
            InkWell(
              onTap: () async {
                final ok = await confirm(context, 'Logout?', 'Kamu akan keluar dari akun ini.', ok: 'Logout', danger: true);
                if (!ok || !mounted) return;
                app.logout();
                Navigator.popUntil(context, (r) => r.isFirst);
                toast(context, 'Kamu telah keluar');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
                child: const Row(children: [Icon(Icons.logout, size: 28), SizedBox(width: 14), Text('Logout', style: TextStyle(color: C.red, fontSize: 16))]),
              ),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: PrimaryBtn('Simpan Profil', () async {
              if (nameC.text.trim().isEmpty) {
                toast(context, 'Nama tidak boleh kosong');
                return;
              }
              try {
                await app.updateProfile(
                  name: nameC.text.trim(),
                  email: app.user.email,
                  phone: app.user.phone,
                  city: cityC.text.trim(),
                  gender: gender,
                  birth: birth,
                );
              } on ApiException catch (e) {
                if (mounted) toast(context, e.message);
                return;
              }
              if (!mounted) return;
              Navigator.pop(context);
              toast(context, 'Profil berhasil disimpan');
            }),
          ),
        ),
      ]),
    );
  }
}