Pod::Spec.new do |s|
  s.name         = "LSAnimator"
  s.version      = "1.2.0"
  s.summary      = "Easy to read and write non-intrusive multi-chain animation kits."
  s.homepage     = "https://github.com/Lision/LSAnimator"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Lision" => "lisionmail@gmail.com" }
  s.source       = { :git => "https://github.com/Lision/LSAnimator.git", :tag => "v1.2.0" }
  s.source_files = "LSAnimator/*.{h,m,c}"
  s.frameworks   = "UIKit", "QuartzCore"
  s.platform     = :ios, '7.0'
  s.requires_arc = true
end