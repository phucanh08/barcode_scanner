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
      home: Builder(builder: (context) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
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
                try {
                  BarcodeScanner().pauseCamera();
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final results = await BarcodeScanner()
                        .detectBarcodesByImagePath(image.path);
                    for (var e in results ?? []) {
                      debugPrint("Mã vạch phát hiện: $e");
                    }
                  } else {
                    BarcodeScanner().resumeCamera();
                  }
                } catch (e) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Đã có lỗi xảy ra'),
                          content: Text('An error occurred: $e'),
                          actions: [
                            CupertinoButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                BarcodeScanner().resumeCamera();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
          body: Stack(
            children: [
              BarcodeScannerView(
                options: const ScanOptions(
                  restrictFormat: [
                    BarcodeFormat.qr,
                    BarcodeFormat.pdf417,
                  ],
                ),
                onData: (data) {
                  debugPrint('Barcode data: ${data.rawContent}');
                },
              ),
              Center(
                child: CupertinoButton(
                  child: const Text('Resume Camera'),
                  onPressed: () {
                    BarcodeScanner().resumeCamera();
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
