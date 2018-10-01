//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

enum ShareDestination {
    case photos
    case messages
    case instagram
    case other
}

class ShareToolbar: UIView {
    init(destinations: [ShareDestination]) {
        self.destinations = destinations
        super.init(frame: .zero)

        addSubview(buttonsStackView)
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    private func makeConstraints() {
        buttonsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually

        return stackView
    }()

    private lazy var buttons: [ShareButton] = {
        destinations.map { ShareButton(shareDestination: $0) }
    }()

    private let destinations: [ShareDestination]
}
