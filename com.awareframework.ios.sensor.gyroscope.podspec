#
# Be sure to run `pod lib lint com.awareframework.ios.sensor.gyroscope.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'com.awareframework.ios.sensor.gyroscope'
  s.version          = '0.7.0'
  s.summary          = 'A Gyroscope Sensor Module for AWARE Framework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
com.awareframework.ios.sensor.gyroscope (Gyroscope) is a sensor module of Aware Framework. This module provides Gyroscope data, indicating the instantaneous rotation around the device's three primary axes.
https://developer.apple.com/documentation/coremotion/getting_raw_gyroscope_events
                       DESC

  s.homepage         = 'https://github.com/awareframework/com.awareframework.ios.sensor.gyroscope'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache2', :file => 'LICENSE' }
  s.author           = { 'Yuuki Nishiyama' => 'nishiyama@csis.u-tokyo.ac.jp' }
  s.source           = { :git => 'https://github.com/awareframework/com.awareframework.ios.sensor.gyroscope.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform              = :ios, '13.0'
  s.ios.deployment_target = '13.0'

  s.swift_version = '5'

  s.source_files = 'com.awareframework.ios.sensor.gyroscope/Classes/**/*'
  

  s.frameworks = 'CoreMotion' 
  s.dependency 'com.awareframework.ios.sensor.core', '~> 0.7'
  
end
