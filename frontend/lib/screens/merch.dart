import 'package:flutter/material.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';

class MerchPage extends StatelessWidget {
  const MerchPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: Column(children: [
          const SizedBox(height: 56, child: Center(child: Text('Merchandise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)))),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [C.maroon, C.red]), borderRadius: BorderRadius.circular(14)),
            child: const Row(children: [
              HeartLogo(size: 40, color: Colors.white),
              SizedBox(width: 14),
              Expanded(child: Text('Koleksi merch Kopi Mantan.\nGratis engrave untuk tumbler!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
            ]),
          ),
          Expanded(
            child: GridView.count(
              // Sama persis dengan grid di halaman Menu.
              crossAxisCount: 2,
              childAspectRatio: .78,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                for (final p in merchProducts)
                  LayoutBuilder(
                    builder: (_, c) => ProductCard(p, width: c.maxWidth, onTap: () => showProductSheet(context, p)),
                  ),
              ],
            ),
          ),
        ]),
      );
}