import UIKit

struct TestLaunchArgument {
    
    struct FlipDirection {
        
        static let fromLeft = "flipDirectionFromLeft"
        static let fromRight = "flipDirectionFromRight"
    }
    
    struct PlayDirection {
        
        static let forward = "playDirectionForward"
        static let backward = "playDirectionBackward"
    }
    
    struct DustSize {
        
        static let small = "dustSizeSmall"
        static let medium = "dustSizeMedium"
        static let large = "dustSizeLarge"
    }
    
    struct EasingFunction {
        
        static let linear = "easingFunctionLinear"
    }

    struct TestMode {
        
        static let closing = "testModeClosing"
        static let dust = "testModeDust"
    }
}
