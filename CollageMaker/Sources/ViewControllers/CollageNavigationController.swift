//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class CollageNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = .white
        navigationBar.tintColor = .black
        navigationBar.setValue(true, forKey: "hidesShadow")
    }

    func setup() {
    }
}
