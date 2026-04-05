import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  static const Color background  = Color(0xFF050508);
  static const Color surface     = Color(0xFF0D0D14);
  static const Color surfaceElevated = Color(0xFF13131E);
  static const Color surfaceGlass   = Color(0x1AFFFFFF);

  static const Color neonMagenta = Color(0xFFFF006E);
  static const Color neonLime    = Color(0xFF39FF14);
  static const Color neonCyan    = Color(0xFF00F5FF);
  static const Color neonGold    = Color(0xFFFFD700);
  static const Color neonOrange  = Color(0xFFFF6B00);

  static const Color accent      = neonCyan;
  static const Color accentGlow  = Color(0x2200F5FF);
  static const Color success     = neonLime;
  static const Color warning     = neonGold;
  static const Color error       = neonMagenta;

  static const Color textPrimary   = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF6B6B8A);
  static const Color divider       = Color(0xFF1A1A2E);

  static const Map<String, Color> languageColors = {
    "en": neonCyan,
    "hi": neonMagenta,
    "ta": neonLime,
    "bn": neonGold,
  };

  static Color langColor(String code) => languageColors[code] ?? accent;

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      surface: surface, primary: neonCyan, secondary: neonMagenta, error: neonMagenta,
    ),
    textTheme: GoogleFonts.rajdhaniTextTheme(ThemeData.dark().textTheme).apply(bodyColor: textPrimary, displayColor: textPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0,
      titleTextStyle: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: 2),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: neonCyan, foregroundColor: background, elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      textStyle: GoogleFonts.orbitron(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1),
    )),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: neonCyan, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: neonCyan, width: 1.5)),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
    ),
    sliderTheme: const SliderThemeData(activeTrackColor: neonCyan, thumbColor: neonCyan, inactiveTrackColor: surfaceElevated, overlayColor: accentGlow),
    cardTheme: CardThemeData(color: surfaceElevated, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
  );
}
