Pod::Spec.new do |s|
  s.name             = 'LinkIO'
  s.version          = '1.1.0'
  s.summary          = 'Self-hosted deep linking SDK for iOS'
  s.description      = <<-DESC
LinkIO is a self-hosted deep linking solution that handles universal links and deferred deep linking for iOS applications.
Open-source alternative to Branch.io.
                       DESC
  s.homepage         = 'https://github.com/pt-nakul-sharma/LinkIO-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nakul Sharma' => 'nakul@rokart.in' }
  s.source           = { :git => 'https://github.com/pt-nakul-sharma/LinkIO-iOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'LinkIO/Classes/**/*'
  s.frameworks = 'UIKit', 'Foundation'
end
