//
//  BarcodeScanner.swift
//  Pods
//
//  Created by TTGP-oaidq-mac on 31/3/25.
//

import Flutter
import UIKit

class BarcodeScannerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return BarcodeScannerView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
    
    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class BarcodeScannerView: NSObject, FlutterPlatformView, BarcodeScannerViewControllerDelegate {
    private var _view: UIView
    let scannerViewController: BarcodeScannerViewController
    let eventChannel: FlutterEventChannel
    let swiftStreamHandler: SwiftStreamHandler
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        scannerViewController = BarcodeScannerViewController()
        swiftStreamHandler = SwiftStreamHandler()
        eventChannel = FlutterEventChannel(name: "flutter_barcode_scanner_\(viewId)", binaryMessenger: messenger)
        eventChannel.setStreamHandler(swiftStreamHandler)
        
        super.init()
        
        do {
            let configuration = try Configuration(serializedBytes: (args as! FlutterStandardTypedData).data)
            scannerViewController.config = configuration
        } catch {
            
        }

        scannerViewController.delegate = self
        _view.addSubview(scannerViewController.view)
    }
    
    func view() -> UIView {
        return _view
    }
    
    func didScanBarcodeWithResult(_ controller: BarcodeScannerViewController?, scanResult: ScanResult) {
        do {
            swiftStreamHandler.eventSink?(try scanResult.serializedData())
        } catch {
            swiftStreamHandler.eventSink?(FlutterError(code: "err_serialize", message: "Failed to serialize the result", details: nil))
        }
    }
    
    func didFailWithErrorCode(_ controller: BarcodeScannerViewController?, errorCode: String) {
        swiftStreamHandler.eventSink?(FlutterError(code: errorCode, message: nil, details: nil))
    }
    
}

class SwiftStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
