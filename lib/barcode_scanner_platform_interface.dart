import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'barcode_scanner_method_channel.dart';

abstract class BarcodeScannerPlatform extends PlatformInterface {
  /// Constructs a BarcodeScannerPlatform.
  BarcodeScannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static BarcodeScannerPlatform _instance = MethodChannelBarcodeScanner();

  /// The default instance of [BarcodeScannerPlatform] to use.
  ///
  /// Defaults to [MethodChannelBarcodeScanner].
  static BarcodeScannerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BarcodeScannerPlatform] when
  /// they register themselves.
  static set instance(BarcodeScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// The method channel used to interact with the native platform.
  MethodChannel? methodChannel;

  void init(int platformViewId) {
    methodChannel = MethodChannel('barcode_scanner_$platformViewId');
  }

  Future<List<String>?> detectBarcodesByImagePath(String imagePath) {
    throw UnimplementedError('detectBarcodesByImagePath has not been implemented.');
  }

  void pauseCamera() {
    throw UnimplementedError('pauseCamera has not been implemented.');
  }

  void resumeCamera() {
    throw UnimplementedError('resumeCamera has not been implemented.');
  }
}
