import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../models/language_model.dart";
import "../models/speech_history_entry.dart";
import "gesture_service.dart";
import "tts_service.dart";
import "ble_service.dart";
class AppState extends ChangeNotifier {
  String _userName = "";
  String _collegeName = "";
  String get userName => _userName;
  String get collegeName => _collegeName;
  AppLanguage _selectedLanguage = supportedLanguages.first;
  AppLanguage get selectedLanguage => _selectedLanguage;
  double _speechRate = 0.45;
  double _pitch = 1.0;
  bool _isMaleVoice = false;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  bool get isMaleVoice => _isMaleVoice;
  final List<SpeechHistoryEntry> _history = [];
  List<SpeechHistoryEntry> get history => List.unmodifiable(_history);
  String _lastText = "";
  String _lastGestureId = "";
  String get lastText => _lastText;
  String get lastGestureId => _lastGestureId;
  bool _bleConnected = false;
  bool _bleScanning = false;
  bool get bleConnected => _bleConnected;
  bool get bleScanning => _bleScanning;
  final GestureService _gestureService = GestureService();
  final TtsService _ttsService = TtsService();
  final BleService _bleService = BleService();
  AppState() { _init(); }
  Future<void> _init() async {
    await _ttsService.init();
    await _gestureService.preloadAll();
    await _loadPreferences();
    _bleService.gestureStream.listen((id) { processGestureId(id); });
  }
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString("user_name") ?? "";
    _collegeName = prefs.getString("college_name") ?? "";
    _speechRate = prefs.getDouble("speech_rate") ?? 0.45;
    _pitch = prefs.getDouble("pitch") ?? 1.0;
    _isMaleVoice = prefs.getBool("is_male_voice") ?? false;
    final langCode = prefs.getString("language_code") ?? "en";
    _selectedLanguage = supportedLanguages.firstWhere((l) => l.code == langCode, orElse: () => supportedLanguages.first);
    await _ttsService.setPitch(_isMaleVoice ? 0.8 : 1.2);
    final historyJson = prefs.getStringList("history") ?? [];
    for (final item in historyJson.reversed.take(50)) {
      try { _history.add(SpeechHistoryEntry.fromJson(jsonDecode(item))); } catch (_) {}
    }
    notifyListeners();
  }
  Future<void> saveProfile({required String name, required String college}) async {
    _userName = name; _collegeName = college;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_name", name);
    await prefs.setString("college_name", college);
    notifyListeners();
  }
  Future<void> setLanguage(AppLanguage lang) async {
    _selectedLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language_code", lang.code);
    notifyListeners();
  }
  Future<void> setVoiceGender(bool isMale) async {
    _isMaleVoice = isMale;
    await _ttsService.setGender(isMale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_male_voice", isMale);
    notifyListeners();
  }
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate; await _ttsService.setRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("speech_rate", rate);
    notifyListeners();
  }
  Future<void> setPitch(double pitch) async {
    _pitch = pitch; await _ttsService.setPitch(pitch);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("pitch", pitch);
    notifyListeners();
  }
  void processGestureId(String id) {
    final text = _gestureService.resolve(gestureId: id, languageCode: _selectedLanguage.code, userName: _userName, collegeName: _collegeName);
    if (text == null) return;
    _speak(text, id);
  }
  void triggerGesture(String id) => processGestureId(id);
  void _speak(String text, String gestureId) {
    _lastText = text; _lastGestureId = gestureId;
    final entry = SpeechHistoryEntry(gestureId: gestureId, text: text, languageCode: _selectedLanguage.code, timestamp: DateTime.now());
    _history.insert(0, entry);
    if (_history.length > 100) _history.removeLast();
    _saveHistory();
    _ttsService.speak(text, _selectedLanguage.code);
    notifyListeners();
  }
  void repeatLast() { if (_lastText.isNotEmpty) { _ttsService.speak(_lastText, _selectedLanguage.code); } }
  void stopSpeaking() => _ttsService.stop();
  void clearHistory() { _history.clear(); _saveHistory(); notifyListeners(); }
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _history.take(50).map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList("history", list);
  }
  Future<void> startBleScan() async {
    _bleScanning = true; notifyListeners();
    final success = await _bleService.scanAndConnect();
    _bleConnected = success; _bleScanning = false; notifyListeners();
  }
  Future<void> bleDisconnect() async { await _bleService.disconnect(); _bleConnected = false; notifyListeners(); }
  @override
  void dispose() { _bleService.dispose(); super.dispose(); }
}
