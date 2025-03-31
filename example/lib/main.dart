import 'package:barcode_scanner/gen/protos/protos.pb.dart';
import 'package:barcode_scanner/model/model.dart';
import 'package:flutter/material.dart';

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
          title: const Text('Plugin example app'),
        ),
        body: BarcodeScannerView(
          options: const ScanOptions(
            restrictFormat: [
              BarcodeFormat.qr,
              BarcodeFormat.pdf417,
            ],
            android: AndroidOptions(useAutoFocus: false)
            // strings: {},
          ),
          onData: (data) {
            print('Barcode data: ${data.rawContent}');
          },
        ),
      ),
    );
  }
}
