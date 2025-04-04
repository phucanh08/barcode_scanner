export 'barcode_scanner_view.dart';
export 'gen/protos/protos.pb.dart';

import 'barcode_scanner_platform_interface.dart';

class BarcodeScanner {
  Future<List<String>?> detectBarcodesByImagePath(String imagePath) {
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
