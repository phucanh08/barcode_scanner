# Barcode Scanner

[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/to/develop-plugins),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Requirements

### iOS

- Minimum iOS Deployment Target: 12
- Xcode 15.3.0 or newer
- Swift 5
- ML Kit does not support 32-bit architectures (i386 and armv7). ML Kit does support 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities. More info [here](https://developers.google.com/ml-kit/migration/ios).

### Android

- minSdkVersion: 21
- targetSdkVersion: 35
- compileSdkVersion: 35

## Usage

### Barcode scanning

Create an instance of BarcodeScannerView

```dart
BarcodeScannerView(
  options: const ScanOptions(
    restrictFormat: [
      BarcodeFormat.qr,
      BarcodeFormat.pdf417,
    ],
    android: AndroidOptions(useAutoFocus: false),
    // strings: {},
  ),
  onData: (data) {
    print('Barcode data: ${data.rawContent}');
  },
)
```

## Example app

Find the example app [here](https://github.com/phucanh08/barcode_scanner/tree/master/example).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/phucanh08/barcode_scanner/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/phucanh08/barcode_scanner/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/phucanh08/barcode_scanner/pulls) directly.