import UIKit
import QuartzCore

/// Animates a "page flip" animation. Imagine the phone screen is the right half of a book. A new page of contents falls from the left, starting at vertical, rotating about the left edge of the phone until it covers the previous page. The flip-direction and play-direction (forwards/backwards) can be changed by updating `flipDirection` and `isReversed` respectively. If `addClosingDustIfForward` is true two small clouds of dust are emitted from the right corners of the new page after it hits the previous page in a forward animation.
/// To create layer contents, call `setupSublayers()`. After, you can set page contents with `setPreviousPageImage()` and `setNewPageImage()`. To start the animations call `addAnimations()`.  If the layer's bounds change after setup, make sure to call `updateFramesForBoundsChange()` to recalculate the sublayer frames. The `debug` and `showShadow` properties are used by `setupSublayers()` and changing them after setup will have no effect. Similarly, `flipDirection`, `closingDuration`, `isReversed`, and `easingFunction` are used by `addAnimations()` and should not be changed after animations are added.
/// The new page and shadow rotation animations are performed on helper layers called "spreads" which are double the frame width. At the start of the animation, one half of the spread sticks up, out of the screen, while the other half sticks out out behind it, deep to the screen. When the rotation animation is added, it's added to the spread layer, which will animate smoothly about it's centerline because it is double width.
public class PTPageTransitionLayer: CALayer, CAAnimationDelegate {
    
    /// The direction the new page falls into frame from.
    public enum FlipDirection {
        
        case fromLeft
        case fromRight
    }
    
    /// The possible dust cloud sizes.
    public enum DustCloudSize: String {
        
        case small = "DustCloudSmall"
        case medium = "DustCloudMedium"
        case large = "DustCloudLarge"
    }
    
    /// The direction this transition layer falls into frame from.
    public var flipDirection: FlipDirection = .fromLeft {
        didSet {
            updateTransforms()
        }
    }
    
    /// Whether the shadow layer that leads the new page should be added.
    public var showShadow = true
    
    /// If true the new page rotates back out of frame. If false the new page falls into frame. Defaults to false.
    public var isReversed = false
    
    /// Whether to add dust clouds at the end of a forward closing animation.
    public var addClosingDustIfForward = false
    
    /// The size of the ending dust cloud.
    public var dustCloudSize: DustCloudSize = .small
    
    /// All sublayers should be bordered and/or colored.
    public var debug = false
    
    /// The duration that the new page falls into frame. Not necessarily the animation duration.
    public var closingDuration: TimeInterval = 0.5
    
    /// The duration of the animation.
    public var totalDuration: TimeInterval {
        return addClosingDust ? closingDuration + dustBirthRateDuration : closingDuration
    }
    
    /// The distance of the camera from the animation. Affects how extreme the page perspective looks.
    public var distanceFromCamera: CGFloat = 1250
    
    /// A completion called when the animation ends.
    /// - Parameters:
    ///     - finished: Whether the animation was finished when it stopped.
    public var animationCompletion: ((Bool) -> Void)?
    
    /// The page animation easing function.
    public var easingFunction = CAMediaTimingFunction(name: .easeIn)
    
    /// The vanishing point of the perspective. Set into the "spine of the book," i.e. the left edge of the phone.
    public let vanishingPoint: CGPoint = CGPoint(x: 0.0, y: 0.5)
        
    /// The shadow layer starting transform: standing up at a 90 degree angle.
    public let shadowStartTransform = CATransform3DMakeRotation(-CGFloat.pi/2, 0.0, 1.0, 0.0)
    
    /// The shadow layer end transform: laying flat over the previous page.
    public let shadowEndTransform = CATransform3DIdentity
    
    /// The new page starting transform: leaning back, out of frame, at a 99 degree angle.
    public let newPageStartTransform = CATransform3DMakeRotation(-(CGFloat.pi/2+CGFloat.pi*0.05), 0.0, 1.0, 0.0)
    
    /// The new page end tranform: laying flat over the shadow and previous page.
    public let newPageEndTransform = CATransform3DIdentity
    
    /// The shadow radius start value: 20.
    public let shadowRadiusStartValue: CGFloat = 20.0
        
    /// The shadow radius end value: 0.
    public let shadowRadiusEndValue: CGFloat = 0.0
    
    /// The shadow opacity start value: totally transparent.
    public let shadowOpacityStartValue: Float = 0.0
    
    /// The shadow opacity end value: totally opaque.
    public let shadowOpacityEndValue: Float = 1.0
    
