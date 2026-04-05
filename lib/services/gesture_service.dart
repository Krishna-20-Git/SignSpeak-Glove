import "dart:convert";
import "package:flutter/services.dart";
import "../models/language_model.dart";
class GestureService {
  static final GestureService _instance = GestureService._internal();
  factory GestureService() => _instance;
  GestureService._internal();
  final Map<String, Map<String, String>> _cache = {};
  Future<void> preloadAll() async { for (final lang in supportedLanguages) { await _loadLanguage(lang); } }
  Future<void> _loadLanguage(AppLanguage lang) async {
    if (_cache.containsKey(lang.code)) return;
    try { final raw = await rootBundle.loadString(lang.assetKey); final decoded = jsonDecode(raw) as Map<String, dynamic>; _cache[lang.code] = decoded.map((k, v) => MapEntry(k, v.toString())); } catch (e) { _cache[lang.code] = {}; }
  }
  String? resolve({required String gestureId, required String languageCode, required String userName, required String collegeName}) {
    final map = _cache[languageCode]; if (map == null) return null;
    final paddedId = gestureId.padLeft(2, "0"); String? phrase = map[paddedId]; if (phrase == null) return null;
    phrase = phrase.replaceAll("{name}", userName.isNotEmpty ? userName : "User");
    phrase = phrase.replaceAll("{college}", collegeName.isNotEmpty ? collegeName : "College");
    return phrase;
  }
  Map<String, String> allGestures(String languageCode) => Map.unmodifiable(_cache[languageCode] ?? {});
}
