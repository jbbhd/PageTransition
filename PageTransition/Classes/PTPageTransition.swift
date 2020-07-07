import UIKit

private extension UIView {
    
    func toImage() -> UIImage? {
        var result: UIImage?
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            result = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return result
    }
}

public class PTPageTransition: NSObject, UIViewControllerAnimatedTransitioning {

    enum Action {
        case present
        case dismiss
    }
    
    private let view: PTPageTransitionView
                
    private let action: Action
    
    init(action: Action, flipDirection: PTPageTransitionLayer.FlipDirection = .fromLeft) {
        self.action = action
        self.view = PTPageTransitionView()
        self.view.pageTransitionLayer.debug = false
        self.view.pageTransitionLayer.showShadow = true
        self.view.pageTransitionLayer.flipDirection = flipDirection
        self.view.pageTransitionLayer.isReversed = action == .dismiss
        self.view.pageTransitionLayer.setupSublayers()
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return view.pageTransitionLayer.totalDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController   = transitionContext.viewController(forKey: .to) else { return }
        if case .present = action {
            transitionContext.containerView.addSubview(toViewController.view)
        }
        guard let fromScreenshot = fromViewController.view.toImage(),
              let toScreenshot   = toViewController.view.toImage() else { return }
        switch action {
        case .present:
            view.pageTransitionLayer.setPreviousPageImage(fromScreenshot.cgImage)
            view.pageTransitionLayer.setNewPageImage(toScreenshot.cgImage)
        case .dismiss:
            view.pageTransitionLayer.setPreviousPageImage(toScreenshot.cgImage)
            view.pageTransitionLayer.setNewPageImage(fromScreenshot.cgImage)
        }
        view.frame = transitionContext.containerView.bounds
        transitionContext.containerView.addSubview(view)
        view.pageTransitionLayer.animationCompletion = { (finished) in
            transitionContext.completeTransition(finished)
        }
        view.pageTransitionLayer.addAnimations()
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        view.removeFromSuperview()
    }
}
