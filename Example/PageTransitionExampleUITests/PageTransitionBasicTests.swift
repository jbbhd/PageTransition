import XCTest
import FBSnapshotTestCase

private extension String {

    static let pt001 = "0.001"
    static let pt250 = "0.250"
    static let pt500 = "0.500"
    static let pt750 = "0.750"
    static let pt999 = "0.999"
}


class PageTranitionBasicTests: FBSnapshotTestCase {

    let timesToTest: [String] = [.pt001, .pt250, .pt500, .pt750, .pt999]

    override func setUp() {
        super.setUp()
        recordMode = true
    }

    func testFromLeftForward() {

        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: timesToTest)
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.closing,
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromLeft,
            TestLaunchArgument.PlayDirection.forward])
        app.launch()
        let imageView = UIImageView()
        for time in timesToTest {
            app.buttons.element.tap()
            let image = XCUIScreen.main.screenshot().image
            imageView.frame.size = image.size
            imageView.image = image
            FBSnapshotVerifyView(imageView, identifier: time)
        }
        app.terminate()
    }

    func testFromLeftBackward() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: timesToTest)
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.closing,
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromLeft,
            TestLaunchArgument.PlayDirection.backward])
        app.launch()
        let imageView = UIImageView()
        for time in timesToTest {
            app.buttons.element.tap()
            let image = XCUIScreen.main.screenshot().image
            imageView.frame.size = image.size
            imageView.image = image
            FBSnapshotVerifyView(imageView, identifier: time)
        }
        app.terminate()
    }

    func testFromRightForward() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: timesToTest)
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.closing,
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromRight,
            TestLaunchArgument.PlayDirection.forward])
        app.launch()
        let imageView = UIImageView()
        for time in timesToTest {
            app.buttons.element.tap()
            let image = XCUIScreen.main.screenshot().image
            imageView.frame.size = image.size
            imageView.image = image
            FBSnapshotVerifyView(imageView, identifier: time)
        }
        app.terminate()
    }

    func testFromRightBackward() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: timesToTest)
        app.launchArguments.append(contentsOf: [
            TestLaunchArgument.TestMode.closing,
            TestLaunchArgument.EasingFunction.linear,
            TestLaunchArgument.FlipDirection.fromRight,
            TestLaunchArgument.PlayDirection.backward])
        app.launch()
        let imageView = UIImageView()
        for time in timesToTest {
            app.buttons.element.tap()
            let image = XCUIScreen.main.screenshot().image
            imageView.frame.size = image.size
            imageView.image = image
            FBSnapshotVerifyView(imageView, identifier: time)
        }
        app.terminate()
    }
}
