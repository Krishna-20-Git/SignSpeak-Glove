import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "../models/language_model.dart";
import "../models/speech_history_entry.dart";
import "../services/app_state.dart";
import "../utils/app_theme.dart";
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final history = state.history;
      return Scaffold(appBar: AppBar(title: const Text("Speech History"), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)), actions: [if (history.isNotEmpty) IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.error), onPressed: () => _confirmClear(context, state))]),
      body: history.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history_rounded, size: 56, color: AppTheme.textSecondary.withOpacity(0.3)), const SizedBox(height: 16), Text("No history yet", style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600))])) : ListView.builder(padding: const EdgeInsets.all(20), itemCount: history.length, itemBuilder: (context, i) {
        final item = history[i];
        final lang = supportedLanguages.firstWhere((l) => l.code == item.languageCode, orElse: () => supportedLanguages.first);
        final color = AppTheme.langColor(item.languageCode);
        return Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)), child: ListTile(leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))), child: Center(child: Text(lang.shortCode, style: const TextStyle(fontSize: 18)))), title: Text(item.text, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)), subtitle: Text("${lang.nativeName} · #${item.gestureId} · ${DateFormat("h:mm a").format(item.timestamp)}", style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppTheme.textSecondary)), trailing: IconButton(icon: const Icon(Icons.volume_up_outlined, size: 18), color: AppTheme.textSecondary, onPressed: () => state.triggerGesture(item.gestureId))));
      }));
    });
  }
  void _confirmClear(BuildContext context, AppState state) {
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: AppTheme.surface, title: const Text("Clear All History?"), actions: [TextButton(child: const Text("Cancel", style: TextStyle(color: AppTheme.textSecondary)), onPressed: () => Navigator.pop(context)), TextButton(child: const Text("Clear All", style: TextStyle(color: AppTheme.error)), onPressed: () { state.clearHistory(); Navigator.pop(context); })]));
  }
}
