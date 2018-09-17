//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos

class CollageTemplateProvider {
    
    
    static func templates(for assets: [PHAsset], callback: @escaping ([Collage]?) -> Void) {
        PhotoLibraryService.cacheImages(for: assets)
        
        var collages: [Collage] = []
        
        switch assets.count {
        case 2:
            collages = Collage.templatesTwoCells()
        case 3:
            collages = Collage.templatesThreeCells()
        default:
            callback(nil)
            break
        }
        
        collectPhotos(from: assets, deliveryMode: .fastFormat) { images in
            collages.forEach { collage in
                collage.fill(with: images)
            }
            callback(collages)
        }
    }
    
    static func highQualityCollage(from template: Collage, assets: [PHAsset], callback: @escaping (Collage) -> Void) {
        template.deleteImages()
        
        collectPhotos(from: assets) { images in
            template.fill(with: images)
            callback(template)
        }
    }
    
    static func collectPhotos(from assets: [PHAsset], deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat, callback: @escaping ([UIImage]) -> Void){
        photos.removeAll()
        
        assets.forEach { asset in
            PhotoLibraryService.photo(for: asset, deliveryMode: deliveryMode) { photo in
                guard let photo = photo  else {
                    return
                }
                
                photos.append(photo)
                if photos.count == assets.count { callback(photos) }
            }
        }
    }
    
    private static var photos: [UIImage] = []
}

fileprivate extension Collage {
    static func templatesTwoCells() -> [Collage] {
        let cell1 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0, width: 0.5, height: 1))
        let cell2 = CollageCell(relativeFrame: RelativeFrame(x: 0.5, y: 0, width: 0.5, height: 1))
        let cell3 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0, width: 1, height: 0.5))
        let cell4 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0.5, width: 1, height: 0.5))
        
        return [Collage(cells: [cell1, cell2]),
                Collage(cells: [cell3, cell4])]
    }
    
    static func templatesThreeCells() -> [Collage] {
        let cell1 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0, width: 0.5, height: 1))
        let cell2 = CollageCell(relativeFrame: RelativeFrame(x: 0.5, y: 0, width: 0.5, height: 0.5))
        let cell3 = CollageCell(relativeFrame: RelativeFrame(x: 0.5, y: 0.5, width: 0.5, height: 0.5))
        let cell4 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0, width: 0.5, height: 0.5))
        let cell5 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0.5, width: 0.5, height: 0.5))
        let cell6 = CollageCell(relativeFrame: RelativeFrame(x: 0.5, y: 0, width: 0.5, height: 1))
        let cell7 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0, width: 1, height: 0.5))
        let cell8 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0.5, width: 1, height: 0.5))
        let cell9 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0.5, width: 0.5, height: 0.5))
        let cell10 = CollageCell(relativeFrame: RelativeFrame(x: 0.5, y: 0.5, width: 0.5, height: 0.5))
        let cell11 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0, width: 0.5, height: 0.5))
        let cell12 = CollageCell(relativeFrame: RelativeFrame(x: 0.5, y: 0, width: 0.5, height: 0.5))
        let cell14 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0, width: 0.33, height: 1))
        let cell15 = CollageCell(relativeFrame: RelativeFrame(x: 0.33, y: 0, width: 0.33, height: 1))
        let cell16 = CollageCell(relativeFrame: RelativeFrame(x: 0.66, y: 0, width: 0.34, height: 1))
        let cell17 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0, width: 1, height: 0.33))
        let cell18 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0.33, width: 1, height: 0.33))
        let cell19 = CollageCell(relativeFrame: RelativeFrame(x: 0, y: 0.66, width: 1, height: 0.34))
        
        return [Collage(cells: [cell1, cell2, cell3]),
                Collage(cells: [cell4, cell5, cell6]),
                Collage(cells: [cell7, cell9, cell10]),
                Collage(cells: [cell8, cell11, cell12]),
                Collage(cells: [cell14, cell15, cell16]),
                Collage(cells: [cell17, cell18, cell19])]
    }
}