    /// The values for the dust birth rate keframe animation. 100% for the first keyframe and 0% for the second.
    public let dustBirthRateValues: [CGFloat] = [0.5, 0.0]
    
    /// The key times for the dust birth rate keyframe animation. 1/4th of a second for the first keyframe and 1 second for the second.
    public let dustBirthRateKeyTimes: [CFTimeInterval] = [0.25, 1.0]
    
    /// The total birth rate animation duration.
    public var dustBirthRateDuration: CFTimeInterval { dustBirthRateKeyTimes.reduce(0, +) }
    
    /// Whether closing dust should be added.
    private var addClosingDust: Bool {
        return addClosingDustIfForward && !isReversed
    }
    
    /// The layer that the finish animation is applied to.
    private var finishAnimationLayer: CALayer!
    
    /// The key that identifies the finish animation in `finishAnimationLayer`.
    private let finishAnimationKey = "PTPageTransitionLayer.finishAnimation"
    
    /// The 4 mask layers that bound the frame in a larger frame.
    private var maskLayers: [CALayer] = []
    
    /// The layer for the previous page that sits flat and is covered by the new page layer.
    private var prevPage: CALayer!
    
    /// The emitter layer that emits the top right dust cloud.
    private var topRightDust: CAEmitterLayer!
    
    /// The emitter layer that emits the bottom right dust cloud.
    private var bottomRightDust: CAEmitterLayer!
    
    /// The layer that has the shadow of the new page.
    private var shadow: CALayer!
    
    /// The spread that holds the shadow layer and assists with the rotation animation. Only visible if `debug` is true.
    private var shadowSpread: CALayer!
    
    /// The layer that has the new page content. Initialized in `setupSublayers()`.
    private var newPage: CALayer!
    
    /// The spread that holds the new page layer and assists with the rotation animation. Only visible if `debug` is true.
    private var newPageSpread: CALayer!
    
    // MARK: Update
    
    /// Re-sets the transforms applied to this layer and sublayers. A transition from right flips this layer and the prev and next layers about the y-axis. Note that the bounds is changed to account for the changed anchor/vanishing point.
    private func updateTransforms() {
        
        // Create and add the perspective.
        var sublayerTransform = CATransform3DIdentity
        sublayerTransform.m34 = -1.0/distanceFromCamera

        switch flipDirection {
        case .fromLeft:
            
            // Update bounds for the changed anchor/vanishing point.
            bounds.origin.x = bounds.size.width/2
            
            self.sublayerTransform = sublayerTransform
            self.prevPage?.transform = CATransform3DIdentity
            self.newPage?.transform = CATransform3DIdentity
        case .fromRight:

            // Update bounds for the changed anchor/vanishing point.
            bounds.origin.x = -bounds.size.width/2
            
            // Add the translation.
            sublayerTransform = CATransform3DTranslate(sublayerTransform, bounds.size.width, 0.0, 0.0)
            // Add the flip.
            sublayerTransform = CATransform3DScale(sublayerTransform, -1.0, 1.0, 1.0)

            self.sublayerTransform = sublayerTransform
            self.prevPage?.transform = CATransform3DMakeScale(-1.0, 1.0, 1.0)
            self.newPage?.transform = CATransform3DMakeScale(-1.0, 1.0, 1.0)
        }
    }
    
    /// Re-sets the sublayer frames. Should be called after every bounds change.
    public func updateFramesForBoundsChange() {

        // When the bounds change, the translation part of the sublayer transform needs to be redone.
        updateTransforms()

        for (i, maskFrame) in maskFrames().enumerated() {
            maskLayers[i].frame = maskFrame
        }
        prevPage.frame                  = prevPageFrame()
        topRightDust.frame              = topRightDustFrame()
        topRightDust.emitterPosition    = topRightDustEmitterPosition()
        bottomRightDust.frame           = bottomRightDustFrame()
        bottomRightDust.emitterPosition = bottomRightDustEmitterPosition()
        shadow.frame                    = shadowFrame()
        shadow.shadowOffset             = shadowOffset()
        shadowSpread.frame              = shadowSpreadFrame()
        newPage.frame                   = newPageFrame()
        newPageSpread.frame             = newPageSpreadFrame()
    }
        
    // MARK: Setup
    
