export 'barcode_scanner_view.dart';
export 'models/barcode.dart';
export 'models/barcode_scanner_options.dart';

import 'package:barcode_scanner/models/barcode.dart';

import 'barcode_scanner_platform_interface.dart';

class BarcodeScanner {
  Future<List<Barcode>?> detectBarcodesByImagePath(String imagePath) {
    return BarcodeScannerPlatform.instance.detectBarcodesByImagePath(imagePath);
  }

  void pauseCamera() {
    BarcodeScannerPlatform.instance.pauseCamera();
  }

  void resumeCamera() {
    BarcodeScannerPlatform.instance.resumeCamera();
  }

  Future<bool> isFlashOn() {
    return BarcodeScannerPlatform.instance.isFlashOn();
  }

  Future<bool> toggleFlash() {
    return BarcodeScannerPlatform.instance.toggleFlash();
  }
}
