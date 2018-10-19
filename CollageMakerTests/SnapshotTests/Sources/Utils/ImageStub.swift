//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

extension UIImage {
    static var test: UIImage? {
        return UIImage(named: "test_img.png", in: Bundle.test, compatibleWith: nil)
    }
}