    /// Creates and configures the sublayers based on current `bounds` and whether `debug` is true, Should only be called once, before `addAnimations()`.
    public func setupSublayers() {
        
        // Set the perspective.
        updateTransforms()

        // Set the background color and borders for debug mode.
        let border: CGFloat             = debug ? 1.0 : 0.0
        let maskLayersBackgroundColor   = debug ? UIColor.clear.cgColor  : UIColor.white.cgColor
        let prevPageBackgroundColor     = debug ? UIColor.blue.cgColor   : UIColor.clear.cgColor
        let newPageBackgroundColor      = debug ? UIColor.orange.cgColor : UIColor.clear.cgColor

        // Set the vanishingPoint.
        anchorPoint = vanishingPoint

        // Set the border around self.
        borderWidth = border

        // Setup the mask rects around the container.
        for maskFrame in maskFrames() {
            let maskLayer = CALayer()
            maskLayer.backgroundColor = maskLayersBackgroundColor
            maskLayer.borderWidth = border
            maskLayer.zPosition = 1.0
            maskLayer.frame = maskFrame
            maskLayers.append(maskLayer)
            addSublayer(maskLayer)
        }

        // Setup the previous page that the new page will land on top of.
        prevPage = CALayer()
        prevPage.backgroundColor = prevPageBackgroundColor
        prevPage.borderWidth = border
        prevPage.frame = prevPageFrame()
        addSublayer(prevPage)
        
        // Get the dust cloud image.
        let dustCloudImage: UIImage? = {
            guard let bundlePath = Bundle(for: self.classForCoder).path(forResource: nil, ofType: "bundle", inDirectory: nil) else { return nil }
            return UIImage(named: dustCloudSize.rawValue, in: Bundle(path: bundlePath), compatibleWith: nil)
        }()
        
        // Make dust clouds.
        func makeDustCloudCell() -> CAEmitterCell {
            let dustCell = CAEmitterCell()
            dustCell.contents = dustCloudImage?.cgImage
            dustCell.birthRate = 1.0
            dustCell.lifetime = 3.0
            dustCell.alphaSpeed = -0.75
            dustCell.velocity = 25.0
            dustCell.velocityRange = 15.0
            dustCell.spinRange = CGFloat.pi/4
            dustCell.scaleRange = 0.1
            dustCell.scale = 1.5
            return dustCell
        }

        // Add the emitter layers.
        let topRightDustCell = makeDustCloudCell()
        topRightDustCell.emissionLongitude = 3*CGFloat.pi/4
        topRightDustCell.emissionRange = CGFloat.pi/4

        topRightDust = CAEmitterLayer()
        topRightDust.zPosition = 2.0
        topRightDust.birthRate = 0.0
        topRightDust.borderWidth = border
        topRightDust.emitterCells = [topRightDustCell]
        topRightDust.frame = topRightDustFrame()
        topRightDust.emitterPosition = topRightDustEmitterPosition()

        let bottomRightDustCell = makeDustCloudCell()
        bottomRightDustCell.emissionLongitude = 5*CGFloat.pi/4
        bottomRightDustCell.emissionRange = CGFloat.pi/4

        bottomRightDust = CAEmitterLayer()
        bottomRightDust.zPosition = 2.0
        bottomRightDust.birthRate = 0.0
        bottomRightDust.borderWidth = border
        bottomRightDust.emitterCells = [bottomRightDustCell]
        bottomRightDust.frame = bottomRightDustFrame()
        bottomRightDust.emitterPosition = bottomRightDustEmitterPosition()

        addSublayer(topRightDust)
        addSublayer(bottomRightDust)

        // Setup the shadow layer on top of the previous page.
        shadow = CALayer()
        shadow.backgroundColor = UIColor.black.cgColor
        shadow.shadowRadius = 0.0
        shadow.shadowOpacity = shadowOpacityStartValue
        shadow.frame = shadowFrame()
        shadow.shadowOffset = shadowOffset()

        shadowSpread = CALayer()
        shadowSpread.borderWidth = border
        shadowSpread.backgroundColor = UIColor.clear.cgColor
        shadowSpread.frame = shadowSpreadFrame()

        if showShadow {
            shadowSpread.addSublayer(shadow)
            addSublayer(shadowSpread)
        }

        // Setup the new page so that it can fall ontop of the prev page via spread.
        newPage = CALayer()
        newPage.backgroundColor = newPageBackgroundColor
        newPage.borderWidth = border
        newPage.frame = newPageFrame()

        newPageSpread = CALayer()
        newPageSpread.borderWidth = border
        newPageSpread.backgroundColor = UIColor.clear.cgColor
        newPageSpread.frame = newPageSpreadFrame()

        newPageSpread.addSublayer(newPage)
        addSublayer(newPageSpread)
    }
    
