import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  final String targetServiceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String targetCharUuid    = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String deviceName        = "SignGlove_01";

  BluetoothDevice? _connectedDevice;
  bool _connected = false;
  bool _scanning = false;

  bool get isConnected => _connected;
  bool get isScanning => _scanning;
  String? get connectedDeviceName => _connected ? deviceName : null;

  final StreamController<String> _gestureController = StreamController<String>.broadcast();
  Stream<String> get gestureStream => _gestureController.stream;

  Future<bool> scanAndConnect() async {
    _scanning = true;
    bool found = false;
    Completer<bool> completer = Completer();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    var subscription = FlutterBluePlus.onScanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.advertisementData.advName == deviceName) {
          if (!found) {
            found = true;
            await FlutterBluePlus.stopScan();
            bool connected = await _connectToDevice(r.device);
            if (!completer.isCompleted) completer.complete(connected);
          }
        }
      }
    });

    final result = await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => false,
    ).catchError((_) => false);

    subscription.cancel();
    _scanning = false;
    return result;
  }

  Future<bool> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _connected = true;

      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _connected = false;
          _connectedDevice = null;
        }
      });

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == targetServiceUuid.toLowerCase()) {
          for (var char in service.characteristics) {
            if (char.uuid.toString().toLowerCase() == targetCharUuid.toLowerCase()) {
              await char.setNotifyValue(true);
              char.onValueReceived.listen((value) {
                if (value.isNotEmpty) {
                  String gestureId = utf8.decode(value);
                  _gestureController.add(gestureId);
                }
              });
              return true; 
            }
          }
        }
      }
      return true;
    } catch (e) {
      _connected = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) await _connectedDevice!.disconnect();
    _connected = false;
    _connectedDevice = null;
  }

  void dispose() { _gestureController.close(); }
}
