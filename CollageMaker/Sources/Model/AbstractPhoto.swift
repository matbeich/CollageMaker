//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit

struct AbstractPhoto {
    var photo: UIImage?
    var asset: PHAsset?

    init(photo: UIImage?, asset: PHAsset? = nil) {
        self.photo = photo
        self.asset = asset
    }
}
