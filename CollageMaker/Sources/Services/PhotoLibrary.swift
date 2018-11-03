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

protocol PhotoLibraryType: AnyObject {
    typealias PhotoCompletion = (UIImage?) -> Void
    typealias PhotosCompletion = ([UIImage]) -> Void

    var assets: [PHAsset] { get }
    var delegate: PhotoLibraryDelegate? { get set }

    func stopCaching()
    func cacheImages(with assets: [PHAsset])
    func assetFor(localIdentifier: String) -> PHAsset?
    func add(_ image: UIImage, callback: @escaping (Bool, PHAsset?) -> Void)
    func photo(with asset: PHAsset, deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize?, callback: @escaping PhotoCompletion)
    func collectPhotos(from assets: [PHAsset], deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize, callback: @escaping PhotosCompletion)
}

final class PhotoLibrary: NSObject, PhotoLibraryType {
    weak var delegate: PhotoLibraryDelegate?

    init(library: PHPhotoLibrary = .shared(), imageCacher: PHCachingImageManager = .shared) {
        self.library = library
        self.imageCacher = imageCacher
        super.init()

        fetchImagesAssets()
        observeAssets()
    }

    func assetFor(localIdentifier: String) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
    }

    func add(_ image: UIImage, callback: @escaping (Bool, PHAsset?) -> Void) {
        var placeholder = PHObjectPlaceholder()

        let changeBlock = {
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let addAssetRequest = PHAssetCollectionChangeRequest(for: PHAssetCollection())

            guard let assetPaceholder = creationRequest.placeholderForCreatedAsset else {
                callback(false, nil)
                return
            }

            placeholder = assetPaceholder
            addAssetRequest?.addAssets([placeholder] as NSArray)
        }

        library.performChanges(changeBlock) { success, _ in
            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject

            DispatchQueue.main.async { callback(success, asset) }
        }
    }

    func cacheImages(with assets: [PHAsset]) {
        imageCacher.startCachingImages(for: assets, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil)
    }

    func stopCaching() {
        imageCacher.stopCachingImagesForAllAssets()
    }

    func photo(with asset: PHAsset, deliveryMode: PHImageRequestOptionsDeliveryMode, size: CGSize? = nil, callback: @escaping PhotoCompletion) {
        let sizeForTarget = size ?? CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        let options = PHImageRequestOptions()

        options.deliveryMode = deliveryMode
        options.resizeMode = .exact

        PHImageManager.default().requestImage(for: asset,
                                              targetSize: sizeForTarget,
                                              contentMode: .default,
                                              options: options) { image, _ in callback(image)
        }
    }

    func collectPhotos(from assets: [PHAsset], deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat, size: CGSize, callback: @escaping PhotosCompletion) {
        let group = DispatchGroup()
        var photos: [UIImage?] = Array(repeating: nil, count: assets.count)

        for (index, asset) in assets.enumerated() {
            group.enter()
            photo(with: asset, deliveryMode: deliveryMode, size: size) { photo in
                photos[index] = photo
                group.leave()
            }
        }

        group.notify(queue: .main) {
            callback(photos.compactMap { $0 })
        }
    }

    private func fetchImagesAssets(count: Int = 0) {
        assets.removeAll()
        let options = PHFetchOptions()

        options.includeAssetSourceTypes = .typeUserLibrary
        options.fetchLimit = count

        assetsFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        assetsFetchResult.enumerateObjects { [weak self] object, _, _ in
            self?.assets.append(object)
        }
    }

    private func observeAssets() {
        library.register(self)
    }

    private func updateAssets(with changeDetails: PHFetchResultChangeDetails<PHAsset>) {
        changeDetails.removedObjects.forEach { asset in assets = assets.filter { $0 != asset } }
        assets.append(contentsOf: changeDetails.insertedObjects)
    }

    private(set) var assets = [PHAsset]()
    private let imageCacher: PHCachingImageManager
    private let library: PHPhotoLibrary
    private var assetsFetchResult = PHFetchResult<PHAsset>()
}

extension PhotoLibrary: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changeDetails = changeInstance.changeDetails(for: assetsFetchResult) else {
            return
        }

        if changeDetails.hasIncrementalChanges {
            assetsFetchResult = changeDetails.fetchResultAfterChanges
            updateAssets(with: changeDetails)
        } else {
            fetchImagesAssets()
        }

        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }

            if changeDetails.hasIncrementalChanges {
                self.delegate?.photoLibrary(self, didInsertAssets: changeDetails.insertedObjects)
                self.delegate?.photoLibrary(self, didRemoveAssets: changeDetails.removedObjects)
            } else {
                self.delegate?.photoLibrary(self, didUpdateAssets: self.assets)
            }
        }
    }
}

private extension PHCachingImageManager {
    static let shared = PHCachingImageManager()
}
