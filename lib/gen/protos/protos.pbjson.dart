//
//  Generated code. Do not modify.
//  source: protos/protos.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use barcodeFormatDescriptor instead')
const BarcodeFormat$json = {
  '1': 'BarcodeFormat',
  '2': [
    {'1': 'unknown', '2': 0},
    {'1': 'aztec', '2': 1},
    {'1': 'code39', '2': 2},
    {'1': 'code93', '2': 3},
    {'1': 'ean8', '2': 4},
    {'1': 'ean13', '2': 5},
    {'1': 'code128', '2': 6},
    {'1': 'dataMatrix', '2': 7},
    {'1': 'qr', '2': 8},
    {'1': 'interleaved2of5', '2': 9},
    {'1': 'upce', '2': 10},
    {'1': 'pdf417', '2': 11},
  ],
};

/// Descriptor for `BarcodeFormat`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List barcodeFormatDescriptor = $convert.base64Decode(
    'Cg1CYXJjb2RlRm9ybWF0EgsKB3Vua25vd24QABIJCgVhenRlYxABEgoKBmNvZGUzORACEgoKBm'
    'NvZGU5MxADEggKBGVhbjgQBBIJCgVlYW4xMxAFEgsKB2NvZGUxMjgQBhIOCgpkYXRhTWF0cml4'
    'EAcSBgoCcXIQCBITCg9pbnRlcmxlYXZlZDJvZjUQCRIICgR1cGNlEAoSCgoGcGRmNDE3EAs=');

@$core.Deprecated('Use resolutionPresetDescriptor instead')
const ResolutionPreset$json = {
  '1': 'ResolutionPreset',
  '2': [
    {'1': 'hd1280x720', '2': 0},
    {'1': 'hd1920x1080', '2': 1},
  ],
};

/// Descriptor for `ResolutionPreset`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List resolutionPresetDescriptor = $convert.base64Decode(
    'ChBSZXNvbHV0aW9uUHJlc2V0Eg4KCmhkMTI4MHg3MjAQABIPCgtoZDE5MjB4MTA4MBAB');

@$core.Deprecated('Use cameraPositionDescriptor instead')
const CameraPosition$json = {
  '1': 'CameraPosition',
  '2': [
    {'1': 'font', '2': 0},
    {'1': 'back', '2': 1},
  ],
};

/// Descriptor for `CameraPosition`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cameraPositionDescriptor = $convert.base64Decode(
    'Cg5DYW1lcmFQb3NpdGlvbhIICgRmb250EAASCAoEYmFjaxAB');

@$core.Deprecated('Use resultTypeDescriptor instead')
const ResultType$json = {
  '1': 'ResultType',
  '2': [
    {'1': 'Barcode', '2': 0},
    {'1': 'Cancelled', '2': 1},
    {'1': 'Error', '2': 2},
  ],
};

/// Descriptor for `ResultType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List resultTypeDescriptor = $convert.base64Decode(
    'CgpSZXN1bHRUeXBlEgsKB0JhcmNvZGUQABINCglDYW5jZWxsZWQQARIJCgVFcnJvchAC');

@$core.Deprecated('Use cameraSettingsDescriptor instead')
const CameraSettings$json = {
  '1': 'CameraSettings',
  '2': [
    {'1': 'resolutionPreset', '3': 1, '4': 1, '5': 14, '6': '.ResolutionPreset', '10': 'resolutionPreset'},
    {'1': 'cameraPosition', '3': 2, '4': 1, '5': 14, '6': '.CameraPosition', '10': 'cameraPosition'},
  ],
};

/// Descriptor for `CameraSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cameraSettingsDescriptor = $convert.base64Decode(
    'Cg5DYW1lcmFTZXR0aW5ncxI9ChByZXNvbHV0aW9uUHJlc2V0GAEgASgOMhEuUmVzb2x1dGlvbl'
    'ByZXNldFIQcmVzb2x1dGlvblByZXNldBI3Cg5jYW1lcmFQb3NpdGlvbhgCIAEoDjIPLkNhbWVy'
    'YVBvc2l0aW9uUg5jYW1lcmFQb3NpdGlvbg==');

@$core.Deprecated('Use configurationDescriptor instead')
const Configuration$json = {
  '1': 'Configuration',
  '2': [
    {'1': 'barcodeFormats', '3': 1, '4': 3, '5': 14, '6': '.BarcodeFormat', '10': 'barcodeFormats'},
    {'1': 'cameraSettings', '3': 2, '4': 1, '5': 11, '6': '.CameraSettings', '10': 'cameraSettings'},
    {'1': 'resultSettings', '3': 3, '4': 1, '5': 11, '6': '.ResultSettings', '10': 'resultSettings'},
  ],
};

/// Descriptor for `Configuration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configurationDescriptor = $convert.base64Decode(
    'Cg1Db25maWd1cmF0aW9uEjYKDmJhcmNvZGVGb3JtYXRzGAEgAygOMg4uQmFyY29kZUZvcm1hdF'
    'IOYmFyY29kZUZvcm1hdHMSNwoOY2FtZXJhU2V0dGluZ3MYAiABKAsyDy5DYW1lcmFTZXR0aW5n'
    'c1IOY2FtZXJhU2V0dGluZ3MSNwoOcmVzdWx0U2V0dGluZ3MYAyABKAsyDy5SZXN1bHRTZXR0aW'
    '5nc1IOcmVzdWx0U2V0dGluZ3M=');

@$core.Deprecated('Use resultSettingsDescriptor instead')
const ResultSettings$json = {
  '1': 'ResultSettings',
  '2': [
    {'1': 'beepOnScan', '3': 1, '4': 1, '5': 8, '10': 'beepOnScan'},
    {'1': 'vibrateOnScan', '3': 2, '4': 1, '5': 8, '10': 'vibrateOnScan'},
  ],
};

/// Descriptor for `ResultSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resultSettingsDescriptor = $convert.base64Decode(
    'Cg5SZXN1bHRTZXR0aW5ncxIeCgpiZWVwT25TY2FuGAEgASgIUgpiZWVwT25TY2FuEiQKDXZpYn'
    'JhdGVPblNjYW4YAiABKAhSDXZpYnJhdGVPblNjYW4=');

@$core.Deprecated('Use scanResultDescriptor instead')
const ScanResult$json = {
  '1': 'ScanResult',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.ResultType', '10': 'type'},
    {'1': 'rawContent', '3': 2, '4': 1, '5': 9, '10': 'rawContent'},
    {'1': 'format', '3': 3, '4': 1, '5': 14, '6': '.BarcodeFormat', '10': 'format'},
    {'1': 'formatNote', '3': 4, '4': 1, '5': 9, '10': 'formatNote'},
  ],
};

/// Descriptor for `ScanResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scanResultDescriptor = $convert.base64Decode(
    'CgpTY2FuUmVzdWx0Eh8KBHR5cGUYASABKA4yCy5SZXN1bHRUeXBlUgR0eXBlEh4KCnJhd0Nvbn'
    'RlbnQYAiABKAlSCnJhd0NvbnRlbnQSJgoGZm9ybWF0GAMgASgOMg4uQmFyY29kZUZvcm1hdFIG'
    'Zm9ybWF0Eh4KCmZvcm1hdE5vdGUYBCABKAlSCmZvcm1hdE5vdGU=');

