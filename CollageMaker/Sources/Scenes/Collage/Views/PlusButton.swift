//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class PlusButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(plusView)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.size.width, bounds.size.height) / 2
        plusView.center = bounds.center
        plusView.bounds.size = bounds.size.applying(CGAffineTransform(scaleX: 0.3, y: 0.3))
    }

    private func setup() {
        backgroundColor = .brightLavender
    }

    private let plusView = PlusView(frame: .zero, color: .white)
}
