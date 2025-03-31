import 'barcode_scanner_platform_interface.dart';

/// An implementation of [BarcodeScannerPlatform] that uses method channels.
class MethodChannelBarcodeScanner extends BarcodeScannerPlatform {
  @override
  Future<List<String>?> detectBarcodesByImagePath(String imagePath) async {
    final result = await methodChannel?.invokeMethod<List<dynamic>>(
        'detectBarcodesByImagePath', imagePath);
    return result?.cast<String>();
  }

  @override
  void pauseCamera() {
    methodChannel?.invokeMethod('pauseCamera');
  }

  @override
  void resumeCamera() {
    methodChannel?.invokeMethod('resumeCamera');
  }
}
