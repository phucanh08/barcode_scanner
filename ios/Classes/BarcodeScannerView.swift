import Flutter
import UIKit
import Vision

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
    let methodChannel: FlutterMethodChannel
    let eventChannelHandler: EventChannelHandler
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        scannerViewController = BarcodeScannerViewController()
        eventChannelHandler = EventChannelHandler()
        methodChannel = FlutterMethodChannel(name: "com.anhlp.barcode_scanner/methods_\(viewId)", binaryMessenger: messenger)
        eventChannel = FlutterEventChannel(name: "com.anhlp.barcode_scanner/events_\(viewId)", binaryMessenger: messenger)
        super.init()
        methodChannel.setMethodCallHandler (self.methodChanelHandler)
        eventChannel.setStreamHandler(eventChannelHandler)
        
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
    
    private func methodChanelHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "detectBarcodesByImagePath":
            self.detectBarcodes(inImageAtPath: call.arguments as! String, result: result)
            break
        case "pauseCamera":
            self.scannerViewController.freezeCapture()
            break;
        case "resumeCamera":
            self.scannerViewController.unfreezeCapture()
            break;
        default:
            break
        }
    }
    
    
    func detectBarcodes(inImageAtPath path: String, result: @escaping FlutterResult) {
        // 1. Tạo URL từ đường dẫn tệp
        let fileURL = URL(fileURLWithPath: path)
        
        // 2. Tải hình ảnh từ URL
        guard let image = UIImage(contentsOfFile: fileURL.path) else {
            print("Không thể tải hình ảnh từ đường dẫn: \(path)")
            result(FlutterError(code: "INVALID_IMAGE", message: "Không thể tải hình ảnh từ đường dẫn: \(path)", details: nil))
            return
        }
        
        // 3. Chuyển đổi UIImage thành CIImage
        guard let ciImage = CIImage(image: image) else {
            print("Không thể tạo CIImage từ UIImage.")
            result(FlutterError(code: "SCAN_ERROR", message: "Không thể tạo CIImage từ UIImage.", details: nil))
            return
        }
        
        // 4. Tạo yêu cầu phát hiện mã vạch
        let barcodeRequest = VNDetectBarcodesRequest { (request, error) in
            if let error = error {
                print("Lỗi khi phát hiện mã vạch: \(error.localizedDescription)")
                result(FlutterError(code: "SCAN_ERROR", message:"Lỗi khi phát hiện mã vạch: \(error.localizedDescription)", details: nil))
                return
            }
            guard let results = request.results as? [VNBarcodeObservation] else {
                print("Không có mã vạch nào được phát hiện.")
                result(FlutterError(code: "NO_BARCODE", message:"Không tìm thấy mã vạch trong ảnh", details: nil))
                return
            }
            
            // 5. Xử lý kết quả
            result(results.map { $0.payloadStringValue ?? "" }.filter { !$0.isEmpty })
            
        }
        
        // 6. Tạo và thực thi VNImageRequestHandler
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([barcodeRequest])
        } catch {
            print("Không thể thực hiện yêu cầu phát hiện mã vạch: \(error.localizedDescription)")
            result(FlutterError(code: "Error when scanning barcodes", message:"Không thể thực hiện yêu cầu phát hiện mã vạch: \(error.localizedDescription)", details: nil))
        }
    }
    
    
    func didScanBarcodeWithResult(_ controller: BarcodeScannerViewController?, scanResult: ScanResult) {
        do {
            eventChannelHandler.eventSink?(try scanResult.serializedData())
        } catch {
            eventChannelHandler.eventSink?(FlutterError(code: "err_serialize", message: "Failed to serialize the result", details: nil))
        }
    }
    
    func didFailWithErrorCode(_ controller: BarcodeScannerViewController?, errorCode: String) {
        eventChannelHandler.eventSink?(FlutterError(code: errorCode, message: nil, details: nil))
    }
    
}

class EventChannelHandler: NSObject, FlutterStreamHandler {
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
