import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const red = Color(0xFFBD1E26);
  static const redSoft = Color(0xFFFBE3E3);
  static const gold = Color(0xFFC49A5F);
  static const goldSoft = Color(0xFFFFF4DE);
  static const green = Color(0xFF1F9D55);
  static const blue = Color(0xFF2F80ED);
  static const bg = Color(0xFFF7F7F7);
  static const field = Color(0xFFF1F1F1);
  static const text = Color(0xFF222222);
  static const grey = Color(0xFF8A8A8A);
  static const line = Color(0xFFE6E6E6);
  static const wa = Color(0xFF25D366);
  static const teal = Color(0xFF5BC8C0);
  static const tealSoft = Color(0xFFDDEFEE);
  static const maroon = Color(0xFF4A1414);
  static const purple = Color(0xFFB58BE0);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.red, primary: C.red),
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(
    textTheme: GoogleFonts.figtreeTextTheme(base.textTheme)
        .apply(bodyColor: C.text, displayColor: C.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: C.text,
    ),
  );
}

String rp(int v) {
  final neg = v < 0;
  final s = v.abs().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${neg ? '-' : ''}Rp$b';
}

String num3(int v) => rp(v).replaceFirst('Rp', '');
