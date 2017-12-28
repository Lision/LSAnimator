Pod::Spec.new do |s|
  s.name         = "LSAnimator"
  s.version      = "2.0.0"
  s.summary      = "Easy to Read and Write Multi-chain Animations Kit in Objective-C and You Can Find The Version That Supports Swift by Searching 'CoreAnimator'."
  s.homepage     = "https://github.com/Lision/LSAnimator"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Lision" => "lisionmail@gmail.com" }
  s.source       = { :git => "https://github.com/Lision/LSAnimator.git", :tag => "v2.0.0" }
  s.source_files = "LSAnimator/*.{h,m,c}"
  s.frameworks   = "UIKit", "QuartzCore"
  s.platform     = :ios, '7.0'
  s.requires_arc = true
end