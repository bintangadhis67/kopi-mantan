import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'state.dart';

Future<T?> push<T>(BuildContext c, Widget page) =>
    Navigator.of(c).push<T>(MaterialPageRoute(builder: (_) => page));

void toast(BuildContext c, String msg) {
  final m = ScaffoldMessenger.of(c);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(msg),
    behavior: SnackBarBehavior.floating,
    backgroundColor: const Color(0xFF333333),
    duration: const Duration(seconds: 2),
  ));
}

Future<bool> confirm(BuildContext c, String title, String msg,
    {String ok = 'Ya', String cancel = 'Batal', bool danger = false}) async {
  final r = await showDialog<bool>(
    context: c,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(cancel, style: const TextStyle(color: C.grey))),
        TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(ok, style: TextStyle(color: danger ? C.red : C.blue, fontWeight: FontWeight.w700))),
      ],
    ),
  );
  return r ?? false;
}

Future<void> info(BuildContext c, String title, String msg) => showDialog(
      context: c,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
      ),
    );

// ---------- tombol ----------
class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double height;
  final Widget? leading;
  const PrimaryBtn(this.label, this.onTap,
      {super.key, this.color = C.red, this.height = 50, this.leading});
  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? color : const Color(0xFFDFDFDF),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Text(label,
                style: TextStyle(
                    color: enabled ? Colors.white : C.grey, fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
        ),
      ),
    );
  }
}

class SmallBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const SmallBtn(this.label, this.onTap, {super.key, this.color = C.red});
  @override
  Widget build(BuildContext context) => Material(
        color: color,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
      );
}

class OutlineBox extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color border;
  final Color fill;
  final EdgeInsets padding;
  const OutlineBox(
      {super.key,
      required this.child,
      this.onTap,
      this.border = C.gold,
      this.fill = Colors.white,
      this.padding = const EdgeInsets.all(10)});
  @override
  Widget build(BuildContext context) => Material(
        color: fill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: border, width: 1.6)),
        child: InkWell(borderRadius: BorderRadius.circular(8), onTap: onTap, child: Padding(padding: padding, child: child)),
      );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(12),
      this.margin = EdgeInsets.zero,
      this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      );
}

class H extends StatelessWidget {
  final String text;
  final double size;
  final EdgeInsets pad;
  const H(this.text, {super.key, this.size = 20, this.pad = const EdgeInsets.fromLTRB(16, 18, 16, 10)});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: pad, child: Text(text, style: TextStyle(fontSize: size, fontWeight: FontWeight.w800)));
}

class AppBarBack extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? bg;
  final bool close;
  const AppBarBack(this.title, {super.key, this.actions, this.bg, this.close = false});
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: bg ?? Colors.white,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(close ? Icons.close : Icons.arrow_back, size: 24), onPressed: () => Navigator.maybePop(context)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: actions,
      );
}

// ---------- gambar produk ----------
class HeartPainter extends CustomPainter {
  final Color color;
  final bool striped;
  HeartPainter(this.color, {this.striped = false});
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final p = Path()
      ..moveTo(w * .5, h * .95)
      ..cubicTo(w * -.15, h * .5, w * .1, h * -.05, w * .5, h * .28)
      ..cubicTo(w * .9, h * -.05, w * 1.15, h * .5, w * .5, h * .95)
      ..close();
    c.drawPath(p, Paint()..color = color);
    if (striped) {
      c.save();
      c.clipPath(p);
      final lp = Paint()..color = Colors.white..strokeWidth = w * .06;
      for (double x = -h; x < w + h; x += w * .16) {
        c.drawLine(Offset(x, h), Offset(x + h * .6, 0), lp);
      }
      c.restore();
    }
  }

  @override
  bool shouldRepaint(covariant HeartPainter o) => o.color != color;
}

/// Logo Kopi Mantan: cangkir dengan tutup merah dan hati. Digambar sebagai vektor,
/// jadi tetap tajam di ukuran berapa pun dan warnanya bisa diganti.
class KopiLogoPainter extends CustomPainter {
  final Color color;

  /// 0..1. Nilai 1 = logo utuh (default). Dipakai untuk animasi splash: garis cangkir
  /// tergambar bertahap, tutup merah jatuh dengan pantulan, lalu hati kecil membesar.
  final double progress;
  KopiLogoPainter(this.color, {this.progress = 1.0});

