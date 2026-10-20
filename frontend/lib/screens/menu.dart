import 'package:flutter/material.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';
import 'home.dart';
import 'outlet.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final sc = ScrollController();
  final keys = List.generate(menuCategories.length, (_) => GlobalKey());
  final tabKeys = List.generate(menuCategories.length, (_) => GlobalKey());
  int sel = 0;
  bool jumping = false;

  @override
  void initState() {
    super.initState();
    sc.addListener(_onScroll);
  }

  @override
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (jumping) return;
    int cur = 0;
    for (int i = 0; i < keys.length; i++) {
      final ctx = keys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy <= 200) cur = i;
    }
    if (cur != sel) {
      setState(() => sel = cur);
      final tc = tabKeys[cur].currentContext;
      if (tc != null) Scrollable.ensureVisible(tc, duration: const Duration(milliseconds: 200), alignment: .3);
    }
  }

  Future<void> jump(int i) async {
    setState(() => sel = i);
    final ctx = keys[i].currentContext;
    if (ctx == null) return;
    jumping = true;
    await Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    jumping = false;
  }

  Widget grid(List<Product> list) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: .78,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final p in list)
            LayoutBuilder(
              builder: (_, c) => ProductCard(p, width: c.maxWidth, onTap: () => showProductSheet(context, p)),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          if (app.menuJump != null) {
            final idx = menuCategories.indexOf(app.menuJump!);
            app.menuJump = null;
            if (idx >= 0) WidgetsBinding.instance.addPostFrameCallback((_) => jump(idx));
          }
          return Column(children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFE6E9F8), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    onTap: () => push(context, OutletPage(initialTab: app.orderMode == 'Delivery' ? 1 : 0)),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(app.orderMode == 'Delivery' ? app.locationTitle : (app.outletChosen ? '${app.orderMode}: ${app.outlet.name}' : 'Pilih Outlet'),
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          Text(app.locationSub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.grey, fontSize: 12)),
                        ]),
                      ),
                      const Icon(Icons.expand_circle_down_outlined, color: C.red, size: 24),
                    ]),
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))]),
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: menuCategories.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (_, i) => GestureDetector(
                  key: tabKeys[i],
                  onTap: () => jump(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: sel == i ? C.gold : Colors.transparent, width: 3))),
                    child: Text(catLabel(menuCategories[i]), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: sel == i ? C.gold : C.text)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Row(children: [
                      Icon(Icons.discount, color: C.green, size: 26),
                      SizedBox(width: 8),
                      Text('Diskon & Cashback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  claimStrip(),
                  // Promo & Combo (horizontal)
                  Container(key: keys[0], child: const H('Promo & Combo', size: 19)),
                  SizedBox(
                    height: 195,
                    child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 16), children: [
                      for (final p in allProducts.where((p) => p.category == 'Promo & Combo'))
                        Padding(padding: const EdgeInsets.only(right: 14), child: ProductCard(p, pill: true, onTap: () => showProductSheet(context, p))),
                    ]),
                  ),
                  for (int i = 1; i < menuCategories.length; i++) ...[
                    Container(key: keys[i], child: H(catLabel(menuCategories[i]), size: 19, pad: const EdgeInsets.fromLTRB(16, 24, 16, 10))),
                    grid(allProducts.where((p) => p.category == menuCategories[i]).toList()),
                  ],
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ]);
        },
      );
}
