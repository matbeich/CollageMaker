//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class ShareButton: UIControl {
    init(shareDestination: ShareDestination) {
        self.destination = shareDestination
        super.init(frame: .zero)

        addSubview(stackView)
        setup()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        switch destination {
        case .photos:
            accessibilityIdentifier = Accessibility.Button.photosButton.id
            imageView.image = R.image.save_btn()
            titleLabel.text = "save".uppercased()
        case .messages:
            accessibilityIdentifier = Accessibility.Button.messagesButton.id
            imageView.image = R.image.imessage_btn()
            titleLabel.text = "iMESSAGE"
        case .instagram:
            accessibilityIdentifier = Accessibility.Button.instagramButton.id
            imageView.image = R.image.inst_btn()
            titleLabel.text = "instagram".uppercased()
        case .other:
            accessibilityIdentifier = Accessibility.Button.otherButton.id
            imageView.image = R.image.other_btn()
            titleLabel.text = "other".uppercased()
        }

        titleLabel.font = R.font.sfCompactDisplayMedium(size: 12)
        titleLabel.textAlignment = .center

        imageView.contentMode = .scaleAspectFit
    }

    private func makeConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(imageView.snp.width)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else {
                    return
                }

                self.layer.opacity = self.isHighlighted ? 0.5 : 1 }
        }
    }

    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.spacing = 12

        return stackView
    }()

    let destination: ShareDestination
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
}