  static const double _w = 696, _h = 852; // ukuran bidang gambar logo

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / _w, size.height / _h);
    canvas.save();
    canvas.translate((size.width - _w * s) / 2, (size.height - _h * s) / 2);
    canvas.scale(s);

    // Di ukuran kecil, goresan ditebalkan agar tetap terlihat (minimal sekitar 1,1 piksel).
    double stroke(double w) => math.max(w, 1.1 / s);
    Paint line(double w) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = stroke(w);

    final dome = Path()
      ..moveTo(190, 126)
      ..cubicTo(240, 90, 300, 80, 345, 82)
      ..cubicTo(430, 85, 495, 125, 512, 180);
    final body = Path()
      ..moveTo(176, 372)
      ..lineTo(210, 690)
      ..cubicTo(220, 745, 255, 772, 310, 772)
      ..lineTo(395, 772)
      ..cubicTo(450, 772, 488, 745, 498, 690)
      ..lineTo(528, 312);
    final heart = Path()
      ..moveTo(380, 624)
      ..lineTo(300, 568)
      ..cubicTo(255, 530, 232, 490, 258, 452)
      ..cubicTo(282, 420, 332, 430, 354, 470)
      ..cubicTo(376, 430, 430, 418, 456, 452)
      ..cubicTo(478, 484, 462, 524, 420, 560)
      ..lineTo(380, 598);
    final band = Path()
      ..moveTo(96, 170)
      ..cubicTo(84, 170, 78, 182, 78, 208)
      ..lineTo(78, 242)
      ..cubicTo(78, 286, 130, 318, 215, 320)
      ..lineTo(470, 320)
      ..cubicTo(560, 318, 612, 290, 612, 242)
      ..lineTo(612, 208)
      ..cubicTo(612, 182, 606, 170, 594, 170)
      ..lineTo(540, 172)
      ..cubicTo(525, 174, 515, 176, 500, 184)
      ..cubicTo(470, 198, 430, 203, 380, 203)
      ..lineTo(300, 203)
      ..cubicTo(250, 203, 205, 201, 160, 194)
      ..cubicTo(130, 187, 115, 172, 96, 170)
      ..close();
    final smallHeart = Path()
      ..moveTo(360, 580)
      ..cubicTo(334, 558, 304, 538, 306, 512)
      ..cubicTo(308, 490, 340, 486, 360, 508)
      ..cubicTo(380, 484, 414, 490, 416, 514)
      ..cubicTo(418, 538, 388, 558, 360, 580)
      ..close();

    // Tahap animasi: seg(a, b) = kemajuan 0..1 antara progress a dan b.
    double seg(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
        curve.transform(math.min(1.0, math.max(0.0, (progress - a) / (b - a))));

    // Gambar goresan secara bertahap (sebagian panjang jalur).
    void strokeIn(Path p, double w, double a, double b) {
      final t = seg(a, b);
      if (t <= 0) return;
      if (t >= 1) {
        canvas.drawPath(p, line(w));
        return;
      }
      final part = Path();
      for (final m in p.computeMetrics()) {
        part.addPath(m.extractPath(0, m.length * t), Offset.zero);
      }
      canvas.drawPath(part, line(w));
    }

    strokeIn(body, 15, 0.00, 0.40);
    strokeIn(dome, 13, 0.50, 0.75);
    strokeIn(heart, 10, 0.55, 0.85);

    // Tutup merah jatuh dari atas dengan sedikit pantulan.
    final bt = seg(0.30, 0.62, Curves.easeOutBack);
    if (bt > 0) {
      final fade = math.min(1.0, math.max(0.0, (progress - 0.30) / 0.12));
      canvas.save();
      canvas.translate(0, -140 * (1 - bt));
      canvas.drawPath(band, Paint()..color = color.withOpacity(fade));
      canvas.restore();
    }

    // Hati kecil membesar dengan efek memantul.
    final ht = seg(0.78, 1.0, Curves.elasticOut);
    if (ht > 0) {
      canvas.save();
      canvas.translate(360, 535);
      canvas.scale(ht);
      canvas.translate(-360, -535);
      canvas.drawPath(smallHeart, Paint()..color = color.withOpacity(.9));
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant KopiLogoPainter o) => o.color != color || o.progress != progress;
}

/// Logo aplikasi. [size] adalah tinggi dan lebar kotak; logo digambar di tengahnya.
class HeartLogo extends StatelessWidget {
  final double size;
  final Color color;
  const HeartLogo({super.key, this.size = 28, this.color = C.red});
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: KopiLogoPainter(color)));
}

