//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class TemplateBarCollectionViewCell: UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }

    var collageTemplate: CollageTemplate? {
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

        imageView.image = nil
        collageTemplate = nil
    }

    func update() {
        guard let collageTemplate = collageTemplate else {
            return
        }

        let size = bounds.size

        CollageTemplateProvider.collage(from: collageTemplate, size: .medium) { collage in

            let collageView = CollageView(frame: CGRect(origin: .zero, size: size))
            collageView.updateCollage(collage)
            collageView.saveCellsVisibleRect()

            CollageRenderer.renderImage(from: collage, with: size) { [weak self] image in
                guard let properCollageTemplate = self?.collageTemplate, properCollageTemplate == collageTemplate else {
                    return
                }

                self?.layer.opacity = 0.0
                self?.imageView.image = image

                UIView.animate(withDuration: 0.5) { self?.layer.opacity = 1.0 }
            }
        }
    }

    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private let imageView = UIImageView()
}
