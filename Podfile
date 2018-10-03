platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def defaults
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'SnapKit'
    pod 'R.swift'
    pod 'AppCraftUtils/Interface', '1.2.64'
    pod 'AppCraftUtils/Sharing', '1.2.64'
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
      pod 'FBSnapshotTestCase'
  end
  
  target 'CollageMakerTests' do
      inherit! :search_paths
      pod 'FBSnapshotTestCase'
  end
end


