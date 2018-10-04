//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos
@testable import CollageMaker

class BundleClass {}

class MockPhotoLibrary: PhotoLibraryType {
    var assets: [PHAsset] = Array(repeating: PHAsset(), count: 4)
    
    var delegate: PhotoLibraryDelegate?
    
    func stopCaching() {}
    
    func assetFor(localIdentifier: String) -> PHAsset? {
        return assets.first(where: { $0.localIdentifier == localIdentifier })
    }
    
    func add(_ image: UIImage, callback: @escaping (Bool, PHAsset?) -> Void) { }
    
    func cacheImages(with assets: [PHAsset]) {}
    
    func photo(with asset: PHAsset, deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize?, callback: @escaping PhotoCompletion) {
        let image =  UIImage(named: "test_img", in: Bundle(for: BundleClass.self), compatibleWith: nil)
        callback(image)
    }
    
    func collectPhotos(from assets: [PHAsset], deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize, callback: @escaping PhotosCompletion) {
        callback(assets.compactMap { _ in UIImage(named: "test_img", in: Bundle(for: BundleClass.self), compatibleWith: nil) })
    }
}
