//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation

class BundleStub {}

extension Bundle {
    static var test: Bundle {
        return Bundle(for: BundleStub.self)
    }
}
