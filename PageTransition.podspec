
# Be sure to run `pod lib lint PageTransition.podspec'

Pod::Spec.new do |s|
  s.name             = 'PageTransition'
  s.version          = '0.1.0'
  s.summary          = 'A \"page flip\" transition using Core Animation.'
  s.description      = <<-DESC
A "page flip" transition using Core Animation. When animated, a single page of new content falls in from the left edge of the frame. Can be customized to flip from left or right, forward or backward. Designed for `UIViewController` transitions. Includes the `CALayer` subclass that performs the animation, a custom `UIView` with that layer as backing layer, and a premade `UIViewControllerAnimatedTransitioning` object.
                       DESC

  s.homepage         = 'https://github.com/jbbhd/PageTransition'
  s.screenshots     = 'https://i.imgur.com/iX57jQb.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jbbhd' => 'https://github.com/jbbhd/' }
  s.source           = { :git => 'https://github.com/jbbhd/PageTransition.git', :tag => s.version.to_s }
  
  s.swift_version = '5.2.4'
  s.ios.deployment_target = '10.0'
  s.frameworks = 'UIKit', 'QuartzCore'

  s.source_files = 'PageTransition/Classes/**/*'
  s.resource_bundles = {
      'PageTransition' => ['PageTransition/Assets/*.png']
  }
end
