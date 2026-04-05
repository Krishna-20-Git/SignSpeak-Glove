import "package:flutter/material.dart";
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String shortCode;
  final String assetKey;
  final String ttsLocale;
  final Color color;
  const AppLanguage({required this.code, required this.name, required this.nativeName, required this.shortCode, required this.assetKey, required this.ttsLocale, required this.color});
}
const List<AppLanguage> supportedLanguages = [
  AppLanguage(code: "en", name: "English", nativeName: "English", shortCode: "EN", assetKey: "assets/gesture_map_en.json", ttsLocale: "en-IN", color: Color(0xFF00F5FF)),
  AppLanguage(code: "hi", name: "Hindi",   nativeName: "Hindi",   shortCode: "HI", assetKey: "assets/gesture_map_hi.json", ttsLocale: "en-IN", color: Color(0xFFFF006E)),
  AppLanguage(code: "ta", name: "Tamil",   nativeName: "Tamil",   shortCode: "TA", assetKey: "assets/gesture_map_ta.json", ttsLocale: "en-IN", color: Color(0xFF39FF14)),
  AppLanguage(code: "bn", name: "Bengali", nativeName: "Bengali", shortCode: "BN", assetKey: "assets/gesture_map_bn.json", ttsLocale: "en-IN", color: Color(0xFFFFD700)),
];
