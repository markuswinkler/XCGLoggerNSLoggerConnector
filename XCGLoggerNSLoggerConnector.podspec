#
# Be sure to run `pod lib lint XCGLoggerNSLoggerConnector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "XCGLoggerNSLoggerConnector"
  s.version          = "0.1.4"
  s.summary          = "fix for new swift syntax"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
#s.description      = <<-DESC
#Adds NSLogger support (with images) to XCGLogger.
#                       DESC

  s.homepage         = "https://github.com/markuswinkler/XCGLoggerNSLoggerConnector"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Markus Winkler" => "markus@markuswinkler.com" }
  s.source           = { :git => "https://github.com/markuswinkler/XCGLoggerNSLoggerConnector.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://twitter.com/creativegun'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'XCGLoggerNSLoggerConnector/**/*.{swift}'

  s.dependency 'XCGLogger', '>= 3.1', '<= 3.3'
  s.dependency 'NSLogger', '~> 1.5'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.framework = 'UIKit'
end