    // MARK: Setters
    
    /// Sets the image for the previous page which will be covered by the new page.
    /// - Parameters:
    ///     - image: The image set as `contents` of the `prevPage` layer. Will be false if called before `setupSublayers()`.
    /// - Returns: Whether the image has been set successfully.
    @discardableResult
    public func setPreviousPageImage(_ image: CGImage?) -> Bool {
        guard prevPage != nil else { return false }
        prevPage.contents = image
        return true
    }
    
    /// Sets the image for the new page which covers the previous page.
    /// - Parameters:
    ///     - image: The image set as `contents` of the `newPage` layer.
    /// - Returns: Whether the image has been set successfully. Will be false if called before `setupSublayers()`.
    @discardableResult
    public func setNewPageImage(_ image: CGImage?) -> Bool {
        guard newPage != nil else { return false }
        newPage.contents = image
        return true
    }
    
    // MARK: Animation
    
    /// Creates and adds the appropriate animations. `finishAnimationLayer` is set here.
    public func addAnimations() {
                
        // Setup and run the animations.
        let shadowSpreadRotation: CABasicAnimation = {
            let shadowSpreadRotation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
            shadowSpreadRotation.fromValue      = isReversed ? shadowEndTransform   : shadowStartTransform
            shadowSpreadRotation.toValue        = isReversed ? shadowStartTransform : shadowEndTransform
            shadowSpreadRotation.duration       = closingDuration
            shadowSpreadRotation.timingFunction = easingFunction
            return shadowSpreadRotation
        }()

        let shadowRadius: CABasicAnimation = {
            let shadowRadius = CABasicAnimation(keyPath: #keyPath(CALayer.shadowRadius))
            shadowRadius.fromValue  = isReversed ? shadowRadiusEndValue   : shadowRadiusStartValue
            shadowRadius.toValue    = isReversed ? shadowRadiusStartValue : shadowRadiusEndValue
            return shadowRadius
        }()

        let shadowOpacity: CABasicAnimation = {
            let shadowOpacity = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOpacity))
            shadowOpacity.fromValue = isReversed ? shadowOpacityEndValue   : shadowOpacityStartValue
            shadowOpacity.toValue   = isReversed ? shadowOpacityStartValue : shadowOpacityEndValue
            return shadowOpacity
        }()

        let shadowAnimations = CAAnimationGroup()
        shadowAnimations.animations     = [shadowRadius, shadowOpacity]
        shadowAnimations.duration       = closingDuration
        shadowAnimations.timingFunction = easingFunction

        let newPageSpreadRotation: CABasicAnimation = {
            let newPageSpreadRotation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
            newPageSpreadRotation.fromValue        = isReversed ? newPageEndTransform   : newPageStartTransform
            newPageSpreadRotation.toValue          = isReversed ? newPageStartTransform : newPageEndTransform
            newPageSpreadRotation.duration         = closingDuration
            newPageSpreadRotation.timingFunction   = easingFunction
            return newPageSpreadRotation
        }()

        let dustBirthRate: CAKeyframeAnimation = {
            let dustBirthRate = CAKeyframeAnimation(keyPath: #keyPath(CAEmitterLayer.birthRate))
            dustBirthRate.values = dustBirthRateValues
            dustBirthRate.keyTimes = dustBirthRateKeyTimes as [NSNumber]
            dustBirthRate.duration = dustBirthRateDuration
            dustBirthRate.beginTime = CACurrentMediaTime() + closingDuration
            return dustBirthRate
        }()

        let topRightDustBirthRate = dustBirthRate
        let bottomRightDustBirthRate = dustBirthRate.copy() as! CAKeyframeAnimation

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shadowSpread.transform  = isReversed ? shadowStartTransform    : shadowEndTransform
        shadow.shadowRadius     = isReversed ? shadowRadiusStartValue  : shadowRadiusEndValue
        shadow.shadowOpacity    = isReversed ? shadowOpacityStartValue : shadowOpacityEndValue
        newPageSpread.transform = isReversed ? newPageStartTransform   : newPageEndTransform
        CATransaction.commit()

        if addClosingDust {
            bottomRightDustBirthRate.delegate = self
            bottomRightDustBirthRate.isRemovedOnCompletion = false
            finishAnimationLayer = bottomRightDust

            shadowSpread        .add(shadowSpreadRotation,     forKey: nil)
            shadow              .add(shadowAnimations,         forKey: nil)
            newPageSpread       .add(newPageSpreadRotation,    forKey: nil)
            topRightDust        .add(topRightDustBirthRate,    forKey: nil)
            bottomRightDust     .add(bottomRightDustBirthRate, forKey: finishAnimationKey)
        } else {
            newPageSpreadRotation.delegate = self
            newPageSpreadRotation.isRemovedOnCompletion = false
            finishAnimationLayer = newPageSpread

            shadowSpread        .add(shadowSpreadRotation,  forKey: nil)
            shadow              .add(shadowAnimations,      forKey: nil)
            newPageSpread       .add(newPageSpreadRotation, forKey: finishAnimationKey)
        }
    }
    
