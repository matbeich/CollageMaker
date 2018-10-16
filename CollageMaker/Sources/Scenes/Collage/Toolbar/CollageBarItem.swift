//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class CollageBarButtonItem: UIControl {
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.layer.opacity = self.isHighlighted ? 0.5 : 1 }
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

        addSubview(titleLabel)
        addSubview(imageView)

        setup()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        imageView.image = normalStateImage
        imageView.contentMode = .scaleAspectFit

        titleLabel.font = titleLabel.font.withSize(10.0)
        titleLabel.text = title
        titleLabel.textAlignment = .center
    }

    private func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.3)
            make.height.equalToSuperview().dividedBy(4)
        }

        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.top)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(imageView.snp.height)
        }
    }

    private let titleLabel = UILabel()
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
