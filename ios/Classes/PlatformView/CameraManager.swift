import AVFoundation
import UIKit

class CameraManager: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var previewView: UIView?
    
    private var currentSession: AVCaptureSession?
    private var currentCamera: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    
    private var resolution: AVCaptureSession.Preset = .hd1280x720
    private var cameraPosition: AVCaptureDevice.Position = .back
    
    weak var delegate: VideoSampleBufferDelegate?
    
    var isPauseCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewView = UIView(frame: view.bounds)
        view.addSubview(previewView!)
    }
    
    func setCameraSettings(_ settings: CameraSettings) {
        setResolutionPreset(settings.resolutionPreset)
        setCameraPosition(settings.cameraPosition)
    }
    
    func setResolutionPreset(_ resolutionPreset: ResolutionPreset) {
        switch resolutionPreset {
        case .hd1280X720:
            self.resolution = .hd1280x720
            break
        case .hd1920X1080:
            self.resolution = .hd1920x1080
            break
        default:
            self.resolution = .hd1280x720
            break
        }
    }
    
    func setCameraPosition(_ cameraPosition: CameraPosition) {
        switch cameraPosition {
        case .back:
            self.cameraPosition = .back
            break
        case .front:
            self.cameraPosition = .front
            break
        default:
            break
        }
    }
    
    func startCamera() {
        // Create and configure session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.currentSession = AVCaptureSession()
            self.setupCamera()
            
            // Set up UI components on the main thread
            DispatchQueue.main.async {
                // Configure UI components only
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.currentSession!)
                self.previewLayer?.videoGravity = .resizeAspectFill
                self.previewView?.layer.addSublayer(self.previewLayer!)
                self.previewLayer?.frame = self.previewView?.bounds ?? CGRect.zero
                
                // Configure video output on main thread (this doesn't start the session)
                self.videoOutput = AVCaptureVideoDataOutput()
                self.videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                
                // Go back to background thread to add output and start running
                DispatchQueue.global(qos: .userInitiated).async {
                    if let output = self.videoOutput {
                        self.currentSession?.addOutput(output)
                        self.currentSession?.startRunning()
                    }
                }
            }
        }
    }
    
    func stopCamera() {
        // Session operations on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.currentSession?.stopRunning()
            self.currentSession = nil
            self.currentCamera = nil
        }
    }
    
    func toggleFlash() -> Bool {
        guard let device = currentCamera, device.hasTorch else { return false }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            device.unlockForConfiguration()
            return device.torchMode == .on
        } catch {
            return false
        }
    }
    
    func isFlashOn() -> Bool {
        return currentCamera?.torchMode == .on
    }
    
    func pauseCameraPreview() {
        // UI state update on main thread
        DispatchQueue.main.async {
            self.isPauseCamera = true
        }

        // Session operations on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            guard let currentSession = self.currentSession else { return }
            if currentSession.isRunning {
                currentSession.stopRunning()
            }
        }
    }

    func resumeCameraPreview() {
        // UI state update on main thread
        DispatchQueue.main.async {
            self.isPauseCamera = false
        }

        // Session operations on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            guard let currentSession = self.currentSession else { return }
            if !currentSession.isRunning {
                currentSession.startRunning()
            }
        }
    }
    
    func getSize() -> CGSize {
        switch(resolution) {
        case .hd1280x720:
            return CGSize(width: 720, height: 1280)
        case .hd1920x1080:
            return CGSize(width: 1080, height: 1920)
        default:
            return CGSize(width: 720, height: 1280)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isPauseCamera else { return }
        delegate?.didReceiveSampleBuffer(sampleBuffer)
    }
    
    func getCameraOrientation() -> AVCaptureVideoOrientation {
        guard let connection = self.previewLayer?.connection else {
            return .portrait
        }
        return connection.videoOrientation
    }
}

protocol VideoSampleBufferDelegate: AnyObject {
    func didReceiveSampleBuffer(_ sampleBuffer: CMSampleBuffer)
}

extension CameraManager {
    private func setupCamera() {
        guard let captureSession = currentSession else {return}
        captureSession.beginConfiguration()
        
        // Stop session on the current thread (assumed to be background thread already)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        if captureSession.canSetSessionPreset(resolution) {
            captureSession.sessionPreset = resolution
        }
        
        if let newCamera = getCamera(for: cameraPosition) {
            self.currentCamera = newCamera
            addCameraInput(camera: newCamera)
            enableAutoFocus(for: newCamera)
        }
        
        captureSession.commitConfiguration()
        
        // Start session on the current thread (assumed to be background thread already)
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        if #available(iOS 15.0, *) {
            // Danh sách các loại camera ưu tiên cần quét
            let deviceTypes: [AVCaptureDevice.DeviceType] = [
                .builtInWideAngleCamera,
                .builtInUltraWideCamera,
                .builtInTelephotoCamera
            ]
            
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: deviceTypes,
                mediaType: .video,
                position: position
            )
            
            return discoverySession.devices
                .filter {
                    let isSupportAutoFocus = $0.isFocusModeSupported(.continuousAutoFocus) && $0.isFocusModeSupported(.autoFocus)
                    return $0.minimumFocusDistance > 0 && isSupportAutoFocus
                }
            
                .sorted { $0.minimumFocusDistance < $1.minimumFocusDistance }
                .first
        } else {
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
        }
        
    }
    
    private func addCameraInput(camera: AVCaptureDevice) {
        do {
            guard let currentSession = currentSession else { return }
            
            let newInput = try AVCaptureDeviceInput(device: camera)
            
            currentSession.addInput(newInput)
            
            if let oldInput = videoInput {
                currentSession.removeInput(oldInput)
            }
            
            if currentSession.canAddInput(newInput) {
                currentSession.addInput(newInput)
                videoInput = newInput
            }
        } catch {
            print("Error creating AVCaptureDeviceInput: \(error)")
        }
    }
    
    private func enableAutoFocus(for camera: AVCaptureDevice) {
        do {
            // Lock configuration để thay đổi các cài đặt của camera
            try camera.lockForConfiguration()
            // Dùng defer để đảm bảo luôn unlock cấu hình khi ra khỏi phạm vi do-try-catch.
            defer { camera.unlockForConfiguration() }
            
            // Thiết lập chế độ lấy nét:
            if camera.isFocusModeSupported(.continuousAutoFocus) {
                camera.focusMode = .continuousAutoFocus
            } else if camera.isFocusModeSupported(.autoFocus) {
                camera.focusMode = .autoFocus
            }
            
            // Nếu thiết bị hỗ trợ lấy nét mượt (smooth autofocus), bật tính năng này
            if camera.isSmoothAutoFocusSupported {
                camera.isSmoothAutoFocusEnabled = true
            }
            
            // Kiểm tra và thiết lập giới hạn khoảng cách tự động lấy nét
            if #available(iOS 17.0, *) {
                if camera.isAutoFocusRangeRestrictionSupported {
                    camera.autoFocusRangeRestriction = .near
                }
            } else {
                // Trên iOS cũ hơn, thay đổi giá trị autoFocusRangeRestriction cũng như vậy
                camera.autoFocusRangeRestriction = .near
            }
            
        } catch {
            print("Error enabling autofocus: \(error)")
        }
    }
}
