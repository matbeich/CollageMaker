//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import UIKit

class MockCollageRenderer: CollageRendererType {
    func renderAsyncImage(from collage: Collage, with size: CGSize, borders: Bool, callback: @escaping (UIImage?) -> Void) {
        callback(UIImage.test)
    }

    func renderImage(from collage: Collage, with size: CGSize, borders: Bool) -> UIImage {
        return UIImage.test ?? UIImage()
    }
}
