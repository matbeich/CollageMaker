platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def external
    source 'https://github.com/CocoaPods/Specs.git'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'SnapKit'
    pod 'R.swift'
    pod 'Firebase/Core'
    pod 'Firebase/RemoteConfig'
end

def internal
    source 'git@github.com:app-craft/internal-pods.git'
    pod 'AppCraftUtils/Interface', '1.2.64'
    pod 'AppCraftUtils/Sharing', '1.2.64'
end

target 'CollageMaker' do
  internal
  external

  target 'CollageMakerTests' do
      inherit! :search_paths
      pod 'iOSSnapshotTestCase'
      pod 'EarlGrey'
  end
end
