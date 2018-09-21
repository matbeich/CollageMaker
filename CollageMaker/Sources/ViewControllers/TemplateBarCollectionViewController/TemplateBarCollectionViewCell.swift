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

        contentView.addSubview(imageView)

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

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

            CollageRenderer.renderImage(from: collage, with: size) { image in
                self.imageView.image = image
            }
        }
    }

    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }
    }

    private let imageView = UIImageView()
}
