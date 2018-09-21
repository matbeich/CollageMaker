//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import UIKit

class GradientButton: UIButton {
    var showShadow: Bool = true {
        didSet {
            layer.shadowOpacity = showShadow ? 0.3 : 0
        }
    }

    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)

        if let imageView = imageView {
            bringSubview(toFront: imageView)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(gradientLayer)
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.brightLavender.cgColor
        layer.shadowOpacity = 0.3

        contentHorizontalAlignment = .center

        setTitleColor(.white, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        tintColor = .white
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = min(bounds.height, bounds.width) / 2
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)

        guard let imageWidth = image(for: state)?.size.width else {
            return rect
        }

        contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

        guard let titleWidth = titleLabel?.text?.size(withAttributes: [NSAttributedStringKey.font: titleLabel?.font as Any]).width else {
            return rect
        }

        let leftInset = max(titleEdgeInsets.left, contentEdgeInsets.left)
        let rightInset = max(titleEdgeInsets.left, contentEdgeInsets.left)

        let x = max(contentRect.width - imageWidth - rightInset, leftInset + titleWidth + titleEdgeInsets.right)

        return CGRect(x: x,
                      y: rect.origin.y,
                      width: imageWidth,
                      height: rect.height)
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        let size = rect.width

        let leftInset = contentVerticalAlignment == .center ? (contentRect.width / 2 - size / 2) : max(titleEdgeInsets.left, contentEdgeInsets.left)

        return CGRect(x: leftInset,
                      y: rect.origin.y,
                      width: size,
                      height: rect.height)
    }

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.setAxis(.horizontal)
        layer.colors = [UIColor.brightLavender.cgColor, UIColor.collagePink.cgColor]

        return layer
    }()
}
