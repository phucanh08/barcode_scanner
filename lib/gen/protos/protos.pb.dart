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

import 'protos.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'protos.pbenum.dart';

class CameraSettings extends $pb.GeneratedMessage {
  factory CameraSettings({
    Resolution? resolution,
    CameraSelection? cameraSelection,
  }) {
    final $result = create();
    if (resolution != null) {
      $result.resolution = resolution;
    }
    if (cameraSelection != null) {
      $result.cameraSelection = cameraSelection;
    }
    return $result;
  }
  CameraSettings._() : super();
  factory CameraSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CameraSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CameraSettings', createEmptyInstance: create)
    ..e<Resolution>(1, _omitFieldNames ? '' : 'resolution', $pb.PbFieldType.OE, defaultOrMaker: Resolution.hd, valueOf: Resolution.valueOf, enumValues: Resolution.values)
    ..e<CameraSelection>(2, _omitFieldNames ? '' : 'cameraSelection', $pb.PbFieldType.OE, protoName: 'cameraSelection', defaultOrMaker: CameraSelection.font, valueOf: CameraSelection.valueOf, enumValues: CameraSelection.values)
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

  /// Resolution
  @$pb.TagNumber(1)
  Resolution get resolution => $_getN(0);
  @$pb.TagNumber(1)
  set resolution(Resolution v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasResolution() => $_has(0);
  @$pb.TagNumber(1)
  void clearResolution() => $_clearField(1);

  /// Camera Selection
  @$pb.TagNumber(2)
  CameraSelection get cameraSelection => $_getN(1);
  @$pb.TagNumber(2)
  set cameraSelection(CameraSelection v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCameraSelection() => $_has(1);
  @$pb.TagNumber(2)
  void clearCameraSelection() => $_clearField(2);
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
    ..pc<BarcodeFormat>(1, _omitFieldNames ? '' : 'barcodeFormats', $pb.PbFieldType.KE, protoName: 'barcodeFormats', valueOf: BarcodeFormat.valueOf, enumValues: BarcodeFormat.values, defaultEnumValue: BarcodeFormat.unknown)
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
    ..e<BarcodeFormat>(3, _omitFieldNames ? '' : 'format', $pb.PbFieldType.OE, defaultOrMaker: BarcodeFormat.unknown, valueOf: BarcodeFormat.valueOf, enumValues: BarcodeFormat.values)
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
