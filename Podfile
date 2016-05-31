platform :ios, '8.0'
use_frameworks!

abstract_target 'ShapeSwiftShared' do
  pod 'proj4', :podspec => './podspecs/proj4.podspec'
  target 'ShapeSwift'
  target 'ShapeSwiftTests' do
    pod 'ShapeSwift', :path => './'
  end
end



