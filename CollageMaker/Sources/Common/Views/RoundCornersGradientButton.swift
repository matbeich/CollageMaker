//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

class RoundCornersGradientButton: UIControl {
    var contentEdgeInsets: UIEdgeInsets? {
        didSet {
            updateConstraints(for: contentEdgeInsets)
        }
    }

    var spacing: CGFloat = 0 {
        didSet {
        }
    }

    var showShadow: Bool = true {
        didSet {
            layer.shadowOpacity = showShadow ? 0.3 : 0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)

        setup()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let width = titleLabel.bounds.width + imageView.bounds.width
        let height = max(titleLabel.bounds.height, imageView.bounds.height)

        return CGSize(width: width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        tintColor = .white
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = min(bounds.height, bounds.width) / 2
        maskRect(size: bounds.size)
    }

    private func setup() {
        layer.addSublayer(gradientLayer)
        layer.insertSublayer(imageView.layer, above: gradientLayer)
        layer.insertSublayer(titleLabel.layer, above: imageView.layer)

        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.brightLavender.cgColor
        layer.shadowOpacity = 0.3
    }

    private func maskRect(size: CGSize) {
        let cornersPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: size)
        let maskLayer = CAShapeLayer()

        maskLayer.path = cornersPath.cgPath
        maskLayer.frame = bounds

        layer.mask = maskLayer
    }

    private func makeConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(titleLabel.snp.width)
        }

        imageView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right)
        }
    }

    private func updateConstraints(for edgeInsets: UIEdgeInsets?) {
        guard let edgeInsets = edgeInsets else {
            return
        }

        contentView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(edgeInsets.top)
            make.bottom.equalToSuperview().offset(-edgeInsets.bottom)
            make.left.equalToSuperview().offset(edgeInsets.left)
            make.right.equalToSuperview().offset(-edgeInsets.right)
        }
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    func setTitle(_ title: String?) {
        titleLabel.text = title
    }

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.setAxis(.horizontal)
        layer.colors = [UIColor.brightLavender.cgColor, UIColor.collagePink.cgColor]

        return layer
    }()

    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let contentView = UIView()
}
