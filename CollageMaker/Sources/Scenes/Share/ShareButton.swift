//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class ShareButton: UIControl {
    init(shareDestination: ShareDestination) {
        self.destination = shareDestination
        super.init(frame: .zero)

        addSubview(imageView)
        addSubview(titleLabel)

        setup()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        switch destination {
        case .photos:
            imageView.image = R.image.save_btn()
            titleLabel.text = "save image".uppercased()
        case .messages:
            imageView.image = R.image.imessage_btn()
            titleLabel.text = "imessage".uppercased()
        case .instagram:
            imageView.image = R.image.inst_btn()
            titleLabel.text = "instagram".uppercased()
        case .other:
            imageView.image = R.image.other_btn()
            titleLabel.text = "other".uppercased()
        }

        titleLabel.font = R.font.sfProDisplaySemibold(size: 13)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
    }

    private func makeConstraints() {
        let offset = 10

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(offset)
            make.height.equalTo(titleLabel.font.lineHeight)
        }
    }

    let destination: ShareDestination
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
}
