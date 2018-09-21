//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos

final class PhotoLibraryService {
    static func getImagesAssets() -> [PHAsset] {
        var assets = [PHAsset]()
        let options = PHFetchOptions()

        options.includeAssetSourceTypes = .typeUserLibrary
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let imageFetchResult = PHAsset.fetchAssets(with: .image, options: options)

        imageFetchResult.enumerateObjects { object, _, _ in
            assets.append(object)
        }

        return assets
    }

    static func cacheImages(for assets: [PHAsset]) {
        imageCacher.startCachingImages(for: assets, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil)
    }

    static func stopCaching() {
        imageCacher.stopCachingImagesForAllAssets()
    }

    static func photo(from asset: PHAsset, deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize? = nil, callback: @escaping (UIImage?) -> Void) {
        let sizeForTarget = size ?? CGSize(width: asset.pixelWidth, height: asset.pixelHeight)

        let options = PHImageRequestOptions()

        options.deliveryMode = deliveryMode
        manager.requestImage(for: asset,
                             targetSize: sizeForTarget,
                             contentMode: .aspectFit,
                             options: options) { image, _ in callback(image)
        }
    }

    static func add(_ image: UIImage, to library: PHPhotoLibrary = .shared(), callback: @escaping (Bool) -> Void) {
        let changeBlock = {
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let addAssetRequest = PHAssetCollectionChangeRequest(for: PHAssetCollection())

            guard let placeholder = creationRequest.placeholderForCreatedAsset else {
                callback(false)
                return
            }

            addAssetRequest?.addAssets([placeholder] as NSArray)
        }

        library.performChanges(changeBlock) { success, _ in
            DispatchQueue.main.async {
                callback(success)
            }
        }
    }

    private static let imageCacher = PHCachingImageManager()
    private static let manager = PHImageManager.default()
}
