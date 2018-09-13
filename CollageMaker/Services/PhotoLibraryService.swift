//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos

final class PhotoLibraryService {
    
    static func getImagesAssets() -> [PHAsset] {
        var assets = [PHAsset]()
        
        let options = PHFetchOptions()
        
        options.includeAssetSourceTypes = .typeUserLibrary
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        
        let imageFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        
        imageFetchResult.enumerateObjects { (object, _, _) in
            assets.append(object)
        }
        
        return assets
    }
    
    static func cacheImages(for assets: [PHAsset]) {
        imageCacher.startCachingImages(for: assets, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil)
    }
    
    static func photo(for asset: PHAsset, size: CGSize?, callback: @escaping (UIImage?) -> Void) {
        let sizeForTarget = size == nil ? CGSize(width: asset.pixelWidth, height: asset.pixelHeight) : size
        
        guard let targetSize = sizeForTarget else {
            callback(nil)
            return
        }
        
        manager.requestImage(for: asset,
                             targetSize: targetSize ,
                             contentMode: .default,
                             options: nil) {  (image, _) in callback(image) }
    }
    
    private static let imageCacher = PHCachingImageManager()
    private static let manager = PHImageManager.default()
}
