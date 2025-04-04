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
        case .font:
            self.cameraPosition = .front
            break
        default:
            break
        }
    }
    
    func startCamera() {
        currentSession = AVCaptureSession()
        setupCamera()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: currentSession!)
        previewLayer?.videoGravity = .resizeAspectFill
        previewView?.layer.addSublayer(previewLayer!)
        previewLayer?.frame = previewView?.bounds ?? CGRect.zero
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        currentSession?.addOutput(videoOutput!)
        
        currentSession?.startRunning()
    }
    
    
    func stopCamera() {
        currentSession?.stopRunning()
        currentSession = nil
        currentCamera = nil
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
        DispatchQueue.global(qos: .background).async {
            guard let currentSession = self.currentSession else { return }
            if currentSession.isRunning {
                currentSession.stopRunning()
            }
            self.isPauseCamera = true
        }
    }
    
    func resumeCameraPreview() {
        DispatchQueue.global(qos: .background).async {
            guard let currentSession = self.currentSession else { return }
            if !currentSession.isRunning {
                currentSession.startRunning()
            }
            self.isPauseCamera = false
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
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    private func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
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
            try camera.lockForConfiguration()
            
            if camera.isFocusModeSupported(.continuousAutoFocus) {
                camera.focusMode = .continuousAutoFocus
            }
            
            camera.unlockForConfiguration()
        } catch {
            print("Error enabling autofocus: \(error)")
        }
    }
}
