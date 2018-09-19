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

    var photoAsset: PHAsset? {
        didSet {
            update()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

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

    func toogleSelection() {
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
        if let asset = photoAsset {
            PhotoLibraryService.photo(from: asset, deliveryMode: .opportunistic, size: CGSize(width: 300, height: 300)) { [weak self] image in
                self?.imageView.image = image
            }
        }
    }

    private let imageView = UIImageView()
    private lazy var selectionView = SelectionView()
}
