import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'barcode_scanner_platform_interface.dart';
import 'model/scan_options.dart';
import 'model/scan_result.dart';

import 'gen/protos/protos.pb.dart' as proto;

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({
    Key? key,
    this.onData,
    this.onError,
    required this.options,
  }) : super(key: key);

  final void Function(ScanResult)? onData;
  final void Function(String)? onError;
  final ScanOptions options;

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
          final tmpResult = proto.ScanResult.fromBuffer(event);
          widget.onData?.call(ScanResult(
            format: tmpResult.format,
            formatNote: tmpResult.formatNote,
            rawContent: tmpResult.rawContent,
            type: tmpResult.type,
          ));
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error receiving event: $e');
        }
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
    final config = proto.Configuration()
      ..useCamera = widget.options.useCamera
      ..restrictFormat.addAll(widget.options.restrictFormat)
      ..autoEnableFlash = widget.options.autoEnableFlash
      ..strings.addAll(widget.options.strings)
      ..android = (proto.AndroidConfiguration()
        ..useAutoFocus = widget.options.android.useAutoFocus
        ..aspectTolerance = widget.options.android.aspectTolerance
        ..appBarTitle = widget.options.android.appBarTitle);
    const viewType = 'barcode_scanner_view';
    const hitTestBehavior = PlatformViewHitTestBehavior.opaque;
    const layoutDirection = TextDirection.ltr;
    final creationParams = config.writeToBuffer();
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
