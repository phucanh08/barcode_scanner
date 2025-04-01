# Barcode Scanner

[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

## Requirements

### iOS

- Minimum iOS Deployment Target: 12
- Xcode 15.3.0 or newer
- Swift 5

Add the following keys to your _Info.plist_ file, located in
`<project root>/ios/Runner/Info.plist`:

* `NSCameraUsageDescription` - describe why your app needs access to the camera.
  This is called _Privacy - Camera Usage Description_ in the visual editor.

### Android

- minSdkVersion: 24
- targetSdkVersion: 35
- compileSdkVersion: 35

For Android, you must do the following before you can use the plugin:
* Add the camera permission to your AndroidManifest.xml

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