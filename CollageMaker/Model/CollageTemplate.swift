//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos


struct CollageTemplate {
    let collage: Collage
    let photoAssets: [PHAsset]
    let size: Size
    
    init(collage: Collage, photoAssets: [PHAsset], size: Size) {
        self.collage = collage
        self.photoAssets = photoAssets
        self.size = size
    }
    
    enum Size {
        case small
        case medium
        case large
        
        var value: CGSize {
            switch self {
            case .small: return CGSize(width: 200, height: 200)
            case .medium: return CGSize(width: 500, height: 500)
            case .large: return CGSize(width: 1000, height: 1000)
            }
        }
    }
}
