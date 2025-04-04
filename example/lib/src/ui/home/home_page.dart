import 'package:flutter/cupertino.dart';

import '../genneral_scanner/genneral_scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Center(
      child: CupertinoButton(
        child: const Text('Click me'),
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const GeneralScannerPage()),
          );
        },
      ),
    ));
  }
}
