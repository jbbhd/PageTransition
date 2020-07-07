import UIKit
import PageTransition

class ViewController: UIViewController {

    private enum TestMode {
        case closing
        case dust
    }
    
    private var transitionView: PTPageTransitionView!
    
    private var nextButton: UIButton!
    
    private var progressSteps: [CFTimeInterval] = []
    
    private var testMode: TestMode?
    
    private var pauseTime: CFTimeInterval!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let flipDirection: PTPageTransitionLayer.FlipDirection? = {
            if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.FlipDirection.fromLeft) {
                return .fromLeft
            } else if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.FlipDirection.fromRight) {
                return .fromRight
            } else {
                return nil
            }
        }()
        let isReversed: Bool? = {
            if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.PlayDirection.forward) {
                return false
            } else if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.PlayDirection.backward) {
                return true
            } else {
                return nil
            }
        }()
        let easingFunction: CAMediaTimingFunction? = {
            if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.EasingFunction.linear) {
                return CAMediaTimingFunction(name: .linear)
            } else {
                return nil
            }
        }()
        testMode = {
            if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.TestMode.closing) {
                return .closing
            } else if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.TestMode.dust) {
                return .dust
            } else {
                return self.testMode
            }
        }()
        transitionView = PTPageTransitionView()
        transitionView.pageTransitionLayer.flipDirection  = flipDirection  ?? transitionView.pageTransitionLayer.flipDirection
        transitionView.pageTransitionLayer.isReversed     = isReversed     ?? transitionView.pageTransitionLayer.isReversed
        transitionView.pageTransitionLayer.easingFunction = easingFunction ?? transitionView.pageTransitionLayer.easingFunction
        switch testMode {
        case .closing:
            progressSteps = ProcessInfo.processInfo.arguments.compactMap({ CFTimeInterval($0) }).sorted()
        case .dust:
            let dustSize: PTPageTransitionLayer.DustCloudSize = {
                if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.DustSize.small) {
                    return .small
                } else if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.DustSize.medium) {
                    return .medium
                } else if ProcessInfo.processInfo.arguments.contains(TestLaunchArgument.DustSize.large) {
                    return .large
                } else {
                    return .large
                }
            }()
            transitionView.pageTransitionLayer.addClosingDustIfForward = true
            transitionView.pageTransitionLayer.dustCloudSize = dustSize
        case .none:
             break
        }
        transitionView.pageTransitionLayer.setupSublayers()
        transitionView.pageTransitionLayer.setPreviousPageImage(UIImage(named: "PrevPageImage")?.cgImage)
        transitionView.pageTransitionLayer.setNewPageImage(UIImage(named: "NewPageImage")?.cgImage)
        let width = view.frame.size.width-40.0
        transitionView.frame.size = CGSize(width: width, height: width)
        view.addSubview(transitionView)
        transitionView.center.x = view.frame.midX
        transitionView.center.y = view.frame.midY

        nextButton = UIButton()
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        nextButton.frame = view.bounds
        view.addSubview(nextButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch testMode {
        case .closing:
            transitionView.pageTransitionLayer.addAnimations()
            transitionView.pageTransitionLayer.speed = 0.0
            pauseTime = transitionView.pageTransitionLayer.convertTime(CACurrentMediaTime(), from: nil)
            transitionView.pageTransitionLayer.timeOffset = pauseTime
        case .dust:
            // Make the animation start with the dust animation.
            transitionView.pageTransitionLayer.addAnimations()
            transitionView.pageTransitionLayer.speed = 0.0
            // Force the animation to render here so later edits to `timeOffset` will be visible.
            RunLoop.main.run(mode: .default, before: Date())
            pauseTime = transitionView.pageTransitionLayer.convertTime(CACurrentMediaTime(), from: nil)
            transitionView.pageTransitionLayer.timeOffset = pauseTime + transitionView.pageTransitionLayer.closingDuration
            transitionView.pageTransitionLayer.speed = 1.0
        case .none:
            transitionView.pageTransitionLayer.addAnimations()
        }
    }
    
    @objc func didTapNext() {
        guard progressSteps.count > 0 else { return }
        transitionView.pageTransitionLayer.timeOffset = pauseTime + progressSteps[0]*transitionView.pageTransitionLayer.totalDuration
        progressSteps = Array(progressSteps.dropFirst())
    }
}

