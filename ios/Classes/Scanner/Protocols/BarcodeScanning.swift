import UIKit
import CoreMedia

protocol BarcodeScanning {
    func setFormats(_ formats: [BarcodeFormat])
    func process(sampleBuffer: CMSampleBuffer) -> [BarcodeResult]
    func process(image: UIImage) -> [BarcodeResult]
}
