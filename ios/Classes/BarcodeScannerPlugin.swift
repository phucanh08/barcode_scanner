import Flutter
import UIKit

public class BarcodeScannerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "barcode_scanner", binaryMessenger: registrar.messenger())
        let instance = BarcodeScannerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    
        
        let factory = BarcodeScannerViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "barcode_scanner_view")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
