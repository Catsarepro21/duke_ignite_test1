import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ble_uuids.dart';

class BleController extends ChangeNotifier {
  late final FlutterReactiveBle _ble;

  BleController() {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      _ble = FlutterReactiveBle();
    }
  }

  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _ppmSubscription;

  final List<DiscoveredDevice> _devices = [];
  List<DiscoveredDevice> get devices => _devices;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;
  DeviceConnectionState get connectionState => _connectionState;

  String? _connectedDeviceId;
  String? get connectedDeviceId => _connectedDeviceId;

  double _currentPpm = 0.0;
  double get currentPpm => _currentPpm;

  int _piezoVolume = 0;
  int get piezoVolume => _piezoVolume;

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await [Permission.bluetooth].request();
    }
  }

  void startScan() async {
    await requestPermissions();
    _devices.clear();
    _isScanning = true;
    notifyListeners();

    _scanSubscription?.cancel();
    _scanSubscription = _ble
        .scanForDevices(
          withServices: [BleUuids.serviceUuid],
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          (device) {
            if (device.name == 'MKR1010-HCHO') {
              final index = _devices.indexWhere((d) => d.id == device.id);
              if (index == -1) {
                _devices.add(device);
                notifyListeners();
              }
            }
          },
          onError: (e) {
            _isScanning = false;
            notifyListeners();
            debugPrint('Scan error: $e');
          },
        );

    // Auto stop scan after 10 seconds
    Timer(const Duration(seconds: 10), stopScan);
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  void connect(String deviceId) {
    stopScan();
    _connectionSubscription?.cancel();
    _connectionSubscription = _ble
        .connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen(
          (update) {
            _connectionState = update.connectionState;
            if (update.connectionState == DeviceConnectionState.connected) {
              _connectedDeviceId = deviceId;
              _subscribeToPpm(deviceId);
              _readPiezoVolume(deviceId);
            } else if (update.connectionState ==
                DeviceConnectionState.disconnected) {
              _connectedDeviceId = null;
              _ppmSubscription?.cancel();
            }
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Connection error: $e');
          },
        );
  }

  void disconnect() {
    _connectionSubscription?.cancel();
    _connectedDeviceId = null;
    _connectionState = DeviceConnectionState.disconnected;
    _ppmSubscription?.cancel();
    notifyListeners();
  }

  Future<void> writeWifiSettings(String ssid, String password) async {
    if (_connectedDeviceId == null) return;

    final ssidChar = QualifiedCharacteristic(
      characteristicId: BleUuids.wifiSsidUuid,
      serviceId: BleUuids.serviceUuid,
      deviceId: _connectedDeviceId!,
    );
    final passChar = QualifiedCharacteristic(
      characteristicId: BleUuids.wifiPasswordUuid,
      serviceId: BleUuids.serviceUuid,
      deviceId: _connectedDeviceId!,
    );

    try {
      await _ble.writeCharacteristicWithResponse(
        ssidChar,
        value: utf8.encode(ssid),
      );
      await _ble.writeCharacteristicWithResponse(
        passChar,
        value: utf8.encode(password),
      );
    } catch (e) {
      debugPrint('Write WiFi error: $e');
    }
  }

  Future<void> writePiezoVolume(int volume) async {
    if (_connectedDeviceId == null) return;

    final char = QualifiedCharacteristic(
      characteristicId: BleUuids.piezoVolumeUuid,
      serviceId: BleUuids.serviceUuid,
      deviceId: _connectedDeviceId!,
    );

    try {
      await _ble.writeCharacteristicWithResponse(char, value: [volume]);
      _piezoVolume = volume;
      notifyListeners();
    } catch (e) {
      debugPrint('Write Piezo error: $e');
    }
  }

  Future<void> _readPiezoVolume(String deviceId) async {
    final char = QualifiedCharacteristic(
      characteristicId: BleUuids.piezoVolumeUuid,
      serviceId: BleUuids.serviceUuid,
      deviceId: deviceId,
    );
    try {
      final value = await _ble.readCharacteristic(char);
      if (value.isNotEmpty) {
        _piezoVolume = value[0];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Read Piezo error: $e');
    }
  }

  void _subscribeToPpm(String deviceId) {
    final char = QualifiedCharacteristic(
      characteristicId: BleUuids.ppmUuid,
      serviceId: BleUuids.serviceUuid,
      deviceId: deviceId,
    );

    _ppmSubscription?.cancel();
    _ppmSubscription = _ble
        .subscribeToCharacteristic(char)
        .listen(
          (data) {
            if (data.length >= 4) {
              // Assume float32 (4 bytes)
              final byteData = ByteData.sublistView(Uint8List.fromList(data));
              _currentPpm = byteData.getFloat32(0, Endian.little);
              notifyListeners();
            }
          },
          onError: (e) {
            debugPrint('PPM subscribe error: $e');
          },
        );
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _ppmSubscription?.cancel();
    super.dispose();
  }
}
