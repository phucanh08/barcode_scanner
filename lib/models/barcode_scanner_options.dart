import 'barcode.dart';

class BarcodeScannerOptions {
  final List<BarcodeFormat> formats;
  final CameraSettings cameraSettings;
  final ResultSettings resultSettings;

  const BarcodeScannerOptions({
    this.formats = const [BarcodeFormat.all],
    this.cameraSettings = const CameraSettings(),
    this.resultSettings = const ResultSettings(),
  });
}

enum ResolutionPreset { hd1280x720, hd1920x1080 }

enum CameraPosition { font, back }

class CameraSettings {
  final ResolutionPreset resolutionPreset;
  final CameraPosition cameraPosition;

  const CameraSettings({
    this.resolutionPreset = ResolutionPreset.hd1280x720,
    this.cameraPosition = CameraPosition.back,
  });
}

class ResultSettings {
  final bool beepOnScan;
  final bool vibrateOnScan;

  const ResultSettings({
    this.beepOnScan = false,
    this.vibrateOnScan = false,
  });
}
