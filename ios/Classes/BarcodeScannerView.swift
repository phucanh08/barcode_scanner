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
    let imageView = UIImageView()
    
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
        imageView.frame = _view.bounds // Đặt kích thước bằng với view cha
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Auto resize
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true // Ẩn ban đầu
        _view.addSubview(imageView)
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
            DispatchQueue.main.async {
                self.scannerViewController.view.isHidden = false
                self.imageView.image = nil
                self.imageView.isHidden = true
            }
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
        guard let image = UIImage(contentsOfFile: fileURL.path)?.fixOrientation() else {
            print("Không thể tải hình ảnh từ đường dẫn: \(path)")
            result(FlutterError(code: "INVALID_IMAGE", message: "Không thể tải hình ảnh từ đường dẫn: \(path)", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            self.imageView.subviews.forEach { $0.removeFromSuperview() }
            self.imageView.image = image
            self.imageView.isHidden = false
            self.scannerViewController.view.isHidden = true
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
            DispatchQueue.main.async {
                for barcode in results {
                    self.drawBoundingBox(for: barcode, in: image)
                }
            }
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
    
    func drawBoundingBox(for barcode: VNBarcodeObservation, in image: UIImage) {
        let boundingBox = barcode.boundingBox // (x, y, width, height) normalized từ 0 - 1
        
        let imageViewSize = imageView.bounds.size
        let imageSize = image.size
        
        let scaleX = imageViewSize.width / imageSize.width
        let scaleY = imageViewSize.height / imageSize.height

        // Tính toán scale để khớp với ImageView
        let scale = (imageViewSize.width / imageSize.width * imageSize.height > imageViewSize.height) ? scaleY : scaleX

        let wLost = (scale == scaleY) ? (imageSize.width * scale - imageViewSize.width) / 2 : 0
        let hLost = (scale == scaleY) ? 0 : (imageSize.height * scale - imageViewSize.height) / 2

        // Chuyển đổi tọa độ bounding box
        let x = boundingBox.origin.x * imageSize.width * scale - wLost
        let y = (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height * scale - hLost
        let width = boundingBox.width * imageSize.width * scale
        let height = boundingBox.height * imageSize.height * scale

        let boxView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        boxView.layer.borderColor = UIColor.green.cgColor
        boxView.layer.borderWidth = 2
        boxView.backgroundColor = UIColor.clear

        imageView.addSubview(boxView)
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

extension UIImage {
    func fixOrientation() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        if self.imageOrientation == .up { return self }

        var transform = CGAffineTransform.identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0).rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height).rotated(by: -.pi / 2)
        default:
            break
        }

        guard let colorSpace = cgImage.colorSpace,
              let ctx = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: cgImage.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: cgImage.bitmapInfo.rawValue
              ) else { return self }

        ctx.concatenate(transform)
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        guard let newCgImage = ctx.makeImage() else { return self }
        return UIImage(cgImage: newCgImage)
    }
}
