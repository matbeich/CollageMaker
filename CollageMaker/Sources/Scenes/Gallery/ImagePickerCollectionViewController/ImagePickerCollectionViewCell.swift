//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import SnapKit
import UIKit

class ImagePickerCollectionViewCell: UICollectionViewCell {
    var cellSelected: Bool = false {
        didSet {
            if cellSelected {
                showSelectionView()
                imageView.layer.opacity = 0.5
            } else {
                hideSelectionView()
                imageView.layer.opacity = 1
            }
        }
    }

    var image: UIImage? {
        didSet {
            update()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .brightLavender
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    static var identifier: String {
        return String(describing: self)
    }

    func toggleSelection() {
        cellSelected = !cellSelected
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        cellSelected = false
    }

    private func showSelectionView() {
        addSubview(selectionView)

        let offset = bounds.height / 18.4

        selectionView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(offset)
            make.right.equalToSuperview().offset(-offset)
            make.size.equalToSuperview().dividedBy(4.84)
        }
    }

    private func hideSelectionView() {
        selectionView.removeFromSuperview()
    }

    private func update() {
        imageView.image = image
    }

    private let imageView = UIImageView()
    private lazy var selectionView = SelectionView()
}

extension CGSize {
    func sameAspectScaled(by multiplier: CGFloat) -> CGSize {
        return CGSize(width: width * multiplier, height: height * multiplier)
    }
}
