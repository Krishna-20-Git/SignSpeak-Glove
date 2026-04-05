import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import "services/app_state.dart";
import "screens/splash_screen.dart";
import "screens/home_screen.dart";
import "screens/dictionary_screen.dart";
import "screens/history_screen.dart";
import "screens/settings_screen.dart";
import "screens/present_screen.dart";
import "utils/app_theme.dart";
import "utils/font_loader.dart";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarColor: AppTheme.background));
  await AppFontLoader.loadIndianFonts();
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const SignSpeakApp()));
}
class SignSpeakApp extends StatelessWidget {
  const SignSpeakApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "SignSpeak", theme: AppTheme.theme, debugShowCheckedModeBanner: false, initialRoute: "/", routes: {
      "/": (_) => const SplashScreen(),
      "/home": (_) => const MainShell(),
      "/settings": (_) => const SettingsScreen(),
      "/history": (_) => const HistoryScreen(),
      "/dictionary": (_) => const DictionaryScreen(),
      "/present": (_) => const PresentScreen(),
    });
  }
}
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _pages = [const HomeScreen(), const DictionaryScreen(), const HistoryScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider, width: 1))), child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(0, Icons.sign_language_outlined, Icons.sign_language, "Home"),
        _navItem(1, Icons.menu_book_outlined, Icons.menu_book, "Dictionary"),
        _navItem(2, Icons.history_rounded, Icons.history_rounded, "History"),
      ])))),
    );
  }
  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(onTap: () => setState(() => _currentIndex = index), behavior: HitTestBehavior.opaque, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), decoration: BoxDecoration(color: isActive ? AppTheme.accentGlow : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(isActive ? activeIcon : icon, size: 22, color: isActive ? AppTheme.accent : AppTheme.textSecondary), const SizedBox(height: 3), Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? AppTheme.accent : AppTheme.textSecondary))])));
  }
}
