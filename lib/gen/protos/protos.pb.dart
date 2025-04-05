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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'protos.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'protos.pbenum.dart';

/// protos/barcode.proto
class BarcodeResult extends $pb.GeneratedMessage {
  factory BarcodeResult({
    BarcodeFormat? format,
    $core.String? rawValue,
    $core.List<$core.int>? rawBytes,
    Rect? boundingBox,
    $core.Iterable<Point>? cornerPoints,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (format != null) {
      $result.format = format;
    }
    if (rawValue != null) {
      $result.rawValue = rawValue;
    }
    if (rawBytes != null) {
      $result.rawBytes = rawBytes;
    }
    if (boundingBox != null) {
      $result.boundingBox = boundingBox;
    }
    if (cornerPoints != null) {
      $result.cornerPoints.addAll(cornerPoints);
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  BarcodeResult._() : super();
  factory BarcodeResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BarcodeResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BarcodeResult', createEmptyInstance: create)
    ..e<BarcodeFormat>(1, _omitFieldNames ? '' : 'format', $pb.PbFieldType.OE, defaultOrMaker: BarcodeFormat.all, valueOf: BarcodeFormat.valueOf, enumValues: BarcodeFormat.values)
    ..aOS(2, _omitFieldNames ? '' : 'rawValue', protoName: 'rawValue')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'rawBytes', $pb.PbFieldType.OY, protoName: 'rawBytes')
    ..aOM<Rect>(4, _omitFieldNames ? '' : 'boundingBox', protoName: 'boundingBox', subBuilder: Rect.create)
    ..pc<Point>(5, _omitFieldNames ? '' : 'cornerPoints', $pb.PbFieldType.PM, protoName: 'cornerPoints', subBuilder: Point.create)
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BarcodeResult clone() => BarcodeResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BarcodeResult copyWith(void Function(BarcodeResult) updates) => super.copyWith((message) => updates(message as BarcodeResult)) as BarcodeResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BarcodeResult create() => BarcodeResult._();
  BarcodeResult createEmptyInstance() => create();
  static $pb.PbList<BarcodeResult> createRepeated() => $pb.PbList<BarcodeResult>();
  @$core.pragma('dart2js:noInline')
  static BarcodeResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BarcodeResult>(create);
  static BarcodeResult? _defaultInstance;

  @$pb.TagNumber(1)
  BarcodeFormat get format => $_getN(0);
  @$pb.TagNumber(1)
  set format(BarcodeFormat v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasFormat() => $_has(0);
  @$pb.TagNumber(1)
  void clearFormat() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get rawValue => $_getSZ(1);
  @$pb.TagNumber(2)
  set rawValue($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRawValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearRawValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get rawBytes => $_getN(2);
  @$pb.TagNumber(3)
  set rawBytes($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRawBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearRawBytes() => $_clearField(3);

  @$pb.TagNumber(4)
  Rect get boundingBox => $_getN(3);
  @$pb.TagNumber(4)
  set boundingBox(Rect v) { $_setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasBoundingBox() => $_has(3);
  @$pb.TagNumber(4)
  void clearBoundingBox() => $_clearField(4);
  @$pb.TagNumber(4)
  Rect ensureBoundingBox() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<Point> get cornerPoints => $_getList(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);
}

class Rect extends $pb.GeneratedMessage {
  factory Rect({
    $core.double? left,
    $core.double? top,
    $core.double? right,
    $core.double? bottom,
  }) {
    final $result = create();
    if (left != null) {
      $result.left = left;
    }
    if (top != null) {
      $result.top = top;
    }
    if (right != null) {
      $result.right = right;
    }
    if (bottom != null) {
      $result.bottom = bottom;
    }
    return $result;
  }
  Rect._() : super();
  factory Rect.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Rect.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Rect', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'left', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'top', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'right', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'bottom', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Rect clone() => Rect()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Rect copyWith(void Function(Rect) updates) => super.copyWith((message) => updates(message as Rect)) as Rect;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Rect create() => Rect._();
  Rect createEmptyInstance() => create();
  static $pb.PbList<Rect> createRepeated() => $pb.PbList<Rect>();
  @$core.pragma('dart2js:noInline')
  static Rect getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Rect>(create);
  static Rect? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get left => $_getN(0);
  @$pb.TagNumber(1)
  set left($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLeft() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeft() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get top => $_getN(1);
  @$pb.TagNumber(2)
  set top($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTop() => $_has(1);
  @$pb.TagNumber(2)
  void clearTop() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get right => $_getN(2);
  @$pb.TagNumber(3)
  set right($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRight() => $_has(2);
  @$pb.TagNumber(3)
  void clearRight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get bottom => $_getN(3);
  @$pb.TagNumber(4)
  set bottom($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBottom() => $_has(3);
  @$pb.TagNumber(4)
  void clearBottom() => $_clearField(4);
}

class Point extends $pb.GeneratedMessage {
  factory Point({
    $core.double? x,
    $core.double? y,
  }) {
    final $result = create();
    if (x != null) {
      $result.x = x;
    }
    if (y != null) {
      $result.y = y;
    }
    return $result;
  }
  Point._() : super();
  factory Point.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Point.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Point', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'x', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Point clone() => Point()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Point copyWith(void Function(Point) updates) => super.copyWith((message) => updates(message as Point)) as Point;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Point create() => Point._();
  Point createEmptyInstance() => create();
  static $pb.PbList<Point> createRepeated() => $pb.PbList<Point>();
  @$core.pragma('dart2js:noInline')
  static Point getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Point>(create);
  static Point? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);
}

class CameraSettings extends $pb.GeneratedMessage {
  factory CameraSettings({
    ResolutionPreset? resolutionPreset,
    CameraPosition? cameraPosition,
  }) {
    final $result = create();
    if (resolutionPreset != null) {
      $result.resolutionPreset = resolutionPreset;
    }
    if (cameraPosition != null) {
      $result.cameraPosition = cameraPosition;
    }
    return $result;
  }
  CameraSettings._() : super();
  factory CameraSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CameraSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CameraSettings', createEmptyInstance: create)
    ..e<ResolutionPreset>(1, _omitFieldNames ? '' : 'resolutionPreset', $pb.PbFieldType.OE, protoName: 'resolutionPreset', defaultOrMaker: ResolutionPreset.hd1280x720, valueOf: ResolutionPreset.valueOf, enumValues: ResolutionPreset.values)
    ..e<CameraPosition>(2, _omitFieldNames ? '' : 'cameraPosition', $pb.PbFieldType.OE, protoName: 'cameraPosition', defaultOrMaker: CameraPosition.front, valueOf: CameraPosition.valueOf, enumValues: CameraPosition.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CameraSettings clone() => CameraSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CameraSettings copyWith(void Function(CameraSettings) updates) => super.copyWith((message) => updates(message as CameraSettings)) as CameraSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CameraSettings create() => CameraSettings._();
  CameraSettings createEmptyInstance() => create();
  static $pb.PbList<CameraSettings> createRepeated() => $pb.PbList<CameraSettings>();
  @$core.pragma('dart2js:noInline')
  static CameraSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CameraSettings>(create);
  static CameraSettings? _defaultInstance;

  /// Resolution Preset
  @$pb.TagNumber(1)
  ResolutionPreset get resolutionPreset => $_getN(0);
  @$pb.TagNumber(1)
  set resolutionPreset(ResolutionPreset v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasResolutionPreset() => $_has(0);
  @$pb.TagNumber(1)
  void clearResolutionPreset() => $_clearField(1);

  /// Camera Position
  @$pb.TagNumber(2)
  CameraPosition get cameraPosition => $_getN(1);
  @$pb.TagNumber(2)
  set cameraPosition(CameraPosition v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCameraPosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearCameraPosition() => $_clearField(2);
}

/// protos/configuration.proto
class Configuration extends $pb.GeneratedMessage {
  factory Configuration({
    $core.Iterable<BarcodeFormat>? barcodeFormats,
    CameraSettings? cameraSettings,
    ResultSettings? resultSettings,
  }) {
    final $result = create();
    if (barcodeFormats != null) {
      $result.barcodeFormats.addAll(barcodeFormats);
    }
    if (cameraSettings != null) {
      $result.cameraSettings = cameraSettings;
    }
    if (resultSettings != null) {
      $result.resultSettings = resultSettings;
    }
    return $result;
  }
  Configuration._() : super();
  factory Configuration.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Configuration.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Configuration', createEmptyInstance: create)
    ..pc<BarcodeFormat>(1, _omitFieldNames ? '' : 'barcodeFormats', $pb.PbFieldType.KE, protoName: 'barcodeFormats', valueOf: BarcodeFormat.valueOf, enumValues: BarcodeFormat.values, defaultEnumValue: BarcodeFormat.all)
    ..aOM<CameraSettings>(2, _omitFieldNames ? '' : 'cameraSettings', protoName: 'cameraSettings', subBuilder: CameraSettings.create)
    ..aOM<ResultSettings>(3, _omitFieldNames ? '' : 'resultSettings', protoName: 'resultSettings', subBuilder: ResultSettings.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Configuration clone() => Configuration()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Configuration copyWith(void Function(Configuration) updates) => super.copyWith((message) => updates(message as Configuration)) as Configuration;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Configuration create() => Configuration._();
  Configuration createEmptyInstance() => create();
  static $pb.PbList<Configuration> createRepeated() => $pb.PbList<Configuration>();
  @$core.pragma('dart2js:noInline')
  static Configuration getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Configuration>(create);
  static Configuration? _defaultInstance;

  /// Restricts the barcode format which should be read
  @$pb.TagNumber(1)
  $pb.PbList<BarcodeFormat> get barcodeFormats => $_getList(0);

  /// CameraSettings
  @$pb.TagNumber(2)
  CameraSettings get cameraSettings => $_getN(1);
  @$pb.TagNumber(2)
  set cameraSettings(CameraSettings v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCameraSettings() => $_has(1);
  @$pb.TagNumber(2)
  void clearCameraSettings() => $_clearField(2);
  @$pb.TagNumber(2)
  CameraSettings ensureCameraSettings() => $_ensure(1);

  /// ResultSettings
  @$pb.TagNumber(3)
  ResultSettings get resultSettings => $_getN(2);
  @$pb.TagNumber(3)
  set resultSettings(ResultSettings v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasResultSettings() => $_has(2);
  @$pb.TagNumber(3)
  void clearResultSettings() => $_clearField(3);
  @$pb.TagNumber(3)
  ResultSettings ensureResultSettings() => $_ensure(2);
}

/// protos/result_settings.proto
class ResultSettings extends $pb.GeneratedMessage {
  factory ResultSettings({
    $core.bool? beepOnScan,
    $core.bool? vibrateOnScan,
  }) {
    final $result = create();
    if (beepOnScan != null) {
      $result.beepOnScan = beepOnScan;
    }
    if (vibrateOnScan != null) {
      $result.vibrateOnScan = vibrateOnScan;
    }
    return $result;
  }
  ResultSettings._() : super();
  factory ResultSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResultSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResultSettings', createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'beepOnScan', protoName: 'beepOnScan')
    ..aOB(2, _omitFieldNames ? '' : 'vibrateOnScan', protoName: 'vibrateOnScan')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ResultSettings clone() => ResultSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ResultSettings copyWith(void Function(ResultSettings) updates) => super.copyWith((message) => updates(message as ResultSettings)) as ResultSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResultSettings create() => ResultSettings._();
  ResultSettings createEmptyInstance() => create();
  static $pb.PbList<ResultSettings> createRepeated() => $pb.PbList<ResultSettings>();
  @$core.pragma('dart2js:noInline')
  static ResultSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResultSettings>(create);
  static ResultSettings? _defaultInstance;

  /// Beep on Scan
  @$pb.TagNumber(1)
  $core.bool get beepOnScan => $_getBF(0);
  @$pb.TagNumber(1)
  set beepOnScan($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBeepOnScan() => $_has(0);
  @$pb.TagNumber(1)
  void clearBeepOnScan() => $_clearField(1);

  /// Vibrate on Scan
  @$pb.TagNumber(2)
  $core.bool get vibrateOnScan => $_getBF(1);
  @$pb.TagNumber(2)
  set vibrateOnScan($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVibrateOnScan() => $_has(1);
  @$pb.TagNumber(2)
  void clearVibrateOnScan() => $_clearField(2);
}

class ScanResult extends $pb.GeneratedMessage {
  factory ScanResult({
    ResultType? type,
    $core.String? rawContent,
    BarcodeFormat? format,
    $core.String? formatNote,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (rawContent != null) {
      $result.rawContent = rawContent;
    }
    if (format != null) {
      $result.format = format;
    }
    if (formatNote != null) {
      $result.formatNote = formatNote;
    }
    return $result;
  }
  ScanResult._() : super();
  factory ScanResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScanResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScanResult', createEmptyInstance: create)
    ..e<ResultType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: ResultType.Barcode, valueOf: ResultType.valueOf, enumValues: ResultType.values)
    ..aOS(2, _omitFieldNames ? '' : 'rawContent', protoName: 'rawContent')
    ..e<BarcodeFormat>(3, _omitFieldNames ? '' : 'format', $pb.PbFieldType.OE, defaultOrMaker: BarcodeFormat.all, valueOf: BarcodeFormat.valueOf, enumValues: BarcodeFormat.values)
    ..aOS(4, _omitFieldNames ? '' : 'formatNote', protoName: 'formatNote')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScanResult clone() => ScanResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScanResult copyWith(void Function(ScanResult) updates) => super.copyWith((message) => updates(message as ScanResult)) as ScanResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScanResult create() => ScanResult._();
  ScanResult createEmptyInstance() => create();
  static $pb.PbList<ScanResult> createRepeated() => $pb.PbList<ScanResult>();
  @$core.pragma('dart2js:noInline')
  static ScanResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScanResult>(create);
  static ScanResult? _defaultInstance;

  /// Represents the type of the result
  @$pb.TagNumber(1)
  ResultType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ResultType v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  /// The barcode itself if the result type is barcode.
  /// If the result type is error it contains the error message
  @$pb.TagNumber(2)
  $core.String get rawContent => $_getSZ(1);
  @$pb.TagNumber(2)
  set rawContent($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRawContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearRawContent() => $_clearField(2);

  /// The barcode format
  @$pb.TagNumber(3)
  BarcodeFormat get format => $_getN(2);
  @$pb.TagNumber(3)
  set format(BarcodeFormat v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasFormat() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormat() => $_clearField(3);

  /// If the format is unknown, this field holds additional information
  @$pb.TagNumber(4)
  $core.String get formatNote => $_getSZ(3);
  @$pb.TagNumber(4)
  set formatNote($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFormatNote() => $_has(3);
  @$pb.TagNumber(4)
  void clearFormatNote() => $_clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
