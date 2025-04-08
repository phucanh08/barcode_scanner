import Vision
import AVFoundation
import UIKit



class BarcodeScanner {
    private var formats: [BarcodeFormat] = []
    private let visionFrameworkBarcodeScanner = VisionFrameworkBarcodeScanner()
    
    func setFormats(_ formats: [BarcodeFormat]) {
        self.formats = formats
        visionFrameworkBarcodeScanner.setFormats(formats)
    }
    
    func process(sampleBuffer: CMSampleBuffer) -> [BarcodeResult] {
        return visionFrameworkBarcodeScanner.process(sampleBuffer: sampleBuffer)
    }
    
    func process(image: UIImage) -> [BarcodeResult] {
        return visionFrameworkBarcodeScanner.process(image: image)
    }
}
