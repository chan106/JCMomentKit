Pod::Spec.new do |s|
s.name         = 'JCMomentKit'
s.summary      = 'A PYQ of iOS components.'
s.version      = '1.0.5'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors      = { 'Guo.JC' => 'ji.chan@foxmail.com' }

s.homepage     = 'https://github.com/chan106/JCMomentKit.git'
s.platform     = :ios
s.ios.deployment_target = '8.0'
s.source       = { :git => 'https://github.com/chan106/JCMomentKit.git', :tag => s.version }

s.requires_arc = true
s.source_files = 'JCMomentKit/**/*.{h,m}'
s.resources    = 'JCMomentKit/**/*.{png,xib,bundle,lproj}'

s.requires_arc = true
s.frameworks = 'UIKit','Photos','CoreLocation'

s.dependency 'YYKit'
s.dependency 'SDWebImage'
s.dependency 'MJRefresh'
end

