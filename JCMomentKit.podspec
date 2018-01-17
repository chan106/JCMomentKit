Pod::Spec.new do |s|

  s.name         = 'JCMomentKit'
  s.version      = ‘0.0.2’
  s.summary      = 'A PYQ of iOS components.'
  s.homepage     = 'https://github.com/chan106/JCMomentKit.git'
  s.license      = 'MIT'
  s.platform     = :ios
  s.author       = {'郭吉成' => 'ji.chan@foxmail.com'}

  s.ios.deployment_target = '8.0'
  s.source       = {:git => 'https://github.com/chan106/JCMomentKit.git', :tag => s.version.to_s}
  s.source_files = 'JCMomentKit/**/*.{h,m}'
  s.resources    = 'JCMomentKit/**/*.{png,xib}’

  s.requires_arc = true
  s.frameworks = 'Foundation', 'UIKit'

  s.dependency 'YYKit'
  s.dependency 'SDWebImage'

end
