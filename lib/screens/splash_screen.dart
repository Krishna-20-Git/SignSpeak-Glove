import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:math";
import "../utils/app_theme.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _main;
  late AnimationController _glitch;
  late AnimationController _particle;
  late AnimationController _ring;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<double> _slideUp;
  bool _showGlitch = false;
  final _rng = Random();
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 30; i++) {
      _particles.add(_Particle(rng: _rng));
    }
    _main = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _glitch = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _particle = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _ring = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    _fadeIn  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _main, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _scaleIn = Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: _main, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _slideUp = Tween<double>(begin: 40, end: 0).animate(CurvedAnimation(parent: _main, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)));

    _main.forward();

    Future.delayed(const Duration(milliseconds: 800), () => _triggerGlitch());
    Future.delayed(const Duration(milliseconds: 1200), () => _triggerGlitch());
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) Navigator.pushReplacementNamed(context, "/home");
    });
  }

  void _triggerGlitch() async {
    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      setState(() => _showGlitch = true);
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      setState(() => _showGlitch = false);
      await Future.delayed(const Duration(milliseconds: 40));
    }
  }

  @override
  void dispose() {
    _main.dispose(); _glitch.dispose();
    _particle.dispose(); _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(children: [
        AnimatedBuilder(animation: _particle, builder: (_, __) {
          return CustomPaint(size: size, painter: _ParticlePainter(_particles, _particle.value));
        }),
        AnimatedBuilder(animation: _ring, builder: (_, __) {
          return CustomPaint(size: size, painter: _RingPainter(_ring.value));
        }),
        Center(child: AnimatedBuilder(animation: _main, builder: (_, __) {
          return FadeTransition(opacity: _fadeIn, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ScaleTransition(scale: _scaleIn, child: Stack(alignment: Alignment.center, children: [
              Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.neonCyan, width: 1.5), boxShadow: [BoxShadow(color: AppTheme.neonCyan.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)])),
              Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.neonCyan.withOpacity(0.1), border: Border.all(color: AppTheme.neonMagenta, width: 1))),
              Icon(Icons.sign_language, color: AppTheme.neonCyan, size: 52, shadows: [Shadow(color: AppTheme.neonCyan.withOpacity(0.8), blurRadius: 20)]),
            ])),
            const SizedBox(height: 36),
            Transform.translate(offset: Offset(0, _slideUp.value), child: Column(children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(colors: [AppTheme.neonCyan, AppTheme.neonMagenta, AppTheme.neonGold]).createShader(bounds),
                child: Text(_showGlitch ? "S1GN5P3AK" : "SIGNSPEAK",
                  style: GoogleFonts.orbitron(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 6)),
              ),
              const SizedBox(height: 8),
              Text("MULTILINGUAL GESTURE INTERFACE",
                style: GoogleFonts.rajdhani(fontSize: 12, color: AppTheme.neonCyan.withOpacity(0.7), letterSpacing: 3, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _langBadge("EN", AppTheme.neonCyan),
                const SizedBox(width: 8),
                _langBadge("HI", AppTheme.neonMagenta),
                const SizedBox(width: 8),
                _langBadge("TA", AppTheme.neonLime),
                const SizedBox(width: 8),
                _langBadge("BN", AppTheme.neonGold),
              ]),
              const SizedBox(height: 48),
              SizedBox(width: 200, child: LinearProgressIndicator(
                backgroundColor: AppTheme.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonCyan),
                minHeight: 2,
              )),
              const SizedBox(height: 12),
              Text("INITIALIZING SYSTEMS...",
                style: GoogleFonts.rajdhani(fontSize: 10, color: AppTheme.textSecondary, letterSpacing: 2)),
            ])),
          ]));
        })),
      ]),
    );
  }

  Widget _langBadge(String code, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Text(code, style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Particle {
  late double x, y, vx, vy, size, opacity;
  late Color color;
  final Random rng;
  _Particle({required this.rng}) { reset(); }
  void reset() {
    x = rng.nextDouble();
    y = rng.nextDouble();
    vx = (rng.nextDouble() - 0.5) * 0.002;
    vy = (rng.nextDouble() - 0.5) * 0.002;
    size = rng.nextDouble() * 2 + 0.5;
    opacity = rng.nextDouble() * 0.6 + 0.1;
    color = [AppTheme.neonCyan, AppTheme.neonMagenta, AppTheme.neonLime][rng.nextInt(3)];
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlePainter(this.particles, this.t);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      p.x += p.vx; p.y += p.vy;
      if (p.x < 0 || p.x > 1 || p.y < 0 || p.y > 1) p.reset();
      final paint = Paint()..color = p.color.withOpacity(p.opacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }
  @override bool shouldRepaint(_) => true;
}

class _RingPainter extends CustomPainter {
  final double t;
  _RingPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    for (int i = 0; i < 3; i++) {
      final progress = (t + i * 0.33) % 1.0;
      final radius = 80 + progress * 180;
      final opacity = (1 - progress) * 0.15;
      final paint = Paint()..color = AppTheme.neonCyan.withOpacity(opacity)..style = PaintingStyle.stroke..strokeWidth = 1;
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }
  @override bool shouldRepaint(_) => true;
}
