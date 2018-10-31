//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class CollageBarButtonItem: UIControl {
    override var isHighlighted: Bool {
        didSet {
            layer.opacity = isHighlighted ? 0.5 : 1
            imageView.image = isHighlighted ? tappedStateImage : normalStateImage
        }
    }

    let title: String
    let normalStateImage: UIImage
    let tappedStateImage: UIImage

    init(title: String, image: UIImage, tappedImage: UIImage? = nil) {
        self.title = title
        self.normalStateImage = image

        if let tappedImage = tappedImage {
            self.tappedStateImage = tappedImage
        } else {
            self.tappedStateImage = image
        }

        super.init(frame: .zero)

        addSubview(stackView)
        setup()
        makeConstraints()
    }

    convenience init(collageItem: CollageItem) {
        self.init(title: collageItem.title, image: collageItem.image, tappedImage: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        imageView.image = normalStateImage
        imageView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.letterSpacing = 0.3
        titleLabel.textAlignment = .center
        titleLabel.font = R.font.sfuiDisplayMedium(size: 12)
        titleLabel.adjustsFontSizeToFitWidth = true
    }

    private func makeConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.width.equalTo(25)
            make.height.equalTo(imageView.snp.width)
        }
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.spacing = 5

        return stackView
    }()

    private let titleLabel = AttributedTextLabel()
    private let imageView = UIImageView()
}

extension CollageBarButtonItem {
    enum CollageItem {
        case horizontal
        case vertical
        case delete
        case addImage

        var title: String {
            switch self {
            case .horizontal: return "HORIZONTAL"
            case .vertical: return "VERTICAL"
            case .addImage: return "ADD IMG"
            case .delete: return "DELETE"
            }
        }

        var image: UIImage {
            switch self {
            case .horizontal: return R.image.horizontal_trim() ?? .none
            case .vertical: return R.image.vertical_trim() ?? .none
            case .addImage: return R.image.pic_icon_() ?? .none
            case .delete: return R.image.pic_icon_() ?? .none
            }
        }
    }
}

extension UIImage {
    static var none: UIImage {
        return UIImage()
    }
}