    // MARK: Layout
        
    /// Creates the frames that bounds `frame`. Created to hide the deep halves of `newPageSpread` and `shadowSpread`.
    func maskFrames() -> [CGRect] {
        return [
            // Top
            CGRect(
                x: -bounds.size.width,
                y: -bounds.size.height,
                width: bounds.size.width*3.0,
                height: bounds.size.height),
            // Bottom
            CGRect(
                x: -bounds.size.width,
                y: bounds.size.height,
                width: bounds.size.width*3.0,
                height: bounds.size.height),
            // Left
            CGRect(
                x: -bounds.size.width,
                y: 0.0,
                width: bounds.size.width,
                height: bounds.size.height),
            // Right
            CGRect(
                x: bounds.size.width,
                y: 0.0,
                width: bounds.size.width,
                height: bounds.size.height),
        ]
    }
    
    /// The frame for `prevPage`.
    func prevPageFrame() -> CGRect {
        return CGRect(origin: .zero, size: bounds.size)
    }
    
    /// The frame for the emitter layer`topRightDust`.
    func topRightDustFrame() -> CGRect {
        CGRect(
            x: 0.0,
            y: 0.0,
            width: bounds.size.width,
            height: bounds.size.height/2.0)
    }
    
    /// The emitter position for `topRightDust`.
    func topRightDustEmitterPosition() -> CGPoint {
        return CGPoint(x: topRightDust.frame.size.width, y: 0.0)
    }
    
    /// The frame for the emitter layer`bottomRightDust`.
    func bottomRightDustFrame() -> CGRect {
        CGRect(
            x: 0.0,
            y: bounds.size.height/2.0,
            width: bounds.size.width,
            height: bounds.size.height/2.0)
    }
    
    /// The emitter position for `bottomRightDust`.
    func bottomRightDustEmitterPosition() -> CGPoint {
        CGPoint(
            x: bottomRightDust.frame.size.width,
            y: bottomRightDust.frame.size.height)
    }
    
    /// The offset for the shadow on `shadowLayer`.
    func shadowOffset() -> CGSize {
        return CGSize(width: shadow.frame.size.width, height: 0.0)
    }
    
    /// The frame for `shadowLayer` in `shadowSpread`.
    func shadowFrame() -> CGRect {
        return CGRect(x: 0.0, y: 0.0, width: bounds.size.width*1.5, height: bounds.size.height)
    }
    
    /// The frame for `shadowSpread`.
    func shadowSpreadFrame() -> CGRect {
        CGRect(
            x: -bounds.size.width*2.0,
            y: 0.0,
            // Set the shadow spread so that each side (left and right) is wider than the shadow width.
            width: bounds.size.width*4.0,
            height: bounds.size.height)
    }
    
    /// The frame for `newPage` in `newPageSpread`.
    func newPageFrame() -> CGRect {
        return CGRect(x: bounds.size.width, y: 0.0, width: bounds.size.width, height: bounds.size.height)
    }
    
    /// The frame for `newPageSpread`.
    func newPageSpreadFrame() -> CGRect {
        CGRect(
            x: -bounds.size.width,
            y: 0.0,
            width: bounds.size.width*2.0,
            height: bounds.size.height)
    }
    
    // MARK: CAAnimationDelegate
    
    /// Calls `animationCompletion`. This class acts as the animation delegate only for the animation saved with `finishAnimationKey` on `finishAnimationLayer`.
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let finishAnimation = finishAnimationLayer.animation(forKey: finishAnimationKey), finishAnimation === anim {
            animationCompletion?(flag)
            finishAnimationLayer.removeAnimation(forKey: finishAnimationKey)
        }
    }
}
