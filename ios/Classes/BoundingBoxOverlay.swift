class BoundingBoxOverlay: UIView {
    private var rect: CGRect?
    
    public func clear() {
        self.rect = nil
        setNeedsDisplay()
    }
    
    public func setBoundingBox(_ rect: CGRect, imageSize: CGSize) {
        let imageViewSize = self.bounds.size
        
        let scaleX = imageViewSize.width / imageSize.width
        let scaleY = imageViewSize.height / imageSize.height
        let scale = min(scaleX, scaleY)
        
        let wLost = (scale == scaleY) ? (imageSize.width * scale - imageViewSize.width) / 2 : 0
        let hLost = (scale == scaleY) ? 0 : (imageSize.height * scale - imageViewSize.height) / 2
        
        let x = rect.origin.x * imageSize.width * scale - wLost
        let y = rect.origin.y * imageSize.height * scale - hLost
        let width = rect.width * imageSize.width * scale
        let height = rect.height * imageSize.height * scale
        
        self.rect = CGRect(x: x, y: y, width: width, height: height)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let boundingRect = self.rect else { return }
        
        let path = UIBezierPath(rect: boundingRect)
        path.lineWidth = 3.0
        UIColor.green.setStroke()
        path.stroke()
    }
}
