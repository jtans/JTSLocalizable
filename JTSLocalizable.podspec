#
# Be sure to run `pod lib lint JTSLocalizable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JTSLocalizable'
  s.version          = '1.0.1'
  s.summary          = 'a easy framework to Localizable strings.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
a easy framework to Localizable strings.use it in your app is simple.
                       DESC

  s.homepage         = 'https://github.com/jtans/JTSLocalizable'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jtans' => 'jtans' }
  s.source           = { :git => 'https://github.com/jtans/JTSLocalizable.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/jtans'

  s.ios.deployment_target = '8.0'

  s.source_files = 'JTSLocalizable/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JTSLocalizable' => ['JTSLocalizable/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit'
  s.dependency 'AFNetworking'

end
