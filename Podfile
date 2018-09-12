platform :ios, '11.0'
use_frameworks!

def defaults
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'SnapKit'
    pod 'R.swift'
    pod 'AppCraftUtils/Interface'
end

def external
  source 'https://github.com/CocoaPods/Specs.git'
end

def internal
  source 'git@github.com:app-craft/internal-pods.git'
end

target 'CollageMaker' do
  internal
  external

  defaults
  
  target 'CollageMakerUITests' do
      inherit! :search_paths
  end
  
  target 'CollageMakerTests' do
      inherit! :search_paths
  end
end


