//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation

struct Config {
    let numberOfCells: Int

    init(numberOfCells: Int) {
        self.numberOfCells = numberOfCells
    }
}

extension Config {
    static let `default` = Config(numberOfCells: 9)
}
