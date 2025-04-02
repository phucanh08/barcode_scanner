import 'package:flutter/cupertino.dart';

import 'ui/genneral_scanner/genneral_scanner_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: GeneralScannerPage(),
    );
  }
}