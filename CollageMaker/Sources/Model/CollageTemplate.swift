//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos

struct CollageTemplate {
    init(frames: [RelativeFrame], assets: [PHAsset] = []) {
        self.cellFrames = frames
        self.assets = assets
    }

    let cellFrames: [RelativeFrame]
    let assets: [PHAsset]
}
