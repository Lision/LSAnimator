Pod::Spec.new do |s|
  s.name             = 'CoreAnimator'
  s.summary          = 'Easy to Read and Write Multi-chain Animations Kit in Swift.'
  s.version          = '2.0.1'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lision' => 'lisionmail@gmail.com' }
  s.social_media_url = 'https://lision.me/'
  s.homepage         = 'https://github.com/Lision/LSAnimator'
  s.source           = { :git => 'https://github.com/Lision/LSAnimator.git', :tag => 'v#{s.version}' }
  s.source_files     = 'LSAnimator/*.{h,m,c,swift}'，'CoreAnimator/CoreAnimator.h'
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
end