//
//  Generated code. Do not modify.
//  source: protos/protos.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// protos/barcode_format.proto
class BarcodeFormat extends $pb.ProtobufEnum {
  static const BarcodeFormat all = BarcodeFormat._(0, _omitEnumNames ? '' : 'all');
  /// 1D Barcode
  static const BarcodeFormat code39 = BarcodeFormat._(1, _omitEnumNames ? '' : 'code39');
  static const BarcodeFormat code93 = BarcodeFormat._(2, _omitEnumNames ? '' : 'code93');
  static const BarcodeFormat code128 = BarcodeFormat._(3, _omitEnumNames ? '' : 'code128');
  static const BarcodeFormat itf = BarcodeFormat._(4, _omitEnumNames ? '' : 'itf');
  static const BarcodeFormat upce = BarcodeFormat._(5, _omitEnumNames ? '' : 'upce');
  static const BarcodeFormat ean8 = BarcodeFormat._(6, _omitEnumNames ? '' : 'ean8');
  static const BarcodeFormat ean13 = BarcodeFormat._(7, _omitEnumNames ? '' : 'ean13');
  static const BarcodeFormat codaBar = BarcodeFormat._(8, _omitEnumNames ? '' : 'codaBar');
  static const BarcodeFormat gs1DataBar = BarcodeFormat._(9, _omitEnumNames ? '' : 'gs1DataBar');
  static const BarcodeFormat gs1DataBarExtended = BarcodeFormat._(10, _omitEnumNames ? '' : 'gs1DataBarExtended');
  /// 2D Barcode
  static const BarcodeFormat qr = BarcodeFormat._(11, _omitEnumNames ? '' : 'qr');
  static const BarcodeFormat pdf417 = BarcodeFormat._(12, _omitEnumNames ? '' : 'pdf417');
  static const BarcodeFormat dataMatrix = BarcodeFormat._(13, _omitEnumNames ? '' : 'dataMatrix');
  static const BarcodeFormat aztec = BarcodeFormat._(14, _omitEnumNames ? '' : 'aztec');
  static const BarcodeFormat unknown = BarcodeFormat._(15, _omitEnumNames ? '' : 'unknown');

  static const $core.List<BarcodeFormat> values = <BarcodeFormat> [
    all,
    code39,
    code93,
    code128,
    itf,
    upce,
    ean8,
    ean13,
    codaBar,
    gs1DataBar,
    gs1DataBarExtended,
    qr,
    pdf417,
    dataMatrix,
    aztec,
    unknown,
  ];

  static final $core.Map<$core.int, BarcodeFormat> _byValue = $pb.ProtobufEnum.initByValue(values);
  static BarcodeFormat? valueOf($core.int value) => _byValue[value];

  const BarcodeFormat._(super.v, super.n);
}

/// protos/camera_settings.proto
class ResolutionPreset extends $pb.ProtobufEnum {
  static const ResolutionPreset hd1280x720 = ResolutionPreset._(0, _omitEnumNames ? '' : 'hd1280x720');
  static const ResolutionPreset hd1920x1080 = ResolutionPreset._(1, _omitEnumNames ? '' : 'hd1920x1080');

  static const $core.List<ResolutionPreset> values = <ResolutionPreset> [
    hd1280x720,
    hd1920x1080,
  ];

  static final $core.Map<$core.int, ResolutionPreset> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ResolutionPreset? valueOf($core.int value) => _byValue[value];

  const ResolutionPreset._(super.v, super.n);
}

class CameraPosition extends $pb.ProtobufEnum {
  static const CameraPosition font = CameraPosition._(0, _omitEnumNames ? '' : 'font');
  static const CameraPosition back = CameraPosition._(1, _omitEnumNames ? '' : 'back');

  static const $core.List<CameraPosition> values = <CameraPosition> [
    font,
    back,
  ];

  static final $core.Map<$core.int, CameraPosition> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CameraPosition? valueOf($core.int value) => _byValue[value];

  const CameraPosition._(super.v, super.n);
}

/// protos/scan_result.proto
class ResultType extends $pb.ProtobufEnum {
  static const ResultType Barcode = ResultType._(0, _omitEnumNames ? '' : 'Barcode');
  static const ResultType Cancelled = ResultType._(1, _omitEnumNames ? '' : 'Cancelled');
  static const ResultType Error = ResultType._(2, _omitEnumNames ? '' : 'Error');

  static const $core.List<ResultType> values = <ResultType> [
    Barcode,
    Cancelled,
    Error,
  ];

  static final $core.Map<$core.int, ResultType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ResultType? valueOf($core.int value) => _byValue[value];

  const ResultType._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
