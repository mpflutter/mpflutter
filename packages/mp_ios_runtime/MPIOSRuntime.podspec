Pod::Spec.new do |spec|

  spec.name         = "MPIOSRuntime"
  spec.version      = "0.0.1"
  spec.summary      = "The MPFlutter runtime of iOS."
  spec.description  = <<-DESC
                      The MPFlutter runtime of iOS.
                      DESC

  spec.homepage     = "https://github.com/mpflutter/mpflutter"
  spec.license      = "Apache"
  
  spec.author             = { "PonyCui" => "cuis@vip.qq.com" }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/mpflutter/mpflutter" }
  spec.source_files  = "src", "src/**/*.{h,m}"
  spec.public_header_files = "src/MPIOSRuntime.h", "src/MPIOSViewController.h", "src/MPIOSApplet.h", "src/MPIOSCardlet.h", "src/MPIOSPage.h", "src/MPIOSEngine.h", "src/MPIOSProvider.h", "src/components/MPIOSComponentView.h", "src/components/mpkit/MPIOSMPPlatformView.h", "src/platform_channel/MPIOSPluginRegister.h", "src/platform_channel/MPIOSMethodChannel.h", "src/platform_channel/MPIOSEventChannel.h"
  spec.resources = "src/**/*.js"
  spec.requires_arc = true
  spec.dependency "jetfire", "~> 0.1"
  spec.dependency "MBProgressHUD", "~> 1.2.0"
  spec.dependency "SDWebImage", "~> 5.0"
  spec.dependency "SDWebImageSVGKitPlugin"
  spec.dependency "SVGKit", "2.1.0"

end
