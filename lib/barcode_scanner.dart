export 'barcode_scanner_view.dart';
import 'barcode_scanner_platform_interface.dart';

class BarcodeScanner {
  Future<String?> getPlatformVersion() {
    return BarcodeScannerPlatform.instance.getPlatformVersion();
  }
}
