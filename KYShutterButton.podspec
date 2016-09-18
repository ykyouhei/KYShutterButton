Pod::Spec.new do |s|
  s.name         = "KYShutterButton"
  s.version      = "2.0.0"
  s.summary      = "KYShutterButton is a custom button that is similar to the shutter button of the camera app"
  s.homepage     = "https://github.com/ykyouhei/KYShutterButton"
  s.license      = "MIT"
  s.author       = { "Kyohei Yamaguchi" => "kyouhei.lab@gmail.com" }
  s.social_media_url   = "https://twitter.com/kyo__hei"
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/ykyouhei/KYShutterButton.git", :tag => s.version.to_s }
  s.source_files = "KYShutterButton/Classes/*.swift"
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
end
