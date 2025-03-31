import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_scanner/barcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Plugin example app',
            style: TextStyle(color: Colors.white),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: CupertinoButton(
            child: const Icon(
              CupertinoIcons.photo,
              color: Colors.white,
            ),
            onPressed: () async {
              BarcodeScanner().pauseCamera();
              final image = await ImagePicker()
                  .pickImage(source: ImageSource.gallery);
              if (image != null) {
                final results = await BarcodeScanner()
                    .detectBarcodesByImagePath(image.path);
                for (var e in results ?? []) {
                  debugPrint("Mã vạch phát hiện: $e");
                }
              }
              BarcodeScanner().resumeCamera();
            },
          ),
        ),
        body: BarcodeScannerView(
          options: const ScanOptions(
            restrictFormat: [
              BarcodeFormat.qr,
              BarcodeFormat.pdf417,
            ],
            android: AndroidOptions(useAutoFocus: false),
            // strings: {},
          ),
          onData: (data) {
            debugPrint('Barcode data: ${data.rawContent}');
          },
        ),
      ),
    );
  }
}