import "dart:async";
class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();
  bool _connected = false;
  bool _scanning = false;
  bool get isConnected => _connected;
  bool get isScanning => _scanning;
  String? get connectedDeviceName => _connected ? "SignGlove_01" : null;
  final StreamController<String> _gestureController = StreamController<String>.broadcast();
  Stream<String> get gestureStream => _gestureController.stream;
  Future<bool> scanAndConnect() async {
    _scanning = true;
    await Future.delayed(const Duration(seconds: 3));
    _scanning = false;
    return false;
  }
  Future<void> disconnect() async { _connected = false; }
  void dispose() { _gestureController.close(); }
}
