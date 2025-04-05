
import '../models/barcode.dart';
import '../models/barcode_scanner_options.dart';
import '../gen/protos/protos.pb.dart' as protos;

extension BarcodeScannerOptionsToProtos on BarcodeScannerOptions {
  protos.Configuration toProtos() {
    return protos.Configuration(
      barcodeFormats: formats.map((e) => e.toProtos()),
      cameraSettings: cameraSettings.toProtos(),
      resultSettings: resultSettings.toProtos(),
    );
  }
}

extension _BarcodeFormatToProtos on BarcodeFormat {
  protos.BarcodeFormat toProtos() {
    return protos.BarcodeFormat.values.where((e) => e.name == name).first;
  }
}

extension _ResolutionPresetToProtos on ResolutionPreset {
  protos.ResolutionPreset toProtos() {
    switch (this) {
      case ResolutionPreset.hd1280x720:
        return protos.ResolutionPreset.hd1280x720;
      case ResolutionPreset.hd1920x1080:
        return protos.ResolutionPreset.hd1920x1080;
    }
  }
}

extension _CameraPositionToProtos on CameraPosition {
  protos.CameraPosition toProtos() {
    switch (this) {
      case CameraPosition.font:
        return protos.CameraPosition.font;
      case CameraPosition.back:
        return protos.CameraPosition.back;
    }
  }
}

extension _CameraSettingsToProtos on CameraSettings {
  protos.CameraSettings toProtos() {
    return protos.CameraSettings(
        resolutionPreset: resolutionPreset.toProtos(),
        cameraPosition: cameraPosition.toProtos());
  }
}

extension _ResultSettingsToProtos on ResultSettings {
  protos.ResultSettings toProtos() {
    return protos.ResultSettings(
      beepOnScan: beepOnScan,
      vibrateOnScan: vibrateOnScan,
    );
  }
}
