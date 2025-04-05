import 'package:barcode_scanner/barcode_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'widgets/flash_button.dart';
import 'widgets/general_scanner_bottom_sheet.dart';

class GeneralScannerPage extends StatelessWidget {
  const GeneralScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    void onPickImageButtonPressed() async {
      try {
        BarcodeScanner().pauseCamera();
        final image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) {
          final results =
              await BarcodeScanner().detectBarcodesByImagePath(image.path);
          for (var e in results ?? []) {
            debugPrint("Mã vạch phát hiện: ${e.toString()}");
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
    }

    void onSettingsButtonPressed() async {}

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('General Scanner'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onPickImageButtonPressed,
              child: Icon(
                CupertinoIcons.photo,
                color: theme.primaryContrastingColor,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onSettingsButtonPressed,
              child: Icon(
                CupertinoIcons.settings,
                color: theme.primaryContrastingColor,
              ),
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          BarcodeScannerView(
            options: Configuration(
              barcodeFormats: [
                BarcodeFormat.qr,
                BarcodeFormat.pdf417,
              ],
              cameraSettings: CameraSettings(
                resolutionPreset: ResolutionPreset.hd1280x720,
                cameraPosition: CameraPosition.back
              ),
              resultSettings: ResultSettings(
                beepOnScan: false,
                vibrateOnScan: false,
              ),
            ),
            onData: (data) {
              debugPrint('Barcode data: ${data.toProto3Json()}');
            },
          ),
          const Positioned(top: 100, left: 20, child: FlashButton()),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GeneralScannerBottomSheet(),
          )
        ],
      ),
    );
  }
}
