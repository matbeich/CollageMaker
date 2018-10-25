//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

enum ShareDestination: String {
    case photos
    case messages
    case instagram
    case other
}

protocol ShareToolbarDelegate: AnyObject {
    func shareToolbar(_ shareToolbar: ShareToolbar, didSelectDestination destination: ShareDestination)
}

class ShareToolbar: UIView {
    weak var delegate: ShareToolbarDelegate?

    var isEnabled: Bool = true {
        didSet {
            buttons.forEach {
                $0.isEnabled = isEnabled
                $0.layer.opacity = isEnabled ? 1.0 : 0.5
            }
        }
    }

    init(destinations: [ShareDestination]) {
        self.destinations = destinations
        super.init(frame: .zero)

        addSubview(buttonsStackView)
        makeConstraints()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    @objc private func tapped(with button: ShareButton) {
        delegate?.shareToolbar(self, didSelectDestination: button.destination)
    }

    private func makeConstraints() {
        buttonsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setup() {
        buttons.forEach { $0.addTarget(self, action: #selector(tapped(with:)), for: .touchUpInside) }
        isEnabled = false
    }

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .equalSpacing

        return stackView
    }()

    private lazy var buttons: [ShareButton] = {
        destinations.map { ShareButton(shareDestination: $0) }
    }()

    private let destinations: [ShareDestination]
}
