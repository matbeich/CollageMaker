//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation

class BundleForTests {}

extension Bundle {
    static var test: Bundle {
        return Bundle(for: BundleForTests.self)
    }
}
