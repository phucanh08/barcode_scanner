import Flutter
import UIKit

public class BarcodeScannerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = BarcodeScannerViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "barcode_scanner_view")
    }
}
