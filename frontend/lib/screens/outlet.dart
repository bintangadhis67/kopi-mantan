import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';

class OutletPage extends StatefulWidget {
  final int initialTab; // 0 pickup, 1 delivery
  final bool goMenu;
  const OutletPage({super.key, this.initialTab = 0, this.goMenu = false});
  @override
  State<OutletPage> createState() => _OutletPageState();
}

class _OutletPageState extends State<OutletPage> {
  late int tab = widget.initialTab;
  String q = '';
  String orderF = 'Semua Order';
  String brandF = 'Semua Brand';

  void finish() {
    Navigator.pop(context);
    if (widget.goMenu) app.goTab(1);
  }

  Widget topTab(String label, int i, Color c) => Expanded(
        child: InkWell(
          onTap: () => setState(() {
            tab = i;
            q = '';
          }),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: tab == i ? c : C.grey)),
            ),
            Container(height: 3, width: 60, decoration: BoxDecoration(color: tab == i ? c : Colors.transparent, borderRadius: BorderRadius.circular(3))),
          ]),
        ),
      );

  Widget chip(String label, bool sel, VoidCallback on, {Widget? lead, Color selColor = C.red}) => Padding(
        padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
        child: GestureDetector(
          onTap: on,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: sel ? selColor : C.line, width: 1.8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (lead != null) ...[lead, const SizedBox(width: 6)],
              Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: sel ? selColor : C.text)),
            ]),
          ),
        ),
      );

  Widget search(String hint) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(30)),
          child: TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: const Icon(Icons.search, size: 26),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 17),
            ),
          ),
        ),
      );

  Widget dot(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 11, height: 11, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c, width: 2))),
        const SizedBox(width: 4),
        Text(t, style: const TextStyle(fontSize: 12)),
      ]);

  Widget pickupTab() {
    final list = outlets.where((o) {
      if (q.isNotEmpty && !('${o.name} ${o.address}'.toLowerCase().contains(q.toLowerCase()))) return false;
      if (orderF == 'Pickup' && !o.pickup) return false;
      if (orderF == 'Drive Thru' && !o.drive) return false;
      if (orderF == 'Dine-In' && o.drive) return false;
      if (brandF == 'Chigo x Flip') return false;
      return true;
    }).toList();
    return Column(children: [
      search('Cari lokasi'),
      SizedBox(
        height: 48,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          for (final f in ['Semua Order', 'Pickup', 'Drive Thru', 'Dine-In'])
            chip(f, orderF == f, () => setState(() => orderF = f),
                lead: f == 'Semua Order'
                    ? null
                    : Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: f == 'Dine-In' ? const Color(0xFF6B4EBB) : C.teal, width: 4)))),
        ]),
      ),
      SizedBox(
        height: 48,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          for (final f in ['Semua Brand', 'Chigo x Flip', 'Kopi Mantan'])
            chip(f, brandF == f, () => setState(() => brandF = f),
                lead: f == 'Semua Brand' ? null : (f == 'Kopi Mantan' ? const HeartLogo(size: 24) : const Icon(Icons.fastfood, color: Colors.amber, size: 24))),
        ]),
      ),
      const Divider(height: 12),
      Expanded(
        child: list.isEmpty
            ? const Center(child: Text('Outlet tidak ditemukan', style: TextStyle(color: C.grey)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final o = list[i];
                  final sel = app.outletChosen && app.outlet.name == o.name;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: sel ? Border.all(color: C.red, width: 2) : null,
                      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        app.selectOutlet(o);
                        finish();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6)]),
                              child: const Center(child: HeartLogo(size: 30)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(o.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 3),
                                Text(o.address, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.grey, fontSize: 13, height: 1.3)),
                              ]),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFE6F0FB), borderRadius: BorderRadius.circular(6)),
                              child: Text(o.distance, style: const TextStyle(color: C.blue, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: C.line),
                          const SizedBox(height: 10),
                          Row(children: [
                            if (o.delivery) dot(C.green, 'Delivery'),
                            if (o.delivery) const SizedBox(width: 10),
                            if (o.pickup) dot(C.teal, 'Pickup'),
                            if (o.drive) ...[const SizedBox(width: 10), dot(const Color(0xFF6B4EBB), 'Drive Thru')],
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _detail(o),
                              child: const Row(children: [
                                Text('Detail', style: TextStyle(color: C.blue, fontWeight: FontWeight.w800, fontSize: 15)),
                                Icon(Icons.chevron_right, color: C.blue, size: 22),
                              ]),
                            ),
                          ]),
                        ]),
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  void _detail(Outlet o) {
    sheet(context, (ctx) => SheetFrame(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const HeartLogo(size: 30), const SizedBox(width: 10), Expanded(child: Text(o.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)))]),
              const SizedBox(height: 12),
              Text(o.address, style: const TextStyle(color: C.grey)),
              const SizedBox(height: 10),
              Row(children: [const Icon(Icons.access_time, size: 18), const SizedBox(width: 8), Text('Buka ${o.hours}')]),
              const SizedBox(height: 6),
              Row(children: [const Icon(Icons.near_me, size: 18), const SizedBox(width: 8), Text('${o.distance} dari lokasimu')]),
              const SizedBox(height: 16),
              PrimaryBtn('Pilih Outlet', () {
                app.selectOutlet(o);
                Navigator.pop(ctx);
                finish();
              }),
            ]),
          ),
        ));
  }

  // ---------- delivery ----------
  void editAddr(Addr? a) {
    final l = TextEditingController(text: a?.label ?? '');
    final d = TextEditingController(text: a?.detail ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(a == null ? 'Tambah Alamat' : 'Ubah Alamat', style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: l, decoration: const InputDecoration(labelText: 'Label (mis. Rumah)')),
          TextField(controller: d, maxLines: 3, minLines: 1, decoration: const InputDecoration(labelText: 'Alamat lengkap')),
        ]),
        actions: [
          if (a != null)
            TextButton(
                onPressed: () async {
                  final nav = Navigator.of(ctx);
                  try {
                    await app.removeAddress(a);
                  } on ApiException catch (e) {
                    if (mounted) toast(context, e.message);
                    return;
                  }
                  nav.pop();
                  if (mounted) setState(() {});
                },
                child: const Text('Hapus', style: TextStyle(color: C.red))),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
              onPressed: () async {
                if (l.text.trim().isEmpty || d.text.trim().isEmpty) return;
                final nav = Navigator.of(ctx);
                try {
                  if (a == null) {
                    await app.addAddress(l.text.trim(), d.text.trim());
                  } else {
                    await app.updateAddress(a, l.text.trim(), d.text.trim());
                  }
                } on ApiException catch (e) {
                  if (mounted) toast(context, e.message);
                  return;
                }
                nav.pop();
                if (mounted) setState(() {});
              },
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  void mapPicker() {
    Offset? pin;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          contentPadding: const EdgeInsets.all(12),
          title: const Text('Pilih lokasi di peta', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          content: GestureDetector(
            onTapDown: (d) => setS(() => pin = d.localPosition),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(color: const Color(0xFFE8EFE4), borderRadius: BorderRadius.circular(10)),
              child: Stack(children: [
                CustomPaint(size: const Size(280, 280), painter: _MapPainter()),
                if (pin != null) Positioned(left: pin!.dx - 16, top: pin!.dy - 32, child: const Icon(Icons.location_on, color: C.red, size: 32)),
                if (pin == null) const Center(child: Text('Ketuk peta untuk menaruh pin', style: TextStyle(color: C.grey))),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            TextButton(
                onPressed: pin == null
                    ? null
                    : () async {
                        final lat = -7.25 + (pin!.dy / 280) * -0.02;
                        final lng = 112.73 + (pin!.dx / 280) * 0.02;
                        final nav = Navigator.of(ctx);
                        try {
                          final a = await app.addAddress('Titik peta', 'Koordinat ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}, Surabaya');
                          app.selectAddress(a);
                        } on ApiException catch (e) {
                          if (mounted) toast(context, e.message);
                          return;
                        }
                        nav.pop();
                        finish();
                      },
                child: const Text('Pilih lokasi ini', style: TextStyle(fontWeight: FontWeight.w800))),
          ],
        ),
      ),
    );
  }

  Widget deliveryTab() {
    final list = app.addresses.where((a) => q.isEmpty || '${a.label} ${a.detail}'.toLowerCase().contains(q.toLowerCase())).toList();
    return Column(children: [
      search('Cari alamat'),
      SizedBox(
        height: 48,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          for (final f in ['Semua Brand', 'Kopi Mantan', 'Chigo'])
            chip(f, brandF == f, () => setState(() => brandF = f),
                lead: f == 'Semua Brand' ? null : (f == 'Kopi Mantan' ? const HeartLogo(size: 24) : const Icon(Icons.fastfood, color: Colors.amber, size: 22))),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(children: [
          Expanded(
            child: OutlineBox(
              onTap: () {
                final a = Addr('Lokasi saat ini', 'Jl. Ahmad Yani, Wonokromo, Surabaya (berdasarkan GPS)');
                app.selectAddress(a);
                finish();
              },
              child: const Row(children: [
                CircleAvatar(radius: 14, backgroundColor: Color(0xFFE3F3E4), child: Icon(Icons.location_on, color: C.green, size: 18)),
                SizedBox(width: 10),
                Text('Gunakan lokasi saat ini', style: TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(onPressed: mapPicker, icon: const Icon(Icons.map_outlined, size: 30)),
        ]),
      ),
      Expanded(
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          for (final a in list)
            Column(children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  app.selectAddress(a);
                  finish();
                },
                leading: const CircleAvatar(radius: 24, backgroundColor: Color(0xFFF3E9DD), child: Icon(Icons.bookmark, color: C.gold)),
                title: Text(a.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(a.detail, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: IconButton(onPressed: () => editAddr(a), icon: const Icon(Icons.edit_note, color: C.blue, size: 28)),
              ),
              const Divider(height: 1),
            ]),
          TextButton.icon(onPressed: () => editAddr(null), icon: const Icon(Icons.add), label: const Text('Tambah alamat baru', style: TextStyle(fontWeight: FontWeight.w700))),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          title: Row(children: [topTab('Pickup', 0, C.teal), topTab('Delivery', 1, const Color(0xFF8DC572))]),
          centerTitle: true,
          titleSpacing: 0,
          toolbarHeight: 60,
          shape: const Border(bottom: BorderSide(color: C.line)),
        ),
        body: tab == 0 ? pickupTab() : deliveryTab(),
      );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final road = Paint()..color = Colors.white..strokeWidth = 10;
    final thin = Paint()..color = const Color(0xFFD5DECF)..strokeWidth = 2;
    for (double i = 20; i < s.width; i += 40) {
      c.drawLine(Offset(i, 0), Offset(i, s.height), thin);
      c.drawLine(Offset(0, i), Offset(s.width, i), thin);
    }
    c.drawLine(Offset(0, s.height * .35), Offset(s.width, s.height * .6), road);
    c.drawLine(Offset(s.width * .3, 0), Offset(s.width * .55, s.height), road);
    c.drawCircle(Offset(s.width * .8, s.height * .2), 28, Paint()..color = const Color(0xFFBFD9F2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}