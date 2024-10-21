#
# Be sure to run `pod lib lint andpad-camera.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'andpad-camera'
  # 社内ライブラリであり、Tag指定でインストールを行うため、このversionは形式的なものとなっている。メジャーバージョンアップ時以外は更新しない運用とする。
  s.version          = '1.0.0'
  s.summary          = 'ANDPAD Camera library.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
andpad-camera is an in-house library with special camera features.
                       DESC

  s.homepage         = 'https://github.com/88labs/andpad-camera-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "ANDPAD Contributors"
  s.source           = { :git => "https://github.com/88labs/andpad-camera-ios.git", :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'

  s.source_files = 'andpad-camera/Classes/**/*'

  s.resource_bundles = {
    'andpad-camera' => [
      'andpad-camera/Assets/**/*.{storyboard,xib,xcassets,strings}',
      'andpad-camera/Assets/GeneratingBlackboardResources/**/*.{html,ttf,js}'
    ]
  }

  # Workaround: To display images in flutter
  # https://github.com/flutter/flutter/issues/58232
  s.resources = 'andpad-camera/Assets/*.xcassets'

  s.dependency 'Alamofire', '~>5.0'

  s.dependency 'EasyPeasy'
  s.dependency 'SnapKit'
  s.dependency 'UIImage-ResizeMagick'
  s.dependency 'Instantiate'
  s.dependency 'InstantiateStandard'
  s.dependency 'Nuke'

  s.dependency 'RxSwift', '~>6.6.0'
  s.dependency 'RxCocoa'
  s.dependency 'RxDataSources'

  # Private spec
  s.dependency 'TamperProof'
  s.dependency 'AndpadCore'
  s.dependency 'AndpadUIComponent'
  s.dependency 'rakugaki'

  s.frameworks = 'UIKit', 'Photos'
end
