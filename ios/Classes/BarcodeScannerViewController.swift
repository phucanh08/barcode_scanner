import Foundation
import MTBBarcodeScanner

class BarcodeScannerViewController: UIViewController {
    private var overlayViews = [String: UIView]()
    private var previewView: UIView?
    private var scanner: MTBBarcodeScanner?
    private var isFreezeCapture: Bool = false
    
    var config: Configuration = Configuration()
    
    private let formatMap = [
        BarcodeFormat.aztec : AVMetadataObject.ObjectType.aztec,
        BarcodeFormat.code39 : AVMetadataObject.ObjectType.code39,
        BarcodeFormat.code93 : AVMetadataObject.ObjectType.code93,
        BarcodeFormat.code128 : AVMetadataObject.ObjectType.code128,
        BarcodeFormat.dataMatrix : AVMetadataObject.ObjectType.dataMatrix,
        BarcodeFormat.ean8 : AVMetadataObject.ObjectType.ean8,
        BarcodeFormat.ean13 : AVMetadataObject.ObjectType.ean13,
        BarcodeFormat.interleaved2Of5 : AVMetadataObject.ObjectType.interleaved2of5,
        BarcodeFormat.pdf417 : AVMetadataObject.ObjectType.pdf417,
        BarcodeFormat.qr : AVMetadataObject.ObjectType.qr,
        BarcodeFormat.upce : AVMetadataObject.ObjectType.upce,
    ]
    
    var delegate: BarcodeScannerViewControllerDelegate?
    
    private var device: AVCaptureDevice? {
        return AVCaptureDevice.default(for: .video)
    }
    
    private var isFlashOn: Bool {
        let settings = AVCapturePhotoSettings()
        return device != nil && (settings.flashMode == AVCaptureDevice.FlashMode.on || device?.torchMode == .on)
    }
    
    private var hasTorch: Bool {
        return device?.hasTorch ?? false
    }
    
    public func freezeCapture() {
        self.scanner?.freezeCapture()
        isFreezeCapture = true
    }
    public func unfreezeCapture() {
        self.previewView.subviews.forEach { $0.removeFromSuperview() }
        self.scanner?.unfreezeCapture()
        isFreezeCapture = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        
#if targetEnvironment(simulator)
        view.backgroundColor = .lightGray
#endif
        
        previewView = UIView(frame: view.bounds)
        if let previewView = previewView {
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(previewView)
        }
        
        let restrictedBarcodeTypes = mapRestrictedBarcodeTypes()
        if restrictedBarcodeTypes.isEmpty {
            scanner = MTBBarcodeScanner(previewView: previewView)
        } else {
            scanner = MTBBarcodeScanner(metadataObjectTypes: restrictedBarcodeTypes,
                                        previewView: previewView
            )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if scanner!.isScanning() {
            scanner!.stopScanning()
        }
        
        UIDevice.current.endGeneratingDeviceOrientationNotifications()

        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                self.startScan()
            } else {
#if !targetEnvironment(simulator)
                self.errorResult(errorCode: "PERMISSION_NOT_GRANTED")
#endif
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        scanner?.stopScanning()
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        if isFlashOn {
            setFlashState(false)
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func startScan() {
        do {
            try scanner!.startScanning(with: cameraFromConfig, resultBlock: { codes in
                self.drawOverlays(on: codes)
                if (self.isFreezeCapture) {return}
                if let code = codes?.first {
                    let codeType = self.formatMap.first(where: { $0.value == code.type });
                    let scanResult = ScanResult.with {
                        $0.type = .barcode
                        $0.rawContent = code.stringValue ?? ""
                        $0.format = codeType?.key ?? .unknown
                        $0.formatNote = codeType == nil ? code.type.rawValue : ""
                    }
                    self.freezeCapture()
                    self.scanResult(scanResult)
                }
            })
        } catch {
            self.scanResult(ScanResult.with {
                $0.type = .error
                $0.rawContent = "\(error)"
                $0.format = .unknown
            })
        }
    }
    
    private func drawOverlays(on codes: [AVMetadataMachineReadableCodeObject]?) {
        // Lấy tất cả các chuỗi mã đã quét được
        var codeStrings = [String]()
        
        guard let codes = codes else {
            for (code, overlayView) in overlayViews {
                if !codeStrings.contains(code) {
                    overlayView.removeFromSuperview()
                    overlayViews.removeValue(forKey: code)
                }
            }
            return
        }
        for code in codes {
            if let stringValue = code.stringValue {
                codeStrings.append(stringValue)
            }
        }
        
        // Loại bỏ các overlay không còn hiển thị trên màn hình
        for (code, overlayView) in overlayViews {
            if !codeStrings.contains(code) {
                overlayView.removeFromSuperview()
                overlayViews.removeValue(forKey: code)
            }
        }
        
        for code in codes {
            if let codeString = code.stringValue {
                if let overlayView = overlayViews[codeString] {
                    // Overlay đã tồn tại, cập nhật vị trí mới
                    overlayView.frame = code.bounds
                } else {
                    // Lần đầu tiên thấy mã này
                    let isValidCode = isValidCodeString(codeString)
                    
                    // Tạo một overlay mới
                    let overlayView = overlay(for: codeString, bounds: code.bounds, valid: isValidCode)
                    overlayViews[codeString] = overlayView
                    
                    // Thêm overlay vào previewView
                    previewView?.addSubview(overlayView)
                }
            }
        }
    }
    
    func isValidCodeString(_ codeString: String) -> Bool {
        // Thực hiện kiểm tra tính hợp lệ của mã
        return true
    }
    
    func overlay(for codeString: String, bounds: CGRect, valid: Bool) -> UIView {
        // Tạo và trả về một UIView đại diện cho overlay
        let overlayView = UIView(frame: bounds)
        overlayView.layer.borderWidth = 2
        overlayView.layer.borderColor = valid ? UIColor.green.cgColor : UIColor.red.cgColor
        return overlayView
    }
    
    @objc private func cancel() {
        scanResult( ScanResult.with {
            $0.type = .cancelled
            $0.format = .unknown
        });
    }
    
    @objc private func onToggleFlash() {
        setFlashState(!isFlashOn)
    }
    
    private func setFlashState(_ on: Bool) {
        if let device = device {
            guard device.hasFlash && device.hasTorch else {
                return
            }
            
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            let settings = AVCapturePhotoSettings()
            
            settings.flashMode = on ? .on : .off
            device.torchMode = on ? .on : .off
            
            device.unlockForConfiguration()
        }
    }
    
    private func errorResult(errorCode: String){
        delegate?.didFailWithErrorCode(self, errorCode: errorCode)
        dismiss(animated: false)
    }
    
    private func scanResult(_ scanResult: ScanResult){
        self.delegate?.didScanBarcodeWithResult(self, scanResult: scanResult)
        dismiss(animated: false)
    }
    
    private func mapRestrictedBarcodeTypes() -> [String] {
        var types: [AVMetadataObject.ObjectType] = []
        
        config.restrictFormat.forEach({ format in
            if let mappedFormat = formatMap[format]{
                types.append(mappedFormat)
            }
        })
        
        return types.map({ t in t.rawValue})
    }
    
    private var cameraFromConfig: MTBCamera {
        return .back
    }
}
