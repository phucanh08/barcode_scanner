import Vision

class VisionFrameworkBarcodeScanner: BarcodeScanning {
    private var formats: [VNBarcodeSymbology] = []
    
    func setFormats(_ formats: [BarcodeFormat]) {
        self.formats = BarcodeFormatMapper.toVNBarcodeSymbologies(from: formats)
    }
    
    func process(sampleBuffer: CMSampleBuffer) -> [BarcodeResult] {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let request = VNDetectBarcodesRequest()
            do {
                request.symbologies = formats
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                try handler.perform([request])
                
                return BarcodeMapper.toBarcodes(from: request.results ?? [])
            } catch {
                print("❌ Lỗi xử lý ảnh: \(error)")
            }
        }
        return []
    }
    
    func process(image: UIImage) -> [BarcodeResult] {
        if let ciImage = CIImage(image: image) {
            let request = VNDetectBarcodesRequest()
            do {
                request.symbologies = formats
                let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
                try handler.perform([request])
                
                return BarcodeMapper.toBarcodes(from: request.results ?? [])
            } catch {
                print("❌ Lỗi xử lý ảnh: \(error)")
            }
        } else {
            print("❌ Không thể tạo CIImage từ UIImage.")
        }
        return []
    }
}
