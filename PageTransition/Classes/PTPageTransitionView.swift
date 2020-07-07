import UIKit

public class PTPageTransitionView: UIView {
    
    public override class var layerClass: AnyClass {
        return PTPageTransitionLayer.self
    }
    
    public var pageTransitionLayer: PTPageTransitionLayer {
        return layer as! PTPageTransitionLayer
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer === pageTransitionLayer {
            pageTransitionLayer.updateFramesForBoundsChange()
        }
    }
}
