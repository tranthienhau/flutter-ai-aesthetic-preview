import 'package:flutter/material.dart';

/// Design tokens from design/DESIGN.md (palette P25 emerald vault).
class C {
  static const bg = Color(0xFFF4FCF9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEAF6F0);
  static const accent = Color(0xFF10A56A);
  static const accentFill = Color(0xFF0D7C50);
  static const accentPressed = Color(0xFF0B734A);
  static const accentTint = Color(0xFFE2F4EC);
  static const disabled = Color(0xFFB9DCCB);
  static const blush = Color(0xFFF59BD0);
  static const blushStrong = Color(0xFFF555B4);
  static const blushTint = Color(0xFFFCE4F2);
  static const text = Color(0xFF0C1F18);
  static const text2 = Color(0xFF46594F);
  static const text3 = Color(0xFF5A6A60);
  static const border = Color(0xFFDCEAE3);
  static const borderStrong = Color(0xFF6DA074);
  static const success = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const warning = Color(0xFFAA4F09);
  static const warningTint = Color(0xFFF6EAE1);
  static const danger = Color(0xFFCE2020);
  static const dangerTint = Color(0xFFFBE5E5);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D7C50), Color(0xFF0B734A)],
  );
  static const softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentTint, blushTint],
  );
}

class R {
  static const card = 20.0;
  static const control = 14.0;
  static const input = 12.0;
}

const cardShadow = [
  BoxShadow(color: Color(0x0A0C1F18), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F0C1F18), blurRadius: 24, offset: Offset(0, 8)),
];

class T {
  static const display = TextStyle(
      fontFamily: 'Spectral', fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.6, color: C.text, height: 1.15);
  static const h1 = TextStyle(
      fontFamily: 'Spectral', fontSize: 26, fontWeight: FontWeight.w600, color: C.text, height: 1.2);
  static const title = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: C.text);
  static const body = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: C.text, height: 1.4);
  static const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: C.text);
  static const caption = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: C.text2, height: 1.35);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'PublicSans',
    scaffoldBackgroundColor: C.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.accentFill,
      primary: C.accentFill,
      secondary: C.blushStrong,
      surface: C.surface,
      error: C.danger,
    ),
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: C.text,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: 'Spectral', fontSize: 22, fontWeight: FontWeight.w600, color: C.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.input), borderSide: const BorderSide(color: C.borderStrong)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.input), borderSide: const BorderSide(color: C.borderStrong)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.input), borderSide: const BorderSide(color: C.accent, width: 2)),
      labelStyle: const TextStyle(color: C.text2),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.accentFill : null),
      side: const BorderSide(color: C.borderStrong, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.accentFill : C.border),
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: C.accent,
      inactiveTrackColor: C.border,
      thumbColor: Colors.white,
      overlayColor: Color(0x2210A56A),
      trackHeight: 6,
    ),
  );
}
