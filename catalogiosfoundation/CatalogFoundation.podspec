Pod::Spec.new do |s|
  @@podLocal = ENV['POD_LOCAL_HOME']

  s.name         = "CatalogFoundation"
  s.version      = "5.10.LOCAL"
  s.summary      = "CatalogFoundation is required to provide the basics for Salesfolio (Catalog App) UI and accessing offline content."
  s.homepage     = "https://github.com/objectpartners/catalogiosfoundation"
  s.license      = {
    :type => 'OPI Proprietary',
    :text => <<-LICENSE
              Copyright (C) 2010-2014 Object Partners Inc.  All rights reserved.
    LICENSE
  }
  s.authors       = { "Steve McCoole" => "steve.mccoole@objectpartners.com", "Torey Lomenda" => "torey.lomenda@objectpartners.com" }
  s.source       = { :git => "https://github.com/objectpartners/catalogiosfoundation.git", :tag => "5.10.LOCAL" }
  s.platform     = :ios, '6.0'
  
  #-- Source and Resources
  s.prefix_header_file = "CatalogFoundation/CatalogFoundation-Prefix.pch"
  s.resources = ['CatalogFoundationResources/**/*.{png,gif,jpg,strings}', 'CatalogFoundation/**/*.{xcdatamodeld}']
  
  s.source_files = 'CatalogFoundation/**/*.{h,m,c}'
  s.requires_arc = true
  
  #--Search Paths
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libz $(SDKROOT)/usr/include/libxml2', 'OTHER_LDFLAGS' => '-all_load', 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/FastPdfKit@objectpartners/FastPdfKit.embeddedframework"' }
  
  #-- Dependencies (Third Party)
  s.dependency 'FastPdfKit@objectpartners/FastPdfKit.embeddedframework', '4.0'
  s.dependency 'DTCoreText', '~> 1.6.11'
  s.dependency 'CustomBadge', '~> 2.0'
  s.dependency 'iCarousel', '~> 1.7.6'
  s.dependency 'AFNetworking', '~> 2.2.4'
  s.dependency 'PDKeychainBindingsController@objectpartners', '~> 1.1'
  s.dependency 'FXLabel', '~> 1.5.8'
  
  s.dependency 'ContentSync', '~> 5.2'
  s.dependency 'OPIFoundation/UILayoutManagers', '~> 5.5'
  s.dependency 'OPIFoundation/UISketchPad', '~> 5.5'
  s.dependency 'OPIFoundation/UICustomViewsAndControllers', '~> 5.5'
  #s.dependency 'OPIFoundation/UIThirdParty', '~> 5.5'
    
  #-- Frameworks and Libraries
  s.libraries = 'z', 'xml2', 'sqlite3.0'
  s.frameworks = 'AudioToolbox', 'AVFoundation', 'CFNetwork', 'CoreData', 'CoreGraphics', 'CoreMedia', 'CoreText', 'Foundation', 'ImageIO', 'MediaPlayer', 'MediaToolbox', 'MessageUI', 'MobileCoreServices', 'OpenGLES', 'QuartzCore', 'QuickLook', 'UIKit', 'Security', 'SystemConfiguration'
end
