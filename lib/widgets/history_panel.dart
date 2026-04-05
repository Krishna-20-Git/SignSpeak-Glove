import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";
import "../models/language_model.dart";
import "../services/app_state.dart";
import "../utils/app_theme.dart";

class HistoryPanel extends StatelessWidget {
  final AppState state;
  const HistoryPanel({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final history = state.history.take(5).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const SizedBox(),
        if (history.isNotEmpty) GestureDetector(onTap: () => Navigator.pushNamed(context, "/history"), child: Text("VIEW_ALL >>", style: GoogleFonts.orbitron(fontSize: 9, color: AppTheme.neonCyan, letterSpacing: 1))),
      ]),
      const SizedBox(height: 8),
      if (history.isEmpty)
        Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(border: Border.all(color: AppTheme.divider)), child: Text("// NO_SPEECH_LOG", textAlign: TextAlign.center, style: GoogleFonts.orbitron(color: AppTheme.textSecondary.withOpacity(0.4), fontSize: 10, letterSpacing: 1)))
      else
        Container(decoration: BoxDecoration(border: Border.all(color: AppTheme.divider)), child: Column(children: history.asMap().entries.map((e) {
          final i = e.key; final item = e.value;
          final lang = supportedLanguages.firstWhere((l) => l.code == item.languageCode, orElse: () => supportedLanguages.first);
          final color = AppTheme.langColor(item.languageCode);
          return Column(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Row(children: [
              Container(width: 28, height: 28, decoration: BoxDecoration(border: Border.all(color: color, width: 1), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)]), child: Center(child: Text(lang.shortCode, style: GoogleFonts.orbitron(fontSize: 8, color: color, fontWeight: FontWeight.w700)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.text, style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(DateFormat("HH:mm:ss").format(item.timestamp), style: GoogleFonts.orbitron(fontSize: 8, color: AppTheme.textSecondary, letterSpacing: 1)),
              ])),
              Text("GID_${item.gestureId}", style: GoogleFonts.orbitron(fontSize: 8, color: AppTheme.textSecondary)),
            ])),
            if (i < history.length - 1) Container(height: 1, color: AppTheme.divider),
          ]);
        }).toList())),
    ]);
  }
}
