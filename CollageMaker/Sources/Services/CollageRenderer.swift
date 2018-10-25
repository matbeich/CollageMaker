//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class CollageRenderer {
    func renderAsyncImage(from collage: Collage, with size: CGSize, borders: Bool = true, callback: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            let image = self?.renderImage(from: collage, with: size, borders: borders)
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

        if let image = cell.image {
            draw(frame: cell.imageVisibleFrame, of: image, in: rect, in: context.cgContext)
        } else {
            cell.color.setFill()
            context.fill(rect)
        }

        if border {
            UIColor.clear.setStroke()
            context.stroke(rect)
        }
    }

    private func draw(frame part: CGRect, of image: UIImage, in rect: CGRect, in context: CGContext) {
        context.saveGState()
        context.addRect(rect)
        context.clip()

        let scale = min(rect.size.width / part.width, rect.size.height / part.height)
        let x = rect.origin.x - part.origin.x * scale
        let y = rect.origin.y - part.origin.y * scale

        let drawRect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: image.size.width * scale, height: image.size.height * scale))
        image.draw(in: drawRect)

        context.restoreGState()
    }
}
