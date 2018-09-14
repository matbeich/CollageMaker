//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos

class CollageTemplateProvider {
    
    static func collage(for assets: [PHAsset], callback: @escaping (Collage?) -> Void) {
        
        guard assets.count == 1 else {
            callback(nil)
            return
        }
        
        assets.forEach {
            PhotoLibraryService.photo(for: $0, size: CGSize(width: 300, height: 300)) { image in
    
                let collage = Collage(cells: [CollageCell(color: .clear, image: image, relativeFrame: .fullsized)])
                
                callback(collage)
            }
        }
        
    }
    
}
