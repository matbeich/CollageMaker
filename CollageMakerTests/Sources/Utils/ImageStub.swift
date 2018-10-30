//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

extension UIImage {
    static var testing: UIImage? {
        return UIImage(named: "test_img", in: Bundle.test, compatibleWith: nil)
    }

    static var testingHQ: UIImage? {
        return UIImage(named: "test_img_hq", in: Bundle.test, compatibleWith: nil)
    }
}
