import XCTest
import PageTransition
import FBSnapshotTestCase
import Foundation

class PageTranitionDustTests: FBSnapshotTestCase {
    
    private let sharedLayer = PTPageTransitionLayer()
        
    private let overallTolerance: CGFloat = 0.15
    
    private let playTime: TimeInterval = 0.2
    
    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testFromLeftWithLargeDust() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.dust,
            TestLaunchArgument.DustSize.large,
            "\(playTime)",
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromLeft,
            TestLaunchArgument.PlayDirection.forward,
            ])
        app.launch()
        
        let expectation = self.expectation(description: "Animation plays.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + playTime) {
            let image = XCUIScreen.main.screenshot().image
            let imageView = UIImageView()
            imageView.frame.size = image.size
            imageView.image = image
            self.FBSnapshotVerifyView(imageView, overallTolerance: self.overallTolerance)
            app.terminate()
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testFromLeftWithMediumDust() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.dust,
            TestLaunchArgument.DustSize.medium,
            "\(playTime)",
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromLeft,
            TestLaunchArgument.PlayDirection.forward,
            ])
        app.launch()
        
        let expectation = self.expectation(description: "Animation plays.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + playTime) {
            let image = XCUIScreen.main.screenshot().image
            let imageView = UIImageView()
            imageView.frame.size = image.size
            imageView.image = image
            self.FBSnapshotVerifyView(imageView, overallTolerance: self.overallTolerance)
            app.terminate()
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testFromLeftWithSmallDust() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.dust,
            TestLaunchArgument.DustSize.small,
            "\(playTime)",
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromLeft,
            TestLaunchArgument.PlayDirection.forward,
            ])
        app.launch()
        
        let expectation = self.expectation(description: "Animation plays.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + playTime) {
            let image = XCUIScreen.main.screenshot().image
            let imageView = UIImageView()
            imageView.frame.size = image.size
            imageView.image = image
            self.FBSnapshotVerifyView(imageView, overallTolerance: self.overallTolerance)
            app.terminate()
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testFromRightWithLargeDust() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.dust,
            TestLaunchArgument.DustSize.large,
            "\(playTime)",
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromRight,
            TestLaunchArgument.PlayDirection.forward,
            ])
        app.launch()
        
        let expectation = self.expectation(description: "Animation plays.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + playTime) {
            let image = XCUIScreen.main.screenshot().image
            let imageView = UIImageView()
            imageView.frame.size = image.size
            imageView.image = image
            self.FBSnapshotVerifyView(imageView, overallTolerance: self.overallTolerance)
            app.terminate()
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testFromRightWithMediumDust() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.dust,
            TestLaunchArgument.DustSize.medium,
            "\(playTime)",
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromRight,
            TestLaunchArgument.PlayDirection.forward,
            ])
        app.launch()
        
        let expectation = self.expectation(description: "Animation plays.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + playTime) {
            let image = XCUIScreen.main.screenshot().image
            let imageView = UIImageView()
            imageView.frame.size = image.size
            imageView.image = image
            self.FBSnapshotVerifyView(imageView, overallTolerance: self.overallTolerance)
            app.terminate()
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testFromRightWithSmallDust() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.dust,
            TestLaunchArgument.DustSize.small,
            "\(playTime)",
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromRight,
            TestLaunchArgument.PlayDirection.forward,
            ])
        app.launch()
        
        let expectation = self.expectation(description: "Animation plays.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + playTime) {
            let image = XCUIScreen.main.screenshot().image
            let imageView = UIImageView()
            imageView.frame.size = image.size
            imageView.image = image
            self.FBSnapshotVerifyView(imageView, overallTolerance: self.overallTolerance)
            app.terminate()
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
}
