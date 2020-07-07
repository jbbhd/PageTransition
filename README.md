# PageTransition

## Summary

A "page flip" transition using Core Animation. When animated, a single page of new content falls in from the left edge of the frame. Can be customized to flip from left or right, forward or backward. Designed for `UIViewController` transitions. Includes the `CALayer` subclass that performs the animation, a custom `UIView` with that layer as backing layer, and a premade `UIViewControllerAnimatedTransitioning` object.

See `PDPageTransitionLayer.swift` for more documentation. 

![Page Transition Example](https://i.imgur.com/iX57jQb.gif)

## Installation

PageTransition is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PageTransition'
```

## License

PageTransition is available under the MIT license. See the LICENSE file for more info.
