import Vision

struct BarcodeMapper {
    static func toBarcodes(from observations: [VNBarcodeObservation]) -> [BarcodeResult] {
        return observations.map(toBarcode(from:))
    }
    
    static func toBarcode(from observation: VNBarcodeObservation) -> BarcodeResult {
        let format = BarcodeFormatMapper.toBarcodeFormat(from: observation.symbology)
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
