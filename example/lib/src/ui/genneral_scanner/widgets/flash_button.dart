import 'package:barcode_scanner/barcode_scanner.dart';
import 'package:flutter/cupertino.dart';

class FlashButton extends StatefulWidget {
  const FlashButton({Key? key}) : super(key: key);

  @override
  State<FlashButton> createState() => _FlashButtonState();
}

class _FlashButtonState extends State<FlashButton> {
  bool isFlashOn = false;
  final barcodeScanner = BarcodeScanner();

  void onToggleFlash() async {
    final result = await barcodeScanner.toggleFlash();
    setState(() => isFlashOn = result);
  }

  void getFlashState() {
    barcodeScanner.isFlashOn().then((value) {
      if (mounted) setState(() => isFlashOn = value);
    });
  }

  @override
  void initState() {
    getFlashState();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FlashButton oldWidget) {
    getFlashState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onToggleFlash,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.barBackgroundColor,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          isFlashOn ? CupertinoIcons.bolt_slash_fill : CupertinoIcons.bolt_fill,
          color: theme.primaryContrastingColor,
        ),
      ),
    );
  }
}
