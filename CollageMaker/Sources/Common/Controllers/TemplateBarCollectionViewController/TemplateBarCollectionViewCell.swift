//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class TemplateBarCollectionViewCell: UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }

    var collageImage: UIImage? {
        didSet {
            update()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        contentView.addSubview(imageView)
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        collageImage = nil
        imageView.image = nil
    }

    func update() {
        layer.opacity = 0

        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.imageView.image = self?.collageImage
            self?.layer.opacity = 1.0
        }
    }

    func setupIdentifier(with value: Int) {
        accessibilityIdentifier = Accessibility.View.templateCell(id: value).id
    }

    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private let imageView = UIImageView()
}
