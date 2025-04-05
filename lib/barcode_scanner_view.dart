import 'dart:async';
import 'dart:io';

import 'package:barcode_scanner/mapper/mapper.dart';
import 'package:barcode_scanner/models/barcode.dart';
import 'package:barcode_scanner/models/barcode_scanner_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'barcode_scanner_platform_interface.dart';

import 'gen/protos/protos.pb.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({
    Key? key,
    this.onData,
    this.onError,
    required this.options,
  }) : super(key: key);

  final void Function(List<Barcode> barcodes)? onData;
  final void Function(String)? onError;
  final BarcodeScannerOptions options;

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  StreamSubscription? streamSubscription;

  void onPlatformViewCreated(int platformViewId) {
    BarcodeScannerPlatform.instance.init(platformViewId);
    final eventChannel =
        EventChannel('com.anhlp.barcode_scanner/events_$platformViewId');
    streamSubscription = eventChannel.receiveBroadcastStream().listen((event) {
      try {
        if (event != null) {
          final barcodes =
              (event as List<dynamic>).map((e) => BarcodeResult.fromBuffer(e));
          if (barcodes.isNotEmpty) {
            widget.onData?.call(barcodes.map((e) => Barcode.fromProtos(e)).toList());
          }
        }
      } catch (e) {
        debugPrint('Error receiving event: $e');
        widget.onError?.call(e.toString());
      }
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const viewType = 'barcode_scanner_view';
    const hitTestBehavior = PlatformViewHitTestBehavior.opaque;
    const layoutDirection = TextDirection.ltr;
    final creationParams = widget.options.toProtos().writeToBuffer();
    const creationParamsCodec = StandardMessageCodec();
    const gestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{};

    switch (Platform.operatingSystem) {
      case 'android':
        return PlatformViewLink(
          viewType: viewType,
          surfaceFactory: (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: gestureRecognizers,
              hitTestBehavior: hitTestBehavior,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            final controller = PlatformViewsService.initExpensiveAndroidView(
              id: params.id,
              viewType: viewType,
              creationParams: creationParams,
              layoutDirection: layoutDirection,
              creationParamsCodec: creationParamsCodec,
              onFocus: () => params.onFocusChanged(true),
            );
            controller
                .addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
            controller.addOnPlatformViewCreatedListener(onPlatformViewCreated);
            controller.create();

            return controller;
          },
        );
      case 'ios':
        return UiKitView(
          viewType: viewType,
          onPlatformViewCreated: onPlatformViewCreated,
          hitTestBehavior: hitTestBehavior,
          layoutDirection: layoutDirection,
          creationParams: creationParams,
          creationParamsCodec: creationParamsCodec,
          gestureRecognizers: gestureRecognizers,
        );
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}
