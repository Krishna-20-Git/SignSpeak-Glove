import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../services/app_state.dart";
import "../utils/app_theme.dart";

class BleStatusChip extends StatelessWidget {
  final AppState state;
  const BleStatusChip({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final connected = state.bleConnected;
    final scanning = state.bleScanning;
    Color color; String label; IconData icon;
    if (scanning) { color = AppTheme.neonGold; label = "SCANNING..."; icon = Icons.bluetooth_searching; }
    else if (connected) { color = AppTheme.neonLime; label = "GLOVE_LINKED"; icon = Icons.bluetooth_connected; }
    else { color = AppTheme.neonMagenta; label = "NO_DEVICE"; icon = Icons.bluetooth_disabled; }
    return Row(children: [
      GestureDetector(
        onTap: connected ? state.bleDisconnect : state.startBleScan,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: color, width: 1), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            scanning ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: color)) : Icon(icon, size: 12, color: color),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 1)),
          ]),
        ),
      ),
      const SizedBox(width: 8),
      if (!connected && !scanning) GestureDetector(
        onTap: state.startBleScan,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: AppTheme.neonCyan, boxShadow: [BoxShadow(color: AppTheme.neonCyan.withOpacity(0.4), blurRadius: 10)]),
          child: Text("SCAN", style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 2)),
        ),
      ),
    ]);
  }
}
