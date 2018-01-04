Pod::Spec.new do |s|
  s.name             = 'LSAnimator'
  s.summary          = 'Easy to Read and Write Multi-chain Animations Kit in Objective-C.'
  s.version          = '2.1.1'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lision' => 'lisionmail@gmail.com' }
  s.social_media_url = 'https://lision.me/'
  s.homepage         = 'https://github.com/Lision/LSAnimator'
  s.source           = { :git => 'https://github.com/Lision/LSAnimator.git', :tag => s.version.to_s }
  s.source_files     = 'LSAnimator/*.{h,m,c}'
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
end