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

@$core.Deprecated('Use resolutionDescriptor instead')
const Resolution$json = {
  '1': 'Resolution',
  '2': [
    {'1': 'hd', '2': 0},
    {'1': 'fullHd', '2': 1},
  ],
};

/// Descriptor for `Resolution`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List resolutionDescriptor = $convert.base64Decode(
    'CgpSZXNvbHV0aW9uEgYKAmhkEAASCgoGZnVsbEhkEAE=');

@$core.Deprecated('Use cameraSelectionDescriptor instead')
const CameraSelection$json = {
  '1': 'CameraSelection',
  '2': [
    {'1': 'font', '2': 0},
    {'1': 'back', '2': 1},
    {'1': 'external', '2': 2},
  ],
};

/// Descriptor for `CameraSelection`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cameraSelectionDescriptor = $convert.base64Decode(
    'Cg9DYW1lcmFTZWxlY3Rpb24SCAoEZm9udBAAEggKBGJhY2sQARIMCghleHRlcm5hbBAC');

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
    {'1': 'resolution', '3': 1, '4': 1, '5': 14, '6': '.Resolution', '10': 'resolution'},
    {'1': 'cameraSelection', '3': 2, '4': 1, '5': 14, '6': '.CameraSelection', '10': 'cameraSelection'},
  ],
};

/// Descriptor for `CameraSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cameraSettingsDescriptor = $convert.base64Decode(
    'Cg5DYW1lcmFTZXR0aW5ncxIrCgpyZXNvbHV0aW9uGAEgASgOMgsuUmVzb2x1dGlvblIKcmVzb2'
    'x1dGlvbhI6Cg9jYW1lcmFTZWxlY3Rpb24YAiABKA4yEC5DYW1lcmFTZWxlY3Rpb25SD2NhbWVy'
    'YVNlbGVjdGlvbg==');

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

