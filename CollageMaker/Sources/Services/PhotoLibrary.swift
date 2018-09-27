//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos

protocol PhotoLibraryDelegate: AnyObject {
    func photoLibrary(_ library: PhotoLibrary, didUpdateAssets assets: [PHAsset])
    func photoLibrary(_ library: PhotoLibrary, didRemoveAssets assets: [PHAsset])
    func photoLibrary(_ library: PhotoLibrary, didInsertAssets assets: [PHAsset])
}

final class PhotoLibrary: NSObject {
    weak var delegate: PhotoLibraryDelegate?

    init(library: PHPhotoLibrary = .shared()) {
        self.library = library
        super.init()

        getImagesAssets()
        observeAssets()
    }

    func add(_ image: UIImage, callback: @escaping (Bool) -> Void) {
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

    private func getImagesAssets() {
        let options = PHFetchOptions()

        options.includeAssetSourceTypes = .typeUserLibrary

        assetsFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        assetsFetchResult.enumerateObjects { [weak self] object, _, _ in
            self?.assets.append(object)
        }

        delegate?.photoLibrary(self, didUpdateAssets: assets)
    }

    private func observeAssets() {
        library.register(self)
    }

    private func updateAssets(with changeDetails: PHFetchResultChangeDetails<PHAsset>) {
        changeDetails.removedObjects.forEach { asset in assets = assets.filter { $0 != asset } }
        assets.append(contentsOf: changeDetails.insertedObjects)

        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.delegate?.photoLibrary(self, didInsertAssets: changeDetails.insertedObjects)
            self.delegate?.photoLibrary(self, didRemoveAssets: changeDetails.removedObjects)
        }
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

        PHImageManager.default().requestImage(for: asset,
                                              targetSize: sizeForTarget,
                                              contentMode: .default,
                                              options: options) { image, _ in callback(image)
        }
    }

    private(set) var assets = [PHAsset]()
    private static let imageCacher = PHCachingImageManager()
    private let library: PHPhotoLibrary
    private var assetsFetchResult = PHFetchResult<PHAsset>()
}

extension PhotoLibrary: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changeDetails = changeInstance.changeDetails(for: assetsFetchResult) else {
            return
        }

        assetsFetchResult = changeDetails.fetchResultAfterChanges
        updateAssets(with: changeDetails)
    }
}
