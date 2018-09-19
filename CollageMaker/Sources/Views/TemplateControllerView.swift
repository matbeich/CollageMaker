//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class TemplateControllerView: UIView {
    var withHeader: Bool {
        return headerLabel.text != nil
    }

    init(frame: CGRect = .zero, headerText: String? = nil) {
        super.init(frame: frame)

        headerLabel.text = headerText
        headerLabel.textColor = .white

        addSubview(dimmingView)
        addSubview(headerLabel)
        addSubview(templateContainerView)

        makeConstraints()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeConstraints() {
        let offset = 20

        dimmingView.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }

        if withHeader {
            headerLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(offset)
                make.right.equalToSuperview().offset(-offset)
                make.top.equalToSuperview()
                make.height.equalTo(50)
            }
        }

        templateContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(withHeader ? offset : 0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setup() {
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0.8
    }

    private let dimmingView = UIView()
    private let headerLabel = AttributedTextLabel()
    private(set) var templateContainerView = UIView()
}
