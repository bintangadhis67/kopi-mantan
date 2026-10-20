import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets.dart';

/// Banner notifikasi yang meluncur dari atas layar (seperti notifikasi pesan masuk),
/// tampil beberapa detik lalu hilang sendiri. Bisa ditutup dengan ketuk atau geser ke atas.
void showTopBanner(
  BuildContext context, {
  required String sender,
  required String message,
  Duration duration = const Duration(seconds: 5),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  var removed = false;
  entry = OverlayEntry(
    builder: (_) => _TopBanner(
      sender: sender,
      message: message,
      duration: duration,
      onDone: () {
        if (removed) return;
        removed = true;
        entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _TopBanner extends StatefulWidget {
  final String sender, message;
  final Duration duration;
  final VoidCallback onDone;
  const _TopBanner({required this.sender, required this.message, required this.duration, required this.onDone});

  @override
  State<_TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<_TopBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, -1.4), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future.delayed(widget.duration, _close);
  }

  Future<void> _close() async {
    if (_closing || !mounted) return;
    _closing = true;
    await _c.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _c,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, top + 8, 12, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: GestureDetector(
                  onTap: _close,
                  onVerticalDragEnd: (d) {
                    if ((d.primaryVelocity ?? 0) < 0) _close();
                  },
                  child: Material(
                    color: Colors.white,
                    elevation: 10,
                    shadowColor: const Color(0x55000000),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(9)),
                          child: const Center(child: HeartLogo(size: 24, color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(
                                child: Text(widget.sender,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87)),
                              ),
                              const Text('sekarang', style: TextStyle(fontSize: 12, color: Colors.black45)),
                            ]),
                            const SizedBox(height: 2),
                            Text(widget.message, style: const TextStyle(fontSize: 13.5, height: 1.3, color: Colors.black87)),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}