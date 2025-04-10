package com.anhlp.barcode_scanner

import com.anhlp.barcode_scanner.platform_view.BarcodeScannerViewFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin

class BarcodeScannerPlugin : FlutterPlugin {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding
            .platformViewRegistry
            .registerViewFactory(
                "barcode_scanner_view",
                BarcodeScannerViewFactory(flutterPluginBinding.binaryMessenger)
            )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
