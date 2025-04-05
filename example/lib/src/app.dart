import 'package:flutter/cupertino.dart';

import 'ui/home/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: HomePage(),
    );
  }
}