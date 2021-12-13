Pod::Spec.new do |spec|

  spec.name         = "MPIOSRuntime"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of mp_ios_runtime."
  spec.description  = <<-DESC
                      A short description of mp_ios_runtime.
                      DESC

  spec.homepage     = "http://EXAMPLE/mp_ios_runtime"
  spec.license      = "Apache"
  
  spec.author             = { "PonyCui" => "cuis@vip.qq.com" }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/mpflutter/mp_ios_runtime", :tag => "0.0.1" }
  spec.source_files  = "src", "src/**/*.{h,m}"
  spec.public_header_files = "src/MPIOSRuntime.h", "src/MPIOSViewController.h", "src/MPIOSApp.h", "src/MPIOSPage.h", "src/MPIOSEngine.h", "src/components/MPIOSComponentView.h", "src/components/basic/MPIOSImage.h"
  spec.resources = "src/**/*.js"
  spec.requires_arc = true
  spec.dependency "jetfire", "~> 0.1"
  spec.dependency "MBProgressHUD", "~> 1.2.0"

end
