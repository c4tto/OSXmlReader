#
# Be sure to run `pod lib lint OSXmlReader.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "OSXmlReader"
  s.version          = "0.1.0"
  s.summary          = "XML Reader using GDataXML-HTML"
  s.description      = <<-DESC
                       An optional longer description of OSXmlReader

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/c4tto/OSXmlReader"
  s.license          = 'MIT'
  s.author           = { "Ondrej Stocek" => "ostocek@gmail.com" }
  s.source           = { :git => "https://github.com/c4tto/OSXmlReader.git", :tag => s.version.to_s }

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'OSXmlReader' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'GDataXML-HTML', '~> 1.2.0'
  s.libraries = "iconv", "xml2"
  s.requires_arc = true
  s.xcconfig = {
	 "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2"
  }
end
