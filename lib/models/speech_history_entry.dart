class SpeechHistoryEntry {
  final String gestureId;
  final String text;
  final String languageCode;
  final DateTime timestamp;
  const SpeechHistoryEntry({required this.gestureId, required this.text, required this.languageCode, required this.timestamp});
  Map<String, dynamic> toJson() => {"gestureId": gestureId, "text": text, "languageCode": languageCode, "timestamp": timestamp.toIso8601String()};
  factory SpeechHistoryEntry.fromJson(Map<String, dynamic> json) => SpeechHistoryEntry(gestureId: json["gestureId"], text: json["text"], languageCode: json["languageCode"], timestamp: DateTime.parse(json["timestamp"]));
}
