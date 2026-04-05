import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import "dart:math";
import "../services/app_state.dart";
import "../utils/app_theme.dart";
import "../widgets/gesture_test_panel.dart";

class PresentScreen extends StatefulWidget {
  const PresentScreen({super.key});
  @override
  State<PresentScreen> createState() => _PresentScreenState();
}

class _PresentScreenState extends State<PresentScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final hasText = state.lastText.isNotEmpty;
      final langColor = AppTheme.langColor(state.selectedLanguage.code);
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textSecondary), onPressed: () => Navigator.pop(context)),
            Text("Presentation Mode", style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.success.withOpacity(0.4))), child: Text("LIVE", style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.success, letterSpacing: 2))),
          ])),
          Expanded(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
            Expanded(child: AnimatedContainer(duration: const Duration(milliseconds: 400), width: double.infinity, decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: hasText ? langColor.withOpacity(0.6) : AppTheme.divider, width: 2), boxShadow: hasText ? [BoxShadow(color: langColor.withOpacity(0.2), blurRadius: 40, spreadRadius: 5)] : []),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (!hasText) ...[
                  AnimatedBuilder(animation: _glowAnim, builder: (_, __) => Icon(Icons.sign_language, size: 80, color: AppTheme.textSecondary.withOpacity(_glowAnim.value * 0.4))),
                  const SizedBox(height: 20),
                  Text("Make a gesture with the glove", style: GoogleFonts.spaceGrotesk(fontSize: 18, color: AppTheme.textSecondary.withOpacity(0.5), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                ] else ...[
                  Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: langColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: langColor.withOpacity(0.4))), child: Text("${state.selectedLanguage.shortCode} · ${state.selectedLanguage.name}", style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: langColor))),
                    const SizedBox(height: 24),
                    Text(state.lastText, style: GoogleFonts.spaceGrotesk(fontSize: 42, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.2), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    _buildWaveBar(langColor),
                    const SizedBox(height: 12),
                    Text("Gesture #${state.lastGestureId}", style: GoogleFonts.robotoMono(fontSize: 13, color: AppTheme.textSecondary)),
                  ])),
                ],
              ]),
            )),
            const SizedBox(height: 20),
            _buildLanguageBar(state),
            const SizedBox(height: 16),
            GestureTestPanel(state: state),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: GestureDetector(onTap: state.repeatLast, child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.replay_rounded, color: AppTheme.accent, size: 18), const SizedBox(width: 8), Text("Repeat", style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.accent))])))),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(onTap: state.stopSpeaking, child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.stop_rounded, color: AppTheme.error, size: 18), const SizedBox(width: 8), Text("Stop", style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.error))])))),
            ]),
          ]))),
        ])),
      );
    });
  }

  Widget _buildWaveBar(Color color) {
    return AnimatedBuilder(animation: _waveController, builder: (_, __) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(16, (i) {
        final h = (sin((i / 16) * pi + (_waveController.value * pi * 2)) + 1) / 2;
        return Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 4, height: 8 + (h * 24), decoration: BoxDecoration(color: color.withOpacity(0.5 + h * 0.5), borderRadius: BorderRadius.circular(2)));
      }));
    });
  }

  Widget _buildLanguageBar(AppState state) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Language: ", style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppTheme.textSecondary)),
      Text(state.selectedLanguage.name, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.langColor(state.selectedLanguage.code))),
      const SizedBox(width: 4),
      Text("· Tap Demo Mode to test", style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.5))),
    ]);
  }
}
