#
# Be sure to run `pod lib lint NFLoadingController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NFLoadingController'
  s.version          = '0.1.0'
  s.summary          = 'NFLoadingController is a library to facilitate the process of creating a waiting/loading screen usin GIF image'

#s.description      = <<-DESC
#TODO: Add long description of the pod here.
#                       DESC

  s.homepage         = 'https://github.com/NFLibs/NFLoadingController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'noursandid' => 'noursandid@gmail.com' , 'FirasAKAK' => 'fir_khalidi@hotmail.com' }
  s.source           = { :git => 'https://github.com/NFLibs/NFLoadingController.git', :tag => s.version }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Pod/Classes/**/*'
  
s.resource_bundles = {
     'NFLoadingController' => ['Pod/Assets/**/*']
   }


   s.dependency 'SwiftGifOrigin'
end
