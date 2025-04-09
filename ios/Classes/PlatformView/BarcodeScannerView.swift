import Flutter
import AVFoundation

class BarcodeScannerView: NSObject, FlutterPlatformView, VideoSampleBufferDelegate {
    private let _view: UIView
    private let imageView = UIImageView()
    private let boundingBoxOverlay = BoundingBoxOverlay()
    
    private let barcodeScanner = BarcodeScanner()
    private let cameraManager = CameraManager()
    
    private let eventChannel: FlutterEventChannel
    private let methodChannel: FlutterMethodChannel
    private let eventChannelHandler = EventChannelHandler()
    
    private var isProcessingImagePath: Bool = false
    private var isProcessingLivestream: Bool = false
    private var beepOnScan: Bool = false
    private var vibrationOnScan: Bool = false
    
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
        
        _view.addSubview(cameraManager.view)
        _view.addSubview(imageView)
        _view.addSubview(boundingBoxOverlay)
        
        methodChannel = FlutterMethodChannel(name: "com.anhlp.barcode_scanner/methods_\(viewId)", binaryMessenger: messenger)
        eventChannel = FlutterEventChannel(name: "com.anhlp.barcode_scanner/events_\(viewId)", binaryMessenger: messenger)
        super.init()
        methodChannel.setMethodCallHandler (self.methodChanelHandler)
        eventChannel.setStreamHandler(eventChannelHandler)
        
        cameraManager.delegate = self
        
        do {
            let configuration = try Configuration(serializedBytes: (args as! FlutterStandardTypedData).data)
            beepOnScan = configuration.resultSettings.beepOnScan
            vibrationOnScan = configuration.resultSettings.vibrateOnScan
            cameraManager.setCameraSettings(configuration.cameraSettings)
            barcodeScanner.setFormats(configuration.barcodeFormats)
        } catch {
            
        }
        cameraManager.startCamera()
    }
    
    func view() -> UIView {
        return _view
    }
    
    func didReceiveSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        if (!isProcessingLivestream && !cameraManager.isPauseCamera) {
            isProcessingLivestream = true
            DispatchQueue.global(qos: .userInitiated).async {
                defer {
                    self.isProcessingLivestream = false
                }
                let results = self.barcodeScanner.process(sampleBuffer: sampleBuffer)
                var rect: CGRect? = nil
                
                var image: UIImage? = nil
                if (!results.isEmpty && !self.cameraManager.isPauseCamera) {
                    let boundingBox = results[0].boundingBox
                    rect = CGRect(x: CGFloat(boundingBox.left), y: CGFloat(boundingBox.top), width: CGFloat(boundingBox.right - boundingBox.left), height: CGFloat(boundingBox.bottom - boundingBox.top))
                    image = UIImage.imageFromSampleBuffer(sampleBuffer)
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        self.imageView.isHidden = false
                        self.imageView.contentMode = .scaleAspectFill
                        self.cameraManager.view.isHidden = true
                        self.updateBoundingBoxOverlay(rect, size: image?.size)
                        self.didScanBarcodeWithResults(results)
                    }
                }
            }
        }
        
    }
    
    private func updateBoundingBoxOverlay(_ rect: CGRect?, size: CGSize? = nil) {
        let isProcessingImagePath = isProcessingImagePath
        if (cameraManager.isPauseCamera && !isProcessingImagePath) { return }
        
        guard let boundingBox = rect else {
            boundingBoxOverlay.clear()
            return
        }
        
        self.cameraManager.pauseCameraPreview()
        
        let imageSize = size ?? cameraManager.getSize()
        boundingBoxOverlay.setBoundingBox(boundingBox, imageSize: imageSize, isFitContain: !isProcessingImagePath)
    }
    
    private func didScanBarcodeWithResults(_ results: [BarcodeResult]) {
        do {
            if(!results.isEmpty) {
                eventChannelHandler.eventSink?(try results.map { try $0.serializedData() })
                DispatchQueue.main.async {
                    if (self.beepOnScan) {
                        // Beep (system sound ID 1057 is a short tone, you can try different ones)
                        AudioServicesPlaySystemSound(1057)
                    }
                    if (self.vibrationOnScan) {
                        // Vibrate
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.prepare()
                        generator.impactOccurred()
                    }
                    
                }
            }
        } catch {
            eventChannelHandler.eventSink?(FlutterError(code: "err_serialize", message: "Failed to serialize the result", details: nil))
        }
    }
}

extension BarcodeScannerView {
    private func methodChanelHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "detectBarcodesByImagePath":
            DispatchQueue.main.async {
                self.boundingBoxOverlay.clear()
            }
            detectBarcodesByImagePath(call.arguments as! String, result: result)
            break
        case "pauseCamera":
            self.cameraManager.pauseCameraPreview()
            result(cameraManager.isPauseCamera)
            break;
        case "resumeCamera":
            DispatchQueue.main.async {
                self.boundingBoxOverlay.clear()
                self.cameraManager.view.isHidden = false
                self.imageView.image = nil
                self.imageView.isHidden = true
                self.imageView.contentMode = .scaleAspectFit
                self.isProcessingLivestream = false
            }
            self.cameraManager.resumeCameraPreview()
            result(!cameraManager.isPauseCamera)
            break;
        case "isFlashOn":
            let isFlashOn = self.cameraManager.isFlashOn()
            result(isFlashOn)
            break;
        case "toggleFlash":
            let data = self.cameraManager.toggleFlash()
            result(data)
            break;
        default:
            break
        }
    }
    
    private func detectBarcodesByImagePath(_ path: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.isProcessingImagePath = true
                self.imageView.contentMode = .scaleAspectFit
            }
            let fileURL = URL(fileURLWithPath: path)
            
            guard let image = UIImage(contentsOfFile: fileURL.path)?.fixOrientation() else {
                print("Không thể tải hình ảnh từ đường dẫn: \(path)")
                result(FlutterError(code: "INVALID_IMAGE", message: "Không thể tải hình ảnh từ đường dẫn: \(path)", details: nil))
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageView.isHidden = false
                self.cameraManager.view.isHidden = true
            }
            
            
            let barcodes = self.barcodeScanner.process(image: image)
            
            DispatchQueue.main.async {
                defer {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isProcessingImagePath = false
                    }
                }
                
                if !barcodes.isEmpty {
                    let boundingBox = barcodes[0].boundingBox
                    let width = CGFloat(boundingBox.right - boundingBox.left)
                    let height = CGFloat(boundingBox.bottom - boundingBox.top)
                    let rect = CGRect(x: CGFloat(boundingBox.top), y: 1 - CGFloat(boundingBox.right), width: height, height: width)
                    
                    
                    DispatchQueue.main.async {
                        self.updateBoundingBoxOverlay(rect, size: image.size)
                    }
                }
                do {
                    result(try barcodes.map { try $0.serializedData() })
                    return
                } catch {
                    print("❌ Lỗi chuyển đổi dữ liệu: result(try barcodes.map { try $0.serializedData() })")
                }
                result([])
            }
        }
        
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
