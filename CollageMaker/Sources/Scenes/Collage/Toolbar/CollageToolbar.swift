//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

protocol CollageToolbarDelegate: AnyObject {
    func collageToolbar(_ collageToolbar: CollageToolbar, itemTapped: CollageBarButtonItem)
}

class CollageToolbar: UIView {
    weak var delegate: CollageToolbarDelegate?

    convenience init(frame: CGRect = .zero, barItems: [CollageBarButtonItem]) {
        self.init(frame: frame)

        barItems.forEach { addCollageBarItem($0) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))

        addSubview(buttonsStackView)
        addGestureRecognizer(tapGestureRecognizer)

        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    func addCollageBarItem(_ item: CollageBarButtonItem) {
        item.tag = buttonsStackView.arrangedSubviews.count
        buttonsStackView.addArrangedSubview(item)
    }

    private func makeConstraints() {
        buttonsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
    }

    @objc private func itemTapped(_ recoginzer: UITapGestureRecognizer) {
        let point = recoginzer.location(in: self)

        guard let item = itemForPoint(point) else {
            return
        }

        delegate?.collageToolbar(self, itemTapped: item)
    }

    private func itemForPoint(_ point: CGPoint) -> CollageBarButtonItem? {
        return buttonsStackView.arrangedSubviews.first(where: { $0.frame.contains(point) }) as? CollageBarButtonItem
    }

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5

        return stackView
    }()

    private lazy var tapGestureRecognizer = UITapGestureRecognizer()
}

extension CollageToolbar {
    static var standart: CollageToolbar {
        let horizontal = CollageBarButtonItem(collageItem: .horizontal)
        let vertical = CollageBarButtonItem(collageItem: .vertical)
        let addimg = CollageBarButtonItem(collageItem: .addImage)
        let delete = CollageBarButtonItem(collageItem: .delete)

        horizontal.accessibilityIdentifier = Accessibility.Button.horizontalButton.id
        vertical.accessibilityIdentifier = Accessibility.Button.verticalButton.id
        addimg.accessibilityIdentifier = Accessibility.Button.addImageButton.id
        delete.accessibilityIdentifier = Accessibility.Button.deleteButton.id

        return CollageToolbar(barItems: [horizontal, vertical, addimg, delete])
    }
}
