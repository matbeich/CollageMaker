//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class GripView: UIView {
    init(with position: GripPosition) {
        self.position = position
        super.init(frame: .zero)

        backgroundColor = .brightLavender
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented ")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(frame.height, frame.width) / 2
    }

    private(set) var position: GripPosition
}
