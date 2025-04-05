class BoundingBoxOverlay: UIView {
    private var rect: CGRect?
    
    public func clear() {
        self.rect = nil
        setNeedsDisplay()
    }
    
    public func setBoundingBox(_ rect: CGRect, imageSize: CGSize, isFitContain: Bool) {
        let imageViewSize = self.bounds.size
        
        let scaleX = imageViewSize.width / imageSize.width
        let scaleY = imageViewSize.height / imageSize.height
        
        var scale: CGFloat = 1
        var wLost: CGFloat = 0
        var hLost: CGFloat = 0
        
        if (isFitContain) {
            scale = max(scaleX, scaleY)
            wLost = (imageSize.width * scale - imageViewSize.width) / 2
            hLost = (imageSize.height * scale - imageViewSize.height) / 2
        } else {
            scale = min(scaleX, scaleY)
            if (scale == scaleY) {
                wLost = (imageSize.width * scale - imageViewSize.width) / 2
            } else {
                hLost = (imageSize.height * scale - imageViewSize.height) / 2
            }
        }
        
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
