platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def external
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SnapKit'
  pod 'R.swift'

end

def internal
  source 'git@github.com:app-craft/internal-pods.git'
  pod 'AppCraftUtils/Interface', '1.2.64'
  pod 'AppCraftUtils/Sharing', '1.2.64'
end

target 'CollageMaker' do
  internal
  external
  
  target 'SnapshotTests' do
      inherit! :search_paths
      pod 'iOSSnapshotTestCase'
  end
  
  target 'CollageMakerTests' do
      inherit! :search_paths
      pod 'FBSnapshotTestCase'
  end
end


