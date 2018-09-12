//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import SnapKit

class CollageCellView: UIView {
    
    init(collageCell: CollageCell, frame: CGRect) {
        self.collageCell = collageCell
        super.init(frame: frame)
        
        setupView()
        updateView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        updateView()
    }
    
    func changeFrame(to: CGRect) {
        self.frame = to
    }
    
    func updateCollageCell(_ collageCell: CollageCell) {
        self.collageCell = collageCell
        
        setupView()
    }

    private func setupView() {
        if let image = collageCell.image {
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
        } else {
            backgroundColor = collageCell.color
        }
    }
    
    private var imageVisibleRect: CGRect {
        return convert(scrollView.frame, to: imageView)
    }
    
    func saveVisibleRect() {
        collageCell.imageVisibleRect = imageVisibleRect
    }
    
    private func updateView() {
        guard let image = collageCell.image else {
            return
        }
        
        let widthScale = scrollView.frame.width / image.size.width
        let heightScale = scrollView.frame.height / image.size.height
        let minScale = max(widthScale, heightScale)
        scrollView.centerImage()
        
        setupScrollView(maxZoomScale: minScale * 2, minZoomScale: minScale)
        
        if collageCell.imageVisibleRect != .zero {
            let scale = bounds.height / collageCell.imageVisibleRect.height
            let imageScale = image.size.width / imageVisibleRect.width
            let contentOffset = CGPoint(x: collageCell.imageVisibleRect.origin.x * scale,
                                        y: collageCell.imageVisibleRect.origin.y * scale)
            
            scrollView.setZoomScale(imageScale, animated: false)
            scrollView.contentOffset = contentOffset
        } else {
            scrollView.setZoomScale(minScale, animated: false)
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
    private(set) var collageCell: CollageCell
}

extension CollageCellView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}
