//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import Photos

class MockPhotoLibrary: PhotoLibraryType {
    var assets: [PHAsset]

    weak var delegate: PhotoLibraryDelegate?

    init(assetsCount: Int) {
        self.assets = Array(1 ... assetsCount).map { _ in PHAsset() }
    }

    func stopCaching() {}

    func assetFor(localIdentifier: String) -> PHAsset? {
        return PHAsset()
    }

    func add(_ image: UIImage, callback: @escaping (Bool, PHAsset?) -> Void) {
        callback(true, PHAsset())
    }

    func cacheImages(with assets: [PHAsset]) {}

    func photo(with asset: PHAsset, deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize?, callback: @escaping PhotoCompletion) {
        callback(UIImage.test)
    }

    func collectPhotos(from assets: [PHAsset], deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize, callback: @escaping PhotosCompletion) {
        callback(assets.compactMap { _ in UIImage.test })
    }
}
