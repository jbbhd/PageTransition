import UIKit

// https://stackoverflow.com/questions/52628113/pausing-and-resuming-caemitterlayer-multiple-of-times
extension CAEmitterLayer {

    public func pause() {
        speed = 0.0
        timeOffset = convertTime(CACurrentMediaTime(), from: self) - beginTime
        lifetime = 0.0
    }

    public func resume() {
        speed = 1.0
        beginTime = convertTime(CACurrentMediaTime(), from: self) - timeOffset
        timeOffset = 0.0
        lifetime = 1.0
    }
}
