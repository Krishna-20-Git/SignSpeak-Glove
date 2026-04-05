import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../services/app_state.dart";
import "../utils/app_theme.dart";

class GestureTestPanel extends StatefulWidget {
  final AppState state;
  const GestureTestPanel({super.key, required this.state});
  @override
  State<GestureTestPanel> createState() => _GestureTestPanelState();
}

class _GestureTestPanelState extends State<GestureTestPanel> {
  bool _expanded = false;
  static const _demoGestures = [
    ("01","Hello"),("02","Thank You"),("03","Yes"),("04","No"),
    ("05","Intro"),("06","College"),("07","Help"),("08","Water"),
    ("09","Food"),("10","Bathroom"),("11","I am fine"),("12","Repeat"),
    ("13","No Understand"),("14","Good Morning"),("15","Good Night"),
    ("16","My Name"),("17","Nice Meet"),("18","Call Doctor"),("19","Emergency"),("20","Love"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.surface, border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(border: Border.all(color: AppTheme.neonCyan, width: 1), boxShadow: [BoxShadow(color: AppTheme.neonCyan.withOpacity(0.3), blurRadius: 6)]), child: const Icon(Icons.science_outlined, size: 14, color: AppTheme.neonCyan)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("GESTURE_SIMULATOR", style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.neonCyan, letterSpacing: 1)),
              Text("tap to inject gesture input", style: GoogleFonts.rajdhani(fontSize: 11, color: AppTheme.textSecondary)),
            ]),
            const Spacer(),
            Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.neonCyan, size: 18),
          ])),
        ),
        if (_expanded) ...[
          Container(height: 1, color: AppTheme.divider),
          Padding(padding: const EdgeInsets.all(14), child: Wrap(spacing: 8, runSpacing: 8, children: _demoGestures.map((g) => GestureDetector(
            onTap: () => widget.state.triggerGesture(g.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.neonCyan.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("${g.$1}", style: GoogleFonts.orbitron(fontSize: 8, color: AppTheme.neonCyan, fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                Text(g.$2, style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ]),
            ),
          )).toList())),
        ],
      ]),
    );
  }
}
