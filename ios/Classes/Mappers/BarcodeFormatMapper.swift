import Vision

struct BarcodeFormatMapper {
    static func toVNBarcodeSymbologies(from formats: [BarcodeFormat]) -> [VNBarcodeSymbology] {
        var result: [VNBarcodeSymbology] = []
        
        // Kiểm tra xem có BarcodeFormat.all không
        if formats.contains(.all) {
            // Thêm tất cả các VNBarcodeSymbology nếu .all được chọn
            result.append(contentsOf: [
                .code39, .code39Checksum, .code39FullASCII, .code39FullASCIIChecksum,
                .code93, .code93i, .code128, .i2of5, .i2of5Checksum, .itf14,
                .upce, .ean8, .ean13, .qr, .pdf417, .dataMatrix, .aztec
            ])
            if #available(iOS 15.0, *) {
                result.append(contentsOf: [
                    VNBarcodeSymbology.codabar, VNBarcodeSymbology.gs1DataBar, VNBarcodeSymbology.gs1DataBarExpanded
                ])
            }
        } else {
            // Duyệt qua từng format và thêm VNBarcodeSymbology tương ứng
            for format in formats {
                switch format {
                case .code39:
                    result.append(contentsOf: [
                        .code39, .code39Checksum, .code39FullASCII, .code39FullASCIIChecksum
                    ])
                case .code93:
                    result.append(contentsOf: [.code93, .code93i])
                case .code128:
                    result.append(.code128)
                case .itf:
                    result.append(contentsOf: [.i2of5, .i2of5Checksum, .itf14])
                case .upce:
                    result.append(.upce)
                case .ean8:
                    result.append(.ean8)
                case .ean13:
                    result.append(.ean13)
                case .qr:
                    result.append(.qr)
                case .pdf417:
                    result.append(.pdf417)
                case .dataMatrix:
                    result.append(.dataMatrix)
                case .aztec:
                    result.append(.aztec)
                default:
                    if #available(iOS 15.0, *) {
                        switch format {
                        case BarcodeFormat.codaBar:
                            result.append(VNBarcodeSymbology.codabar)
                            break
                        case BarcodeFormat.gs1DataBar:
                            result.append(VNBarcodeSymbology.gs1DataBar)
                            break
                        case BarcodeFormat.gs1DataBarExtended:
                            result.append(VNBarcodeSymbology.gs1DataBarExpanded)
                            break
                        default:
                            break
                        }
                    }
                    break
                }
            }
        }
        
        return result
    }
    
    static func toBarcodeFormat(from symbology: VNBarcodeSymbology) -> BarcodeFormat {
        switch symbology {
        case .code39, .code39Checksum, .code39FullASCII, .code39FullASCIIChecksum:
            return BarcodeFormat.code39
        case .code93, .code93i:
            return BarcodeFormat.code93
        case .code128:
            return BarcodeFormat.code128
        case .i2of5, .i2of5Checksum, .itf14:
            return BarcodeFormat.itf
        case .upce:
            return BarcodeFormat.upce
        case .ean8:
            return BarcodeFormat.ean8
        case .ean13:
            return BarcodeFormat.ean13
        case .qr:
            return BarcodeFormat.qr
        case .pdf417:
            return BarcodeFormat.pdf417
        case .dataMatrix:
            return BarcodeFormat.dataMatrix
        case .aztec:
            return BarcodeFormat.aztec
        default:
            if #available(iOS 15.0, *) {
                switch symbology {
                case VNBarcodeSymbology.codabar:
                    return .codaBar
                case VNBarcodeSymbology.gs1DataBar:
                    return .gs1DataBar
                case VNBarcodeSymbology.gs1DataBarExpanded:
                    return .gs1DataBarExtended
                default:
                    break
                }
            }
            return .unknown
        }
    }
}
