//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class CollageCellView: UIView {
    var selected: Bool = false {
        didSet {
            if selected {
                backgroundColor = .brightLavender
                imageView.layer.opacity = 0.5
            } else {
                backgroundColor = nil
                imageView.layer.opacity = 1.0
            }
        }
    }

    var collageCell: CollageCell
    var imageVisibleRect: CGRect {
        return convert(scrollView.frame, to: imageView)
    }

    init(collageCell: CollageCell = .zeroFrame, frame: CGRect = .zero) {
        self.collageCell = collageCell
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame = bounds
        updateScrollView()
    }

    func changeFrame(for parentRect: CGRect) {
        self.frame = collageCell.relativeFrame.absolutePosition(in: parentRect)
    }

    func updateCollageCell(_ collageCell: CollageCell) {
        self.collageCell = collageCell
        updateScrollView()
    }

    private func setup() {
        updateImageView()
        updateScrollView()
    }

    private func updateImageView() {
        guard let image = collageCell.image else {
            backgroundColor = collageCell.color
            return
        }

        imageView.image = nil
        imageView.removeFromSuperview()
        scrollView.removeFromSuperview()

        imageView = UIImageView(image: image)

        scrollView.frame = bounds
        scrollView.contentSize = image.size
        scrollView.addSubview(imageView)
        scrollView.delegate = self

        addSubview(scrollView)
        backgroundColor = .clear
    }

    private func updateScrollView() {
        guard let image = collageCell.image else {
            return
        }

        let widthScale = scrollView.frame.width / image.size.width
        let heightScale = scrollView.frame.height / image.size.height
        let fitScale = max(widthScale, heightScale)

        setupScrollView(maxZoomScale: fitScale * 3, minZoomScale: fitScale)

        if collageCell.imageVisibleFrame != .zero {
            let scale = bounds.height / collageCell.imageVisibleFrame.height

            let rect = CGRect(x: collageCell.imageVisibleFrame.origin.x * scale,
                              y: collageCell.imageVisibleFrame.origin.y * scale,
                              width: collageCell.imageVisibleFrame.width * scale,
                              height: collageCell.imageVisibleFrame.height * scale)

            scrollView.setZoomScale(scale, animated: false)
            scrollView.centerAtPoint(p: rect.center)
        } else {
            scrollView.setZoomScale(fitScale, animated: false)
            scrollView.centerImage()
        }
    }

    private func setupScrollView(maxZoomScale: CGFloat = 1, minZoomScale: CGFloat = 1) {
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.minimumZoomScale = minZoomScale
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
    }

    private lazy var imageView = UIImageView()
    private lazy var scrollView = UIScrollView()
}

extension CollageCellView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
