import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import "dart:math";
import "../services/app_state.dart";
import "../utils/app_theme.dart";
import "../widgets/language_selector.dart";
import "../widgets/ble_status_chip.dart";
import "../widgets/gesture_test_panel.dart";
import "../widgets/history_panel.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _scanCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _glowAnim;
  late Animation<double> _entryAnim;
  String _prevText = "";

  @override
  void initState() {
    super.initState();
    _waveCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scanCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _glowAnim  = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _entryAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _waveCtrl.dispose(); _glowCtrl.dispose();
    _scanCtrl.dispose(); _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      if (state.lastText != _prevText && state.lastText.isNotEmpty) {
        _prevText = state.lastText;
        _entryCtrl.forward(from: 0);
      }
      final langColor = AppTheme.langColor(state.selectedLanguage.code);
      final hasText = state.lastText.isNotEmpty;

      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(children: [
          _buildGridBackground(),
          SafeArea(child: CustomScrollView(slivers: [
            _buildAppBar(context, state, langColor),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
              BleStatusChip(state: state),
              const SizedBox(height: 20),
              _buildSpeechCard(state, langColor, hasText),
              const SizedBox(height: 20),
              _buildSectionLabel("OUTPUT LANGUAGE"),
              const SizedBox(height: 10),
              LanguageSelector(state: state),
              const SizedBox(height: 20),
              _buildSectionLabel("GESTURE CONTROL"),
              const SizedBox(height: 10),
              GestureTestPanel(state: state),
              const SizedBox(height: 20),
              _buildSectionLabel("RECENT SPEECH"),
              const SizedBox(height: 10),
              HistoryPanel(state: state),
              const SizedBox(height: 100),
            ]))),
          ])),
        ]),
        floatingActionButton: _buildFab(context),
      );
    });
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(children: [
      Container(width: 3, height: 14, color: AppTheme.neonCyan, margin: const EdgeInsets.only(right: 8)),
      Text(text, style: GoogleFonts.orbitron(fontSize: 10, color: AppTheme.neonCyan, letterSpacing: 2, fontWeight: FontWeight.w600)),
      const SizedBox(width: 12),
      Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.neonCyan.withOpacity(0.3), Colors.transparent])))),
    ]);
  }

  Widget _buildAppBar(BuildContext context, AppState state, Color langColor) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.background, AppTheme.background.withOpacity(0)]),
        ),
      ),
      title: Row(children: [
        AnimatedBuilder(animation: _glowAnim, builder: (_, __) => Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.neonCyan, width: 1.5),
            boxShadow: [BoxShadow(color: AppTheme.neonCyan.withOpacity(_glowAnim.value * 0.5), blurRadius: 12)],
          ),
          child: Icon(Icons.sign_language, color: AppTheme.neonCyan, size: 20, shadows: [Shadow(color: AppTheme.neonCyan, blurRadius: 8)]),
        )),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(colors: [AppTheme.neonCyan, AppTheme.neonMagenta]).createShader(b),
            child: Text("SIGNSPEAK", style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3)),
          ),
          Text(state.userName.isNotEmpty ? "${state.userName.toUpperCase()}" : "READY", style: GoogleFonts.rajdhani(fontSize: 11, color: AppTheme.neonCyan.withOpacity(0.7), letterSpacing: 2)),
        ]),
      ]),
      actions: [
        IconButton(icon: Icon(Icons.settings_outlined, color: AppTheme.neonCyan.withOpacity(0.7)), onPressed: () => Navigator.pushNamed(context, "/settings")),
      ],
    );
  }

  Widget _buildSpeechCard(AppState state, Color langColor, bool hasText) {
    return AnimatedBuilder(animation: _glowAnim, builder: (_, __) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 200),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: hasText ? langColor : AppTheme.divider, width: hasText ? 1.5 : 1),
          boxShadow: hasText ? [
            BoxShadow(color: langColor.withOpacity(_glowAnim.value * 0.4), blurRadius: 30, spreadRadius: 2),
            BoxShadow(color: langColor.withOpacity(0.1), blurRadius: 60),
          ] : [],
        ),
        child: Stack(children: [
          if (hasText) Positioned(top: 0, right: 0, child: Container(width: 80, height: 80, decoration: BoxDecoration(gradient: RadialGradient(colors: [langColor.withOpacity(0.15), Colors.transparent])))),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: langColor, width: 1), boxShadow: [BoxShadow(color: langColor.withOpacity(0.3), blurRadius: 6)]),
                child: Text("${state.selectedLanguage.shortCode} // ${state.selectedLanguage.name.toUpperCase()}", style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.w700, color: langColor, letterSpacing: 1)),
              ),
              if (state.lastGestureId.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(border: Border.all(color: AppTheme.textSecondary.withOpacity(0.3))), child: Text("GID_${state.lastGestureId}", style: GoogleFonts.orbitron(fontSize: 9, color: AppTheme.textSecondary))),
              ],
              const Spacer(),
              if (hasText) GestureDetector(onTap: state.repeatLast, child: Icon(Icons.replay_rounded, color: langColor, size: 20, shadows: [Shadow(color: langColor, blurRadius: 8)])),
            ]),
            const SizedBox(height: 20),
            if (!hasText) ...[
              Center(child: Column(children: [
                const SizedBox(height: 8),
                AnimatedBuilder(animation: _scanCtrl, builder: (_, __) => CustomPaint(size: const Size(80, 80), painter: _ScannerPainter(_scanCtrl.value))),
                const SizedBox(height: 16),
                Text("AWAITING GESTURE INPUT", style: GoogleFonts.orbitron(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.5), letterSpacing: 2)),
                const SizedBox(height: 8),
              ])),
            ] else ...[
              ScaleTransition(scale: _entryAnim, child: Text(state.lastText, style: GoogleFonts.rajdhani(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, height: 1.2))),
              const SizedBox(height: 16),
              AnimatedBuilder(animation: _waveCtrl, builder: (_, __) => Row(children: [
                Icon(Icons.graphic_eq_rounded, color: langColor, size: 16, shadows: [Shadow(color: langColor, blurRadius: 6)]),
                const SizedBox(width: 8),
                Row(children: List.generate(20, (i) {
                  final h = (sin((i / 20) * pi * 2 + _waveCtrl.value * pi * 2) + 1) / 2;
                  return Container(margin: const EdgeInsets.symmetric(horizontal: 1), width: 2.5, height: 4 + h * 20, decoration: BoxDecoration(color: langColor.withOpacity(0.4 + h * 0.6), boxShadow: [BoxShadow(color: langColor.withOpacity(h * 0.4), blurRadius: 4)]));
                })),
                const SizedBox(width: 8),
                Text("TTS_ACTIVE", style: GoogleFonts.orbitron(fontSize: 9, color: langColor.withOpacity(0.8), letterSpacing: 1)),
              ])),
            ],
          ])),
          Positioned(top: 0, left: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(border: Border(top: BorderSide(color: langColor, width: 2), left: BorderSide(color: langColor, width: 2))))),
          Positioned(top: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(border: Border(top: BorderSide(color: langColor, width: 2), right: BorderSide(color: langColor, width: 2))))),
          Positioned(bottom: 0, left: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: langColor, width: 2), left: BorderSide(color: langColor, width: 2))))),
          Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: langColor, width: 2), right: BorderSide(color: langColor, width: 2))))),
        ]),
      );
    });
  }

  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/present"),
      child: AnimatedBuilder(animation: _glowAnim, builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.neonMagenta,
          boxShadow: [BoxShadow(color: AppTheme.neonMagenta.withOpacity(_glowAnim.value * 0.7), blurRadius: 20, spreadRadius: 2)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.fullscreen, color: Colors.black, size: 18),
          const SizedBox(width: 8),
          Text("PRESENT", style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 2)),
        ]),
      )),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF00F5FF).withOpacity(0.03)..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _ScannerPainter extends CustomPainter {
  final double t;
  _ScannerPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    final paint = Paint()..color = AppTheme.neonCyan.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), 30, paint);
    canvas.drawCircle(Offset(cx, cy), 20, paint..color = AppTheme.neonCyan.withOpacity(0.3));
    final angle = t * 2 * pi;
    final sweepPaint = Paint()..color = AppTheme.neonCyan.withOpacity(0.6)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx + cos(angle) * 30, cy + sin(angle) * 30), sweepPaint);
    for (int i = 0; i < 4; i++) {
      final a = angle - i * 0.3;
      canvas.drawLine(Offset(cx, cy), Offset(cx + cos(a) * 30, cy + sin(a) * 30), sweepPaint..color = AppTheme.neonCyan.withOpacity(0.15 - i * 0.03));
    }
  }
  @override bool shouldRepaint(_) => true;
}