class CupPainter extends CustomPainter {
  final Color color;
  CupPainter(this.color);
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    c.drawLine(Offset(w * .56, h * .0), Offset(w * .5, h * .3),
        Paint()..color = const Color(0xFF333333)..strokeWidth = w * .035..strokeCap = StrokeCap.round);
    final body = Path()
      ..moveTo(w * .2, h * .3)
      ..lineTo(w * .8, h * .3)
      ..lineTo(w * .7, h * .97)
      ..lineTo(w * .3, h * .97)
      ..close();
    c.drawShadow(body, Colors.black45, 3, false);
    c.drawPath(
        body,
        Paint()
          ..shader = LinearGradient(
                  colors: [color.withOpacity(.55), color],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)
              .createShader(Rect.fromLTWH(0, 0, w, h)));
    // foam / cloud
    final foam = Path()
      ..moveTo(w * .2, h * .3)
      ..quadraticBezierTo(w * .5, h * .5, w * .8, h * .3)
      ..close();
    c.drawPath(foam, Paint()..color = Colors.white.withOpacity(.75));
    // lid
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .15, h * .22, w * .7, h * .09), Radius.circular(w * .04)),
        Paint()..color = const Color(0xFFF4F4F4));
    // logo heart
    c.save();
    c.translate(w * .39, h * .5);
    final hs = Size(w * .22, w * .22);
    HeartPainter(C.red, striped: true).paint(c, hs);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CupPainter o) => o.color != color;
}

IconData _iconFor(Product p) {
  switch (p.id) {
    case 'm1':
      return Icons.local_drink;
    case 'm2':
      return Icons.shopping_bag;
    case 'm3':
      return Icons.coffee;
    case 'm4':
      return Icons.checkroom;
  }
  if (p.category.contains('Toast')) return Icons.bakery_dining;
  return Icons.lunch_dining;
}

/// Menghubungkan nama produk ke file gambar di folder assets/images/.
/// Contoh: produk "Crispy Chicken Burger" memakai file crispy_chicken_burger.png
/// (huruf besar/kecil, spasi, dan tanda _ diabaikan; format png/jpg/jpeg/webp).
class ProductAssets {
  static Map<String, String> _files = {};

  static String _key(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Panggil sekali di main() sebelum runApp.
  static Future<void> load() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      const prefix = 'assets/images/';
      final map = <String, String>{};
      for (final path in manifest.listAssets()) {
        if (!path.startsWith(prefix)) continue;
        final file = path.substring(prefix.length);
        final dot = file.lastIndexOf('.');
        if (dot <= 0) continue;
        final ext = file.substring(dot + 1).toLowerCase();
        if (ext != 'png' && ext != 'jpg' && ext != 'jpeg' && ext != 'webp') continue;
        map[_key(file.substring(0, dot))] = path;
      }
      _files = map;
    } catch (_) {
      _files = {};
    }
  }

  static String? pathFor(String productName) => _files[_key(productName)];
}

class ProductImage extends StatelessWidget {
  final Product p;
  final double size;
  final BoxFit fit;
  final double radius;
  const ProductImage(this.p, {super.key, this.size = 100, this.fit = BoxFit.cover, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    // Tampilan bawaan (digambar lewat kode), dipakai kalau file gambar belum ada.
    final Widget fallback = p.drink
        ? SizedBox(width: size, height: size, child: CustomPaint(painter: CupPainter(p.color)))
        : Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: p.color.withOpacity(.25)),
            child: Icon(_iconFor(p), size: size * .5, color: p.color),
          );

    final path = ProductAssets.pathFor(p.name);
    if (path == null) return fallback;

    // Batas ukuran decode (sisi terpanjang) supaya gambar 700 KB tidak membebani memori.
    final bound = (size * MediaQuery.of(context).devicePixelRatio * 1.5).round();
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image(
          image: ResizeImage(AssetImage(path), width: bound, height: bound, policy: ResizeImagePolicy.fit),
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stack) {
            // Catat penyebab gagalnya supaya terlihat di konsol (debug).
            debugPrint('ProductImage gagal (resize) untuk "${p.name}" -> $path : $error');
            // Coba lagi tanpa ResizeImage sebelum menyerah ke gambar bawaan.
            return Image.asset(
              path,
              width: size,
              height: size,
              fit: fit,
              errorBuilder: (context, error2, stack2) {
                debugPrint('ProductImage gagal (asli) untuk "${p.name}" -> $path : $error2');
                return fallback;
              },
            );
          },
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  const Tag(this.text, {super.key, this.color = const Color(0xFF3FAE5A)});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

class PricePill extends StatelessWidget {
  final int price;
  const PricePill(this.price, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: C.redSoft, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.discount, size: 14, color: C.red),
          const SizedBox(width: 4),
          Text(rp(price), style: const TextStyle(color: C.red, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      );
}

class ProductCard extends StatelessWidget {
  final Product p;
  final double width;
  final bool pill;
  final VoidCallback onTap;
  const ProductCard(this.p, {super.key, required this.onTap, this.width = 130, this.pill = false});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(alignment: Alignment.bottomLeft, children: [
              Center(child: ProductImage(p, size: width * .85)),
              if (p.badge != null && p.badge != 'GRATIS UPSIZE') Tag(p.badge!),
            ]),
            const SizedBox(height: 6),
            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            if (pill)
              PricePill(p.price)
            else
              Text(rp(p.price), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.grey)),
          ]),
        ),
      );
}

