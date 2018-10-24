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

    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)

        if let imageView = imageView {
            bringSubview(toFront: imageView)
            contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
            imageEdgeInsets.left = 2
            titleEdgeInsets.right = 2
        }
    }

    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)

        titleWidth = titleLabel?.text?.size(withAttributes: [.font: titleLabel?.font as Any]).width ?? 0
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)

        guard let imageWidth = image(for: state)?.size.width else {
            return rect
        }

        let leftInset = max(titleEdgeInsets.left, contentEdgeInsets.left)
        let rightInset = max(imageEdgeInsets.right, contentEdgeInsets.right)

        let x = max(contentRect.width - imageWidth - rightInset + imageEdgeInsets.left, leftInset + titleWidth + titleEdgeInsets.right)

        return CGRect(x: x,
                      y: rect.origin.y,
                      width: imageWidth,
                      height: rect.height)
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        let textWidth = max(titleWidth, rect.width)
        let leftInset = contentHorizontalAlignment == .center ? (contentRect.width / 2 - textWidth / 2) : max(titleEdgeInsets.left, contentEdgeInsets.left)

        return CGRect(x: leftInset - titleEdgeInsets.right,
                      y: rect.origin.y,
                      width: textWidth,
                      height: rect.height)
    }

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.setAxis(.horizontal)
        layer.colors = [UIColor.brightLavender.cgColor, UIColor.collagePink.cgColor]

        return layer
    }()

    private var titleWidth: CGFloat = 0
}
