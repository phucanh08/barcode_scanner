import 'package:barcode_scanner/barcode_scanner.dart';

import 'barcode_scanner_platform_interface.dart';

/// An implementation of [BarcodeScannerPlatform] that uses method channels.
class MethodChannelBarcodeScanner extends BarcodeScannerPlatform {
  @override
  Future<List<BarcodeResult>?> detectBarcodesByImagePath(String imagePath) async {
    final methodChannel = await methodChannelComparator.future;
    final result = await methodChannel.invokeMethod<List<dynamic>>(
        'detectBarcodesByImagePath', imagePath);

    return result?.map((e) => BarcodeResult.fromBuffer(e)).toList();
  }

  @override
  Future<bool> pauseCamera() async {
    final methodChannel = await methodChannelComparator.future;
    return methodChannel
        .invokeMethod<bool>('pauseCamera')
        .then((value) => value ?? false);
  }

  @override
  Future<bool> resumeCamera() async {
    final methodChannel = await methodChannelComparator.future;
    return methodChannel
        .invokeMethod<bool>('resumeCamera')
        .then((value) => value ?? false);
  }

  @override
  Future<bool> isFlashOn() async {
    final methodChannel = await methodChannelComparator.future;
    return methodChannel
        .invokeMethod<bool>('isFlashOn')
        .then((value) => value ?? false);
  }

  @override
  Future<bool> toggleFlash() async {
    final methodChannel = await methodChannelComparator.future;
    return methodChannel
        .invokeMethod<bool>('toggleFlash')
        .then((value) => value ?? false);
  }
}
