import Vision
import AVFoundation
import UIKit

class BarcodeScanner {
    private var currentRequests: [VNRequest] = []
    private var barcodeFormats: [VNBarcodeSymbology] = []
    var delegate: BarcodeScannerListener?
    
    func setFormats(_ formats: [BarcodeFormat]) {
        self.barcodeFormats = convertFormats(formats)
    }
    
    func process(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            _ = self?.handleDetectionResults(request: request, error: error)
        }
        request.symbologies = self.barcodeFormats
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
    
    func process(_ image: UIImage) -> [ScanResult] {
        guard let ciImage = CIImage(image: image) else {
            print("Không thể tạo CIImage từ UIImage.")
            return []
        }
        
        let request = VNDetectBarcodesRequest()
        do {
            request.symbologies = barcodeFormats
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            try handler.perform([request])
            return handleDetectionResults(request: request, error: nil, size: image.size)
        } catch {
            print("❌ Lỗi xử lý ảnh: \(error)")
            return handleDetectionResults(request: request, error: error, size: image.size)
        }
    }
    
    private func handleDetectionResults(request: VNRequest, error: Error?, size: CGSize? = nil) -> [ScanResult] {
        guard let results = request.results as? [VNBarcodeObservation] else {
            self.delegate?.didFailWithErrorCode("DETECTION_ERROR", error?.localizedDescription ?? "Lỗi Detect", error)
            return []
        }
        
        var rect: CGRect? = nil
        
        if let barcode = results.first {
            rect = convertToViewCoordinates(normalizedRect: barcode.boundingBox)
        }
        DispatchQueue.main.async {
            self.delegate?.didUpdateBoundingBoxOverlay(rect, size: size)
        }
        
        var scanResults: [ScanResult] = []
        
        
        for barcode in results {
            let format = convertSymbology(barcode.symbology)
            let rawContent = barcode.payloadStringValue ?? ""
            
            let scanResult = ScanResult.with {
                $0.type = .barcode
                $0.rawContent = rawContent
                $0.format = format
                $0.formatNote = barcode.symbology.rawValue
            }
            
            scanResults.append(scanResult)
        }
        
        DispatchQueue.main.async {
            self.delegate?.didScanBarcodeWithResults(scanResults)
        }
        
        return scanResults
    }
    
    
    private func convertSymbology(_ symbology: VNBarcodeSymbology) -> BarcodeFormat {
        switch symbology {
        case .qr: return .qr
        case .code39, .code39Checksum: return .code39
        case .code128: return .code128
        case .code93, .code93i: return .code93
        case .ean8: return .ean8
        case .ean13: return .ean13
        case .upce: return .upce
        case .aztec: return .aztec
        case .pdf417: return .pdf417
        case .dataMatrix: return .dataMatrix
        default: return .unknown
        }
    }
    
    private func convertFormats(_ formats: [BarcodeFormat]) -> [VNBarcodeSymbology] {
        return formats.compactMap {
            switch $0 {
            case .aztec: return .aztec
            case .code39: return .code39
            case .code93: return .code93
            case .code128: return .code128
            case .dataMatrix: return .dataMatrix
            case .ean8: return .ean8
            case .ean13: return .ean13
            case .interleaved2Of5: return .i2of5
            case .pdf417: return .pdf417
            case .qr: return .qr
            case .upce: return .upce
            default: return nil
            }
        }
    }
    
    private func convertToViewCoordinates(normalizedRect: CGRect) -> CGRect {
        return CGRect(
            x: normalizedRect.origin.x,
            y: 1 - normalizedRect.origin.y - normalizedRect.height,
            width: normalizedRect.width,
            height: normalizedRect.height
        )
    }
}

protocol BarcodeScannerListener: AnyObject {
    func didUpdateBoundingBoxOverlay(_ rect: CGRect?, size: CGSize?)
    func didScanBarcodeWithResults(_ results: [ScanResult])
    func didFailWithErrorCode(_ code: String, _ message: String, _ details: Any?)
}
