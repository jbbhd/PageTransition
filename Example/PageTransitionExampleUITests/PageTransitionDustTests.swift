import XCTest
import PageTransition
import FBSnapshotTestCase
import Foundation

class PageTranitionDustTests: FBSnapshotTestCase {
    
    private let sharedLayer = PTPageTransitionLayer()
    
    private let dustSizes = [TestLaunchArgument.DustSize.large, TestLaunchArgument.DustSize.medium, TestLaunchArgument.DustSize.small]
    
    private let tolerance: CGFloat = 0.25
    
    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testDustFromLeftForward() {
        for dustSize in dustSizes {
            let app = XCUIApplication()
            app.launchArguments.append(contentsOf: [
                TestLaunchArgument.TestMode.dust,
                dustSize,
                TestLaunchArgument.EasingFunction.linear,
                TestLaunchArgument.FlipDirection.fromLeft,
                TestLaunchArgument.PlayDirection.forward,
                ])
            app.launch()
             
            let image = XCUIScreen.main.screenshot().image
            let imageView = UIImageView()
            imageView.frame.size = image.size
            imageView.image = image
            self.FBSnapshotVerifyView(imageView, identifier: dustSize, overallTolerance: tolerance)
            
            app.terminate()
        }
    }
    
    func testDustFromRightForward() {
        for dustSize in dustSizes {
            let app = XCUIApplication()
            app.launchArguments.append(contentsOf: [
                TestLaunchArgument.TestMode.dust,
                dustSize,
                TestLaunchArgument.EasingFunction.linear,
                TestLaunchArgument.FlipDirection.fromRight,
                TestLaunchArgument.PlayDirection.forward,
                ])
            app.launch()
             
            let image = XCUIScreen.main.screenshot().image
            let imageView = UIImageView()
            imageView.frame.size = image.size
            imageView.image = image
            self.FBSnapshotVerifyView(imageView, identifier: dustSize, overallTolerance: tolerance)
            
            app.terminate()
        }
    }
}
