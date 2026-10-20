import 'package:flutter/material.dart';
import '../api.dart';
import '../top_banner.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';

/// Menampilkan sheet login. Mengembalikan true bila login berhasil.
Future<bool> showLoginSheet(BuildContext context) async {
  final r = await sheet<bool>(context, (_) => _LoginSheet(parent: context));
  return r ?? false;
}

class _LoginSheet extends StatefulWidget {
  final BuildContext parent;
  const _LoginSheet({required this.parent});
  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  // stage: phone, otp
  String stage = 'phone';
  final phoneC = TextEditingController();
  final otpC = TextEditingController();
  bool busy = false;
  String? err;

  @override
  void dispose() {
    phoneC.dispose();
    otpC.dispose();
    super.dispose();
  }

  /// Jalankan proses login ke API; tampilkan error bila gagal.
  Future<void> run(Future<void> Function() job) async {
    if (busy) return;
    setState(() {
      busy = true;
      err = null;
    });
    try {
      await job();
      if (!mounted) return;
      done();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => err = e.message);
      toast(context, e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// Banner pesan masuk berisi kode OTP (meluncur dari atas layar).
  void showOtpBanner() => showTopBanner(
        context,
        sender: 'KOPI MANTAN',
        message: 'Kode OTP kamu: 1234. Jangan berikan kode ini kepada siapa pun, termasuk pihak Kopi Mantan.',
      );

  void done() {
    Navigator.pop(context, true);
    toast(widget.parent, 'Berhasil masuk. Selamat datang!');
  }

  Widget phoneStage() {
    final ok = phoneC.text.trim().length >= 9;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Masuk / Daftar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        const SizedBox(height: 4),
        const Text('Masukkan nomor handphone untuk masuk atau daftar akun Kopi Mantan.', style: TextStyle(color: C.grey)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            const Text('+62', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: phoneC,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (_) => setState(() => err = null),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Nomor Handphone', hintStyle: TextStyle(color: Color(0xFFC8C8C8))),
              ),
            ),
          ]),
        ),
        if (err != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(err!, style: const TextStyle(color: C.red, fontSize: 12))),
        const SizedBox(height: 12),
        PrimaryBtn('Lanjut Konfirmasi', ok
            ? () async {
                var n = phoneC.text.trim();
                if (n.startsWith('0')) n = n.substring(1);
                if (n.startsWith('62')) n = n.substring(2);
                phoneC.text = n;
                try {
                  await Api.post('/auth/otp/request', {'phone': n});
                } on ApiException catch (e) {
                  if (mounted) setState(() => err = e.message);
                  return;
                }
                if (!mounted) return;
                setState(() => stage = 'otp');
                showOtpBanner();
              }
            : null),
        const SizedBox(height: 12),
        Row(children: const [
          Expanded(child: Divider()),
          Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Text('ATAU', style: TextStyle(color: C.grey))),
          Expanded(child: Divider()),
        ]),
        const SizedBox(height: 12),
        PrimaryBtn('Lanjutkan dengan Apple', () {
          run(() => app.loginSocial('apple'));
        }, color: Colors.black, height: 52, leading: const Icon(Icons.apple, color: Colors.white)),
        const SizedBox(height: 8),
        PrimaryBtn('Lanjutkan dengan Google', () {
          run(() => app.loginSocial('google'));
        }, color: C.blue, height: 52, leading: const Icon(Icons.g_mobiledata, color: Colors.white, size: 30)),
      ]),
    );
  }

  Widget otpStage() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => setState(() => stage = 'phone'), icon: const Icon(Icons.arrow_back)),
            const Text('Verifikasi Nomor', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('Masukkan kode OTP 4 digit yang dikirim ke +62${phoneC.text}.',
                style: const TextStyle(color: C.grey)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: otpC,
            keyboardType: TextInputType.number,
            maxLength: 4,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, letterSpacing: 18, fontWeight: FontWeight.w700),
            onChanged: (_) => setState(() => err = null),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: C.field,
              errorText: err,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryBtn('Verifikasi', otpC.text.length == 4
              ? () => run(() => app.loginWithOtp(phoneC.text.trim(), otpC.text))
              : null),
          Center(
            child: TextButton(
                onPressed: () async {
                  try {
                    await Api.post('/auth/otp/request', {'phone': phoneC.text.trim()});
                  } on ApiException catch (e) {
                    if (mounted) toast(context, e.message);
                    return;
                  }
                  if (mounted) showOtpBanner();
                },
                child: const Text('Kirim ulang kode', style: TextStyle(color: C.blue, fontWeight: FontWeight.w700))),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      child: stage == 'phone' ? phoneStage() : otpStage(),
    );
  }
}