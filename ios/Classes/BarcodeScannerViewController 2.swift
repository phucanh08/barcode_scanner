import AVFoundation
import UIKit

class BarcodeScannerViewController2: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
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
    
    func setResolution(resolution: Resolution) {
        switch resolution {
        case Resolution.hd:
            self.resolution = .hd1280x720
            break
        case Resolution.fullHd:
            self.resolution = .hd1920x1080
            break
        default:
            break
        }
    }
    
    func setCameraPosition(cameraPosition: CameraSelection) {
        switch cameraPosition {
        case CameraSelection.back:
            self.cameraPosition = .back
            break
        case CameraSelection.font:
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
        isPauseCamera = true
    }
    
    
    func resumeCameraPreview() {
        isPauseCamera = false
    }
    
    func getSize() -> CGSize {
        switch(resolution) {
        case .hd1280x720:
            return CGSize(width: 1280, height: 720)
        case .hd1920x1080:
            return CGSize(width: 1920, height: 1080)
        default:
            return CGSize(width: 1280, height: 720)
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


extension BarcodeScannerViewController2 {
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
