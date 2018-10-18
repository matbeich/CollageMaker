//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class TemplatesContainerView: UIView {
    var withHeader: Bool {
        return headerLabel.text != nil
    }

    init(frame: CGRect = .zero, headerText: String? = nil) {
        super.init(frame: frame)

        headerLabel.text = headerText
        headerLabel.textColor = .white

        addSubview(dimmingView)
        addSubview(headerLabel)
        addSubview(contentView)

        makeConstraints()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setHeaderText(_ text: String?) {
        headerLabel.text = text
        makeConstraints()
    }

    private func makeConstraints() {
        let offset = 20

        dimmingView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }

        if withHeader {
            headerLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(offset)
                make.right.equalToSuperview().offset(-offset)
                make.top.equalToSuperview()
                make.height.equalTo(50)
            }
        }

        contentView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(withHeader ? offset : 0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setup() {
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0.8
        accessibilityIdentifier = Accessibility.View.templateView.id

        headerLabel.font = R.font.sfProDisplaySemibold(size: 20)
    }

    private let dimmingView = UIView()
    private let headerLabel = AttributedTextLabel()
    private(set) var contentView = UIView()
}
