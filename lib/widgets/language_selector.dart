import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../models/language_model.dart";
import "../services/app_state.dart";
import "../utils/app_theme.dart";

class LanguageSelector extends StatelessWidget {
  final AppState state;
  const LanguageSelector({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return Row(children: supportedLanguages.map((lang) {
      final isSelected = state.selectedLanguage.code == lang.code;
      final color = lang.color;
      return Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
        onTap: () => state.setLanguage(lang),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : AppTheme.surface,
            border: Border.all(color: isSelected ? color : AppTheme.divider, width: isSelected ? 1.5 : 1),
            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)] : [],
          ),
          child: Column(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: isSelected ? 2 : 1), boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)] : []), child: Center(child: Text(lang.shortCode, style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.w800, color: color)))),
            const SizedBox(height: 6),
            Text(lang.nativeName, style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? color : AppTheme.textSecondary), textAlign: TextAlign.center),
          ]),
        ),
      )));
    }).toList());
  }
}
