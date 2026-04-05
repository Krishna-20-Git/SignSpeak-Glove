import "package:flutter/foundation.dart";
import "package:google_fonts/google_fonts.dart";
class AppFontLoader {
  static Future<void> loadIndianFonts() async {
    if (kIsWeb) {
      GoogleFonts.notoSansDevanagari();
      GoogleFonts.notoSansTamil();
      GoogleFonts.notoSansBengali();
    }
  }
}
