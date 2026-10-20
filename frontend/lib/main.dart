import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'api.dart';
import 'state.dart';
import 'widgets.dart';
import 'screens/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProductAssets.load();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const KopiMantanApp());
}

/// Memuat sesi login dan katalog dari server. Berjalan di balik layar splash.
Future<void> _bootstrap() async {
  await Api.loadToken();
  await app.restoreSession();
  await app.loadCatalog();
}

class KopiMantanApp extends StatelessWidget {
  const KopiMantanApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Kopi Mantan',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const SplashPage(),
      );
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))..forward();

  @override
  void initState() {
    super.initState();
    // Splash tampil minimal 2,6 detik; sambil menunggu, data dimuat dari server.
    Future.wait<void>([
      Future<void>.delayed(const Duration(milliseconds: 2600)),
      _bootstrap().catchError((_) {}),
    ]).timeout(const Duration(seconds: 10), onTimeout: () => const <void>[]).then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Shell(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(painter: KopiLogoPainter(C.red, progress: _c.value)),
            ),
          ),
        ),
      );
}