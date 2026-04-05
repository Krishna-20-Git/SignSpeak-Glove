import "package:flutter_tts/flutter_tts.dart";
import "../models/language_model.dart";

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isMale = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    await _tts.setLanguage("en-IN");
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.2);
    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg) => _isSpeaking = false);
  }

  Future<void> speak(String text, String languageCode) async {
    final lang = supportedLanguages.firstWhere(
      (l) => l.code == languageCode,
      orElse: () => supportedLanguages.first,
    );
    await _tts.setLanguage(lang.ttsLocale);
    await _tts.setPitch(_isMale ? 0.7 : 1.3);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> setGender(bool isMale) async {
    _isMale = isMale;
    await _tts.setPitch(isMale ? 0.7 : 1.3);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);
  Future<void> setPitch(double pitch) => _tts.setPitch(pitch);
}
