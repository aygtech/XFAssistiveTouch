
Pod::Spec.new do |s|

  s.name         	= "XFAssistiveTouch_WeexBox"
  s.version      	= "1.0.0"
  s.summary      	= "Assistive button the same as iOS AssistiveTouch"
  s.homepage     	= "https://github.com/aygtech/XFAssistiveTouch_WeexBox"
  s.license      	= { :type => "MIT", :file => "LICENSE" }
  s.author 		= { "Mario" => "myeveryheart@qq.com" }
  s.platform     	= :ios, "8.0"
  s.source       	= { :git => "https://github.com/aygtech/XFAssistiveTouch_WeexBox.git", :tag => s.version }
  s.source_files  	= "XFAssistiveTouch/*.{h,m}"
  s.requires_arc 	= true
  s.dependency 'SDWebImage'
end

