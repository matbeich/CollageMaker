//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class CollageRenderer {
    func renderImage(from collage: Collage, with size: CGSize, callback: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            let image = self?.renderImage(from: collage, with: size, borders: true)
            DispatchQueue.main.async { callback(image) }
        }
    }

    func renderImage(from collage: Collage, with size: CGSize, borders: Bool) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            collage.cells.forEach { render(cell: $0, in: context, border: borders) }
        }
    }

    private func render(cell: CollageCell, in context: UIGraphicsRendererContext, border: Bool) {
        let rect = cell.relativeFrame.absolutePosition(in: context.format.bounds)

        if let image = cell.image?.updateImageOrientionUpSide(), let cropedImage = cropImage(image, toRect: cell.imageVisibleRect) {
            cropedImage.draw(in: rect)
        } else {
            cell.color.setFill()
            context.fill(rect)
        }

        if border {
            UIColor.clear.setStroke()
            context.stroke(rect) }
    }

    private func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect) -> UIImage? {
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: cutImageRef)
    }
}
