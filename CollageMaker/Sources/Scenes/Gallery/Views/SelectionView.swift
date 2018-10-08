//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class SelectionView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .brightLavender
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        confirmIconImageView.contentMode = .scaleAspectFit

        addSubview(confirmIconImageView)
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.size.height / 2
    }

    private func makeConstraints() {
        confirmIconImageView.snp.makeConstraints { make in
            make.size.equalToSuperview().dividedBy(2)
            make.center.equalToSuperview()
        }
    }

    private let confirmIconImageView = UIImageView(image: R.image.confirm_btn())
}
