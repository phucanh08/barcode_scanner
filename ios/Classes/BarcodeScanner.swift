import Vision
import AVFoundation
import UIKit

class BarcodeScanner {
    private var currentRequests: [VNRequest] = []
    private var barcodeFormats: [VNBarcodeSymbology] = []
    
    func setFormats(_ formats: [BarcodeFormat]) {
        self.barcodeFormats = convertFormats(formats)
    }
    
    func process(_ sampleBuffer: CMSampleBuffer) -> [BarcodeResult] {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return []}
        
        let request = VNDetectBarcodesRequest()
        
        
        do {
            request.symbologies = barcodeFormats
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            
            try handler.perform([request])
            
            let result = request.results?.compactMap { observation in observation.toBarcodeResult() }
            
            return result ?? []
            
        } catch {
            print("❌ Lỗi xử lý ảnh: \(error)")
        }
        return []
    }
    
    func process(_ image: UIImage) -> [BarcodeResult] {
        guard let ciImage = CIImage(image: image) else {
            print("Không thể tạo CIImage từ UIImage.")
            return []
        }
        
        let request = VNDetectBarcodesRequest()
        
        do {
            request.symbologies = barcodeFormats
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            try handler.perform([request])
            
            let result = request.results?.compactMap { observation in observation.toBarcodeResult() }
            return result ?? []
            
        } catch {
            print("❌ Lỗi xử lý ảnh: \(error)")
        }
        return []
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
            case .itf: return .i2of5
            case .pdf417: return .pdf417
            case .qr: return .qr
            case .upce: return .upce
            default: return nil
            }
        }
    }
}

extension VNBarcodeObservation {
    func toBarcodeResult() -> BarcodeResult {
        let observation = self
        let format = observation.symbology.toBarcodeFormat()
        let rect = CGRect(
            x: observation.boundingBox.origin.y,
            y: observation.boundingBox.origin.x,
            width: observation.boundingBox.height,
            height: observation.boundingBox.width
        )
        let boundingBox = Rect.with {
            $0.left = Float(rect.origin.x)
            $0.top = Float(rect.origin.y)
            $0.right = Float(rect.origin.x + rect.width)
            $0.bottom = Float(rect.origin.y + rect.height)
        }
        
        let barcode = BarcodeResult.with {
            $0.format = format
            $0.rawValue = observation.payloadStringValue ?? ""
            if #available(iOS 17.0, *) {
                $0.rawBytes = observation.payloadData ?? Data()
            }
            $0.boundingBox = boundingBox
            $0.cornerPoints = [
                Point.with {
                    $0.x = Float(observation.topLeft.x)
                    $0.y = Float(observation.topLeft.y)
                },
                Point.with {
                    $0.x = Float(observation.topRight.x)
                    $0.y = Float(observation.topRight.y)
                },
                Point.with {
                    $0.x = Float(observation.bottomRight.x)
                    $0.y = Float(observation.bottomRight.y)
                },
                Point.with {
                    $0.x = Float(observation.bottomLeft.x)
                    $0.y = Float(observation.bottomLeft.y)
                }
            ]
            $0.timestamp = Int64(Date().timeIntervalSince1970)
        }
        
        return barcode
    }
}


extension VNBarcodeSymbology {
    func toBarcodeFormat() -> BarcodeFormat {
        switch self {
        case .code39, .code39Checksum, .code39FullASCII, .code39FullASCIIChecksum: return BarcodeFormat.code39
        case .code93, .code93i: return BarcodeFormat.code93
        case .code128: return BarcodeFormat.code128
        case .i2of5, .i2of5Checksum, .itf14: return BarcodeFormat.itf
        case .upce: return BarcodeFormat.upce
        case .ean8: return BarcodeFormat.ean8
        case .ean13: return BarcodeFormat.ean13
        case .qr: return BarcodeFormat.qr
        case .pdf417: return BarcodeFormat.pdf417
        case .dataMatrix: return BarcodeFormat.dataMatrix
        case .aztec: return BarcodeFormat.aztec
        default:
            if #available(iOS 15.0, *) {
                switch self {
                case VNBarcodeSymbology.codabar: return .codaBar
                case VNBarcodeSymbology.gs1DataBar: return .gs1DataBar
                case VNBarcodeSymbology.gs1DataBarExpanded: return .gs1DataBarExtended
                default: break
                }
            }
            return .unknown
        }
        
    }
}
