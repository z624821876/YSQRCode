Pod::Spec.new do |s|
  s.name             = 'YSQRCodeGenerator'
  s.version          = '1.0'
  s.summary          = '根据EFQRCode改写的 OC 版本二维码生成库，方法与EFQRCode保持一致'

  s.homepage         = 'https://github.com/z624821876/YSQRCode'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'z624821876' => 'yu624821876@163.com' }
  s.source           = { :git => 'https://github.com/z624821876/YSQRCode.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YSQRCodeGenerator/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YSQRCodeGenerator' => ['YSQRCodeGenerator/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
