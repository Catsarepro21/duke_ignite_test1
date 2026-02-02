import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleUuids {
  static final serviceUuid = Uuid.parse("12345678-1234-1234-1234-1234567890AB");

  static final wifiSsidUuid = Uuid.parse(
    "12345678-1234-1234-1234-1234567890AC",
  );
  static final wifiPasswordUuid = Uuid.parse(
    "12345678-1234-1234-1234-1234567890AD",
  );
  static final piezoVolumeUuid = Uuid.parse(
    "12345678-1234-1234-1234-1234567890AE",
  );
  static final ppmUuid = Uuid.parse("12345678-1234-1234-1234-1234567890AF");
}
