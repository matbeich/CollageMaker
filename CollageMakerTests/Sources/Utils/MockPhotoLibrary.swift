//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import Photos

class MockPhotoLibrary: PhotoLibraryType {
    enum Quality {
        case high
        case medium
    }

    var quality: Quality
    var assets: [PHAsset]

    weak var delegate: PhotoLibraryDelegate?

    init(assetsCount: Int = 50, quality: Quality = .medium) {
        self.assets = Array(1 ... assetsCount).map { _ in PHAsset() }
        self.quality = quality
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
        callback(quality == .medium ? UIImage.testing : UIImage.testingHQ)
    }

    func collectPhotos(from assets: [PHAsset], deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize, callback: @escaping PhotosCompletion) {
        callback(assets.compactMap { _ in
            let img = quality == .medium ? UIImage.testing : UIImage.testingHQ
            return img
        })
    }
}
