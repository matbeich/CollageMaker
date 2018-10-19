//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class CollageBarButtonItem: UIControl {
    override var isHighlighted: Bool {
        didSet {
            layer.opacity = isHighlighted ? 0.5 : 1
        }
    }

    let title: String
    let normalStateImage: UIImage
    let tappedStateImage: UIImage

    init(title: String, image: UIImage, tappedImage: UIImage? = nil, action: Selector? = nil) {
        self.title = title
        self.normalStateImage = image
        //        addTarget(self, action: action?, for: .touchUpInside)

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
    static var horizontal: CollageBarButtonItem {
        return CollageBarButtonItem(title: "HORIZONTAL", image: R.image.horizontal() ?? .none)
    }

    static var vertical: CollageBarButtonItem {
        return CollageBarButtonItem(title: "VERTICAL", image: R.image.vertical() ?? .none)
    }

    static var addImage: CollageBarButtonItem {
        return CollageBarButtonItem(title: "ADD IMG", image: R.image.addimg() ?? .none)
    }

    static var delete: CollageBarButtonItem {
        return CollageBarButtonItem(title: "DELETE", image: R.image.addimg() ?? .none)
    }
}

extension UIImage {
    static var none: UIImage {
        return UIImage()
    }
}
