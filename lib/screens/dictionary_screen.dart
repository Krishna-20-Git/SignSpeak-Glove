import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import "../models/language_model.dart";
import "../services/app_state.dart";
import "../services/gesture_service.dart";
import "../utils/app_theme.dart";
class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});
  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}
class _DictionaryScreenState extends State<DictionaryScreen> {
  String _searchQuery = "";
  final _gestureService = GestureService();
  final _searchController = TextEditingController();
  @override
  void dispose() { _searchController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final enMap = _gestureService.allGestures("en");
      final entries = enMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      final filtered = _searchQuery.isEmpty ? entries : entries.where((e) { final q = _searchQuery.toLowerCase(); for (final lang in supportedLanguages) { final text = _gestureService.resolve(gestureId: e.key, languageCode: lang.code, userName: state.userName, collegeName: state.collegeName)?.toLowerCase(); if (text != null && text.contains(q)) return true; } return e.key.contains(q); }).toList();
      return Scaffold(appBar: AppBar(title: const Text("Gesture Dictionary"), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: TextField(controller: _searchController, onChanged: (v) => setState(() => _searchQuery = v), decoration: InputDecoration(hintText: "Search gestures...", prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 18, color: AppTheme.textSecondary), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ""); }) : null))),
        Expanded(child: filtered.isEmpty ? Center(child: Text("No gestures found", style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary))) : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: filtered.length, itemBuilder: (context, i) {
          final entry = filtered[i];
          return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.accentGlow, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.accent.withOpacity(0.4))), child: Text("Gesture #${entry.key}", style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent))),
              const Spacer(),
              GestureDetector(onTap: () => state.triggerGesture(entry.key), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppTheme.surfaceElevated, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.divider)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.play_arrow_rounded, size: 14, color: AppTheme.textSecondary), const SizedBox(width: 4), Text("Speak", style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))]))),
            ])),
            const Divider(color: AppTheme.divider, height: 1),
            ...supportedLanguages.map((lang) { final text = _gestureService.resolve(gestureId: entry.key, languageCode: lang.code, userName: state.userName, collegeName: state.collegeName); final color = AppTheme.langColor(lang.code); return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 80, child: Row(children: [Text(lang.shortCode, style: const TextStyle(fontSize: 14)), const SizedBox(width: 6), Text(lang.name, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: color))])), const SizedBox(width: 12), Expanded(child: Text(text ?? "—", style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)))])); }),
          ]));
        })),
      ]));
    });
  }
}