// ---------- cart bar ----------
class CartBar extends StatelessWidget {
  final VoidCallback onTap;
  const CartBar({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          if (app.cart.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Material(
              color: C.red,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${app.cartCount} produk', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        Text(rp(app.subtotal), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                      ]),
                    ),
                    const Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 30),
                  ]),
                ),
              ),
            ),
          );
        },
      );
}

// ---------- bottom sheet util ----------
Future<T?> sheet<T>(BuildContext c, WidgetBuilder b, {bool dark = false}) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: b,
    );

class SheetFrame extends StatelessWidget {
  final Widget child;
  final bool closeBtn;
  const SheetFrame({super.key, required this.child, this.closeBtn = true});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (closeBtn)
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 22),
                  ),
                ),
              ),
            ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
            child: SafeArea(top: false, child: child),
          ),
        ]),
      );
}

// ---------- sheet detail produk ----------
Future<void> showProductSheet(BuildContext context, Product p, {CartItem? edit}) =>
    sheet(context, (ctx) => _ProductSheet(p: p, edit: edit, parent: context));

class _ProductSheet extends StatefulWidget {
  final Product p;
  final CartItem? edit;
  final BuildContext parent;
  const _ProductSheet({required this.p, this.edit, required this.parent});
  @override
  State<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<_ProductSheet> {
  late String size, ice, sugar;
  late int qty;
  late TextEditingController noteC;

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    size = e?.size ?? (widget.p.id == 'c1' ? 'Large' : 'Regular');
    ice = e?.ice ?? 'Normal Ice';
    sugar = e?.sugar ?? 'Normal Sugar';
    qty = e?.qty ?? 1;
    noteC = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    noteC.dispose();
    super.dispose();
  }

  Widget opts(String title, List<String> items, String cur, void Function(String) on, {Map<String, String>? extra}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final i in items)
            GestureDetector(
              onTap: () => setState(() => on(i)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: cur == i ? C.redSoft : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cur == i ? C.red : C.line, width: 1.4),
                ),
                child: Text('$i${extra?[i] ?? ''}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: cur == i ? C.red : C.text)),
              ),
            ),
        ]),
      ]);

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final edit = widget.edit;
    final unit = p.price + (p.drink && size == 'Large' ? 4000 : 0);
    return SheetFrame(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .85),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ProductImage(p, size: 96),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(rp(unit), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: C.red)),
                      const SizedBox(height: 6),
                      Text(p.desc, style: const TextStyle(color: C.grey, fontSize: 13)),
                    ]),
                  ),
                ]),
                if (p.drink) ...[
                  opts('Ukuran', ['Regular', 'Large'], size, (v) => size = v, extra: {'Large': ' (+Rp4.000)'}),
                  opts('Es', ['Normal Ice', 'Less Ice', 'No Ice'], ice, (v) => ice = v),
                  opts('Gula', ['Normal Sugar', 'Less Sugar', 'No Sugar'], sugar, (v) => sugar = v),
                ],
                const SizedBox(height: 14),
                const Text('Catatan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteC,
                  decoration: InputDecoration(
                    hintText: 'Contoh: jangan terlalu manis',
                    filled: true,
                    fillColor: C.field,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: Row(children: [
              IconButton(
                  onPressed: qty > 1 ? () => setState(() => qty--) : null,
                  icon: Icon(Icons.remove_circle_outline, color: qty > 1 ? C.gold : C.line, size: 32)),
              Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              IconButton(
                  onPressed: () => setState(() => qty++),
                  icon: const Icon(Icons.add_circle_outline, color: C.gold, size: 32)),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryBtn(edit == null ? 'Tambah - ${rp(unit * qty)}' : 'Simpan - ${rp(unit * qty)}', () {
                  final item = CartItem(p,
                      size: p.drink ? size : 'Regular', ice: ice, sugar: sugar, note: noteC.text.trim(), qty: qty);
                  if (edit != null) {
                    app.replaceItem(edit, item);
                  } else {
                    app.addToCart(item);
                  }
                  Navigator.pop(context);
                  toast(widget.parent, edit == null ? '${p.name} ditambahkan ke keranjang' : 'Pesanan diperbarui');
                }),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}