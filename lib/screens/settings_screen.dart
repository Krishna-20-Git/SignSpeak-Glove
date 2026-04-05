import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import "../services/app_state.dart";
import "../utils/app_theme.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _collegeCtrl;
  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _nameCtrl = TextEditingController(text: s.userName);
    _collegeCtrl = TextEditingController(text: s.collegeName);
  }
  @override
  void dispose() { _nameCtrl.dispose(); _collegeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) => Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("CONFIG_PANEL", style: GoogleFonts.orbitron(fontSize: 14, color: AppTheme.neonCyan, letterSpacing: 3)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.neonCyan), onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _section("USER_PROFILE"),
        const SizedBox(height: 10),
        _box([
          _field(_nameCtrl, "DISPLAY_NAME", "e.g. Krishna"),
          const SizedBox(height: 14),
          _field(_collegeCtrl, "INSTITUTION", "e.g. SRM Institute"),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () { state.saveProfile(name: _nameCtrl.text.trim(), college: _collegeCtrl.text.trim()); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PROFILE SAVED", style: GoogleFonts.orbitron(fontSize: 10, color: Colors.black)), backgroundColor: AppTheme.neonLime, behavior: SnackBarBehavior.floating)); },
            child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: AppTheme.neonCyan, boxShadow: [BoxShadow(color: AppTheme.neonCyan.withOpacity(0.4), blurRadius: 12)]), child: Text("SAVE_PROFILE", textAlign: TextAlign.center, style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 2))),
          ),
        ]),
        const SizedBox(height: 24),
        _section("VOICE_CONFIG"),
        const SizedBox(height: 10),
        _box([
          Text("GENDER_PRESET", style: GoogleFonts.orbitron(fontSize: 10, color: AppTheme.neonCyan, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GestureDetector(onTap: () => state.setVoiceGender(false), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(border: Border.all(color: !state.isMaleVoice ? AppTheme.neonMagenta : AppTheme.divider, width: !state.isMaleVoice ? 1.5 : 1), boxShadow: !state.isMaleVoice ? [BoxShadow(color: AppTheme.neonMagenta.withOpacity(0.3), blurRadius: 10)] : []), child: Column(children: [Icon(Icons.woman_rounded, color: !state.isMaleVoice ? AppTheme.neonMagenta : AppTheme.textSecondary, size: 24), Text("FEMALE", style: GoogleFonts.orbitron(fontSize: 9, color: !state.isMaleVoice ? AppTheme.neonMagenta : AppTheme.textSecondary, letterSpacing: 1))])))),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(onTap: () => state.setVoiceGender(true), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(border: Border.all(color: state.isMaleVoice ? AppTheme.neonCyan : AppTheme.divider, width: state.isMaleVoice ? 1.5 : 1), boxShadow: state.isMaleVoice ? [BoxShadow(color: AppTheme.neonCyan.withOpacity(0.3), blurRadius: 10)] : []), child: Column(children: [Icon(Icons.man_rounded, color: state.isMaleVoice ? AppTheme.neonCyan : AppTheme.textSecondary, size: 24), Text("MALE", style: GoogleFonts.orbitron(fontSize: 9, color: state.isMaleVoice ? AppTheme.neonCyan : AppTheme.textSecondary, letterSpacing: 1))])))),
          ]),
          const SizedBox(height: 20),
          _slider("SPEECH_RATE", state.speechRate, 0.2, 0.9, state.setSpeechRate, "SLOW", "FAST"),
          const SizedBox(height: 16),
          _slider("PITCH_LEVEL", state.pitch, 0.5, 2.0, state.setPitch, "LOW", "HIGH"),
        ]),
        const SizedBox(height: 24),
        _section("DATA_MANAGEMENT"),
        const SizedBox(height: 10),
        _box([GestureDetector(
          onTap: () => _confirmClear(context, state),
          child: Row(children: [Icon(Icons.delete_outline, color: AppTheme.neonMagenta, size: 18, shadows: [Shadow(color: AppTheme.neonMagenta, blurRadius: 8)]), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("PURGE_SPEECH_LOG", style: GoogleFonts.orbitron(fontSize: 10, color: AppTheme.neonMagenta, letterSpacing: 1)), Text("${state.history.length} entries stored", style: GoogleFonts.rajdhani(fontSize: 12, color: AppTheme.textSecondary))])]),
        )]),
        const SizedBox(height: 40),
      ]),
    ));
  }

  Widget _section(String t) => Row(children: [Container(width: 3, height: 12, color: AppTheme.neonCyan, margin: const EdgeInsets.only(right: 8)), Text(t, style: GoogleFonts.orbitron(fontSize: 10, color: AppTheme.neonCyan, letterSpacing: 2)), const SizedBox(width: 10), Expanded(child: Container(height: 1, color: AppTheme.divider))]);

  Widget _box(List<Widget> children) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.surface, border: Border.all(color: AppTheme.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _field(TextEditingController ctrl, String label, String hint) => TextField(controller: ctrl, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 16), decoration: InputDecoration(labelText: label, labelStyle: GoogleFonts.orbitron(fontSize: 9, color: AppTheme.neonCyan, letterSpacing: 1), hintText: hint));

  Widget _slider(String label, double value, double min, double max, Function(double) onChanged, String l, String r) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: GoogleFonts.orbitron(fontSize: 9, color: AppTheme.neonCyan, letterSpacing: 1)), Text(value.toStringAsFixed(2), style: GoogleFonts.orbitron(fontSize: 9, color: AppTheme.neonGold))]),
    Slider(value: value, min: min, max: max, onChanged: onChanged),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: GoogleFonts.rajdhani(fontSize: 11, color: AppTheme.textSecondary)), Text(r, style: GoogleFonts.rajdhani(fontSize: 11, color: AppTheme.textSecondary))]),
  ]);

  void _confirmClear(BuildContext context, AppState state) => showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: AppTheme.surface, title: Text("PURGE_LOG?", style: GoogleFonts.orbitron(color: AppTheme.neonMagenta, fontSize: 14)), content: Text("This will permanently delete all speech history.", style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14)), actions: [TextButton(child: Text("CANCEL", style: GoogleFonts.orbitron(color: AppTheme.textSecondary, fontSize: 10)), onPressed: () => Navigator.pop(context)), TextButton(child: Text("PURGE", style: GoogleFonts.orbitron(color: AppTheme.neonMagenta, fontSize: 10)), onPressed: () { state.clearHistory(); Navigator.pop(context); })]));
}
