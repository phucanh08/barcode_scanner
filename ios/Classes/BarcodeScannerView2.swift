import Flutter
import AVFoundation

class BarcodeScannerView2: NSObject, FlutterPlatformView, VideoSampleBufferDelegate, BarcodeScannerListener {
    private let _view: UIView
    private let imageView = UIImageView()
    private let boundingBoxOverlay = BoundingBoxOverlay()
    private let barcodeDetector = BarcodeDetector(formats: [])
    private let scannerViewController = BarcodeScannerViewController2()
    
    private let eventChannel: FlutterEventChannel
    private let methodChannel: FlutterMethodChannel
    private let eventChannelHandler = EventChannelHandler()
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        
        imageView.frame = _view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        
        boundingBoxOverlay.frame = _view.bounds
        boundingBoxOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        boundingBoxOverlay.backgroundColor = .clear
        boundingBoxOverlay.isUserInteractionEnabled = false
        
        _view.addSubview(scannerViewController.view)
        _view.addSubview(imageView)
        _view.addSubview(boundingBoxOverlay)
        
        methodChannel = FlutterMethodChannel(name: "com.anhlp.barcode_scanner/methods_\(viewId)", binaryMessenger: messenger)
        eventChannel = FlutterEventChannel(name: "com.anhlp.barcode_scanner/events_\(viewId)", binaryMessenger: messenger)
        super.init()
        methodChannel.setMethodCallHandler (self.methodChanelHandler)
        eventChannel.setStreamHandler(eventChannelHandler)
        
        scannerViewController.delegate = self
        barcodeDetector.delegate = self
       
        
        
        do {
            let configuration = try Configuration(serializedBytes: (args as! FlutterStandardTypedData).data)
            scannerViewController.setResolution(resolution: configuration.cameraSettings.resolution)
        } catch {
            
        }
        scannerViewController.startCamera()
    }
    
    func view() -> UIView {
        return _view
    }
    
    func didReceiveSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.barcodeDetector.process(sampleBuffer: sampleBuffer)
        }
    }
    
    func didUpdateBoundingBoxOverlay(_ rect: CGRect?, size: CGSize? = nil) {
        if let imageSize = size {
            drawImagePathOverlay(rect, imageSize: imageSize)
        } else {
            let cameraSize = scannerViewController.getSize()
            drawCameraImageOverlay(rect, imageSize: cameraSize)
        }
    }
    
    func didScanBarcodeWithResults(_ results: [ScanResult]) {
        do {
            if(!results.isEmpty) {
                eventChannelHandler.eventSink?(try results.first!.serializedData())
            }
        } catch {
            eventChannelHandler.eventSink?(FlutterError(code: "err_serialize", message: "Failed to serialize the result", details: nil))
        }
    }
    
    func didFailWithErrorCode(_ code: String, _ message: String, _ details: Any?) {
        eventChannelHandler.eventSink?(FlutterError(code: code, message: message, details: details))
    }
}

extension BarcodeScannerView2 {
    private func methodChanelHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "detectBarcodesByImagePath":
            detectBarcodesByImagePath(call.arguments as! String, result: result)
            break
        case "pauseCamera":
            self.scannerViewController.pauseCameraPreview()
            result(scannerViewController.isPauseCamera)
            break;
        case "resumeCamera":
            DispatchQueue.main.async {
                self.scannerViewController.view.isHidden = false
                self.imageView.image = nil
                self.imageView.isHidden = true
            }
            self.scannerViewController.resumeCameraPreview()
            result(!scannerViewController.isPauseCamera)
            break;
        case "isFlashOn":
            let isFlashOn = self.scannerViewController.isFlashOn()
            result(isFlashOn)
            break;
        case "toggleFlash":
            let data = self.scannerViewController.toggleFlash()
            result(data)
            break;
        default:
            break
        }
    }
    
    private func detectBarcodesByImagePath(_ path: String, result: @escaping FlutterResult) {
        if #available(iOS 13.0, *) {
            Task {
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
                
                
                let barcodes = self.barcodeDetector.process(image)
               
                DispatchQueue.main.async {
                    if barcodes.isEmpty {
                        print("❌ Không tìm thấy barcode nào")
                    } else {
                        for barcode in barcodes {
                            print("✅ Barcode detected: \(barcode.rawContent)")
                        }
                    }
                    result(barcodes.map { $0.rawContent }) // Trả về danh sách barcode
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func drawCameraImageOverlay(_ rect: CGRect?, imageSize: CGSize) {
        // Xóa tất cả các subview cũ
        boundingBoxOverlay.subviews.forEach { $0.removeFromSuperview() }
        
        guard let rect = rect else { return }
        
        // Tạo view chứa bounding box
        let boxView = UIView(frame: boundingBoxOverlay.bounds)
        boxView.backgroundColor = .clear
        boundingBoxOverlay.addSubview(boxView)
        
        // Tạo layer để vẽ bounding box
        let boxLayer = CAShapeLayer()
        boxLayer.lineWidth = 3.0
        boxLayer.strokeColor = UIColor.green.cgColor
        boxLayer.fillColor = UIColor.clear.cgColor
        
        // Tạo path để vẽ bounding box
        let boxRect = CGRect(
            x: rect.origin.x * boxView.bounds.width,
            y: rect.origin.y * boxView.bounds.height,
            width: rect.width * boxView.bounds.width,
            height: rect.height * boxView.bounds.height
        )
        
        let path = UIBezierPath(rect: boxRect)
        boxLayer.path = path.cgPath
        
        // Thêm transform cho layer phù hợp với orientation của camera
        // Lấy thông tin orientation từ AVCaptureConnection của camera
        let videoOrientation = scannerViewController.getCameraOrientation()
        
        // Áp dụng transform dựa trên orientation
        var transform = CGAffineTransform.identity
        
        switch videoOrientation {
        case .portrait:
            transform = transform.translatedBy(x: boxView.bounds.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
        case .portraitUpsideDown:
            transform = transform.translatedBy(x: 0, y: boxView.bounds.height)
            transform = transform.rotated(by: -.pi / 2)
            break
        case .landscapeLeft:
           
            break
        case .landscapeRight:
            transform = transform.translatedBy(x: boxView.bounds.width, y: boxView.bounds.height)
            transform = transform.rotated(by: .pi)
            break
        @unknown default:
            break
        }
        
        boxLayer.setAffineTransform(transform)
        boxView.layer.addSublayer(boxLayer)
    }
    
    private func drawImagePathOverlay(_ rect: CGRect?, imageSize: CGSize) {
        if let rect = rect {
            let boundingBox = rect // (x, y, width, height) normalized từ 0 - 1
            
            let imageViewSize = imageView.bounds.size
            
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

            boundingBoxOverlay.setBoundingBox(CGRect(x: x, y: imageViewSize.height - y - height, width: width, height: height))
        } else {
            boundingBoxOverlay.setBoundingBox(nil)
        }
    }
}

class BoundingBoxOverlay: UIView {
    private var rect: CGRect?
    
    func setBoundingBox(_ rect: CGRect?) {
        self.rect = rect
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let boundingRect = self.rect else { return }
        
        let path = UIBezierPath(rect: boundingRect)
        path.lineWidth = 3.0
        UIColor.green.setStroke()
        path.stroke()
    }
}
