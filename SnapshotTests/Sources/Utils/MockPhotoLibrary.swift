//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import Foundation
import Photos

class MockPhotoLibrary: PhotoLibraryType {
    var assets: [PHAsset]

    weak var delegate: PhotoLibraryDelegate?

    init(assets: [PHAsset]) {
        self.assets = assets
    }

    func stopCaching() {}

    func assetFor(localIdentifier: String) -> PHAsset? {
        return assets.first(where: { $0.localIdentifier == localIdentifier })
    }

    func add(_ image: UIImage, callback: @escaping (Bool, PHAsset?) -> Void) {}

    func cacheImages(with assets: [PHAsset]) {}

    func photo(with asset: PHAsset, deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize?, callback: @escaping PhotoCompletion) {
        let image = UIImage.test
        callback(image)
    }

    func collectPhotos(from assets: [PHAsset], deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize, callback: @escaping PhotosCompletion) {
        callback(assets.compactMap { _ in UIImage.test })
    }
}
