import Vision


struct BarcodeFormatMapper {
    static func toVNBarcodeSymbologies(from formats: [BarcodeFormat]) -> [VNBarcodeSymbology] {
        return formats.compactMap(toVNBarcodeSymbology(from:))
    }
    
    static func toVNBarcodeSymbology(from format: BarcodeFormat) -> VNBarcodeSymbology? {
        switch format {
        case .aztec: return .Aztec
        case .code128: return .Code128
        case .code39: return .Code39
        case .code93: return .Code93
        case .dataMatrix: return .DataMatrix
        case .ean13: return .EAN13
        case .ean8: return .EAN8
        case .pdf417: return .PDF417
        case .qr: return .QR
        case .upce: return .UPCE
        case .all: return nil // giá trị .all được xử lý riêng
        default: return nil
        }
    }
    
    static func toBarcodeFormat(from symbology: VNBarcodeSymbology) -> BarcodeFormat {
        switch symbology {
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
                switch symbology {
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
