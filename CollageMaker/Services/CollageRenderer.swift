//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class CollageRenderer {
    
    static func renderImage(from collage: Collage, with size: CGSize, callback: (UIImage) -> Void) {
        callback(renderImage(from: collage, with: size))
    }
    
    static func renderImage(from collage: Collage, with size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            collage.cells.forEach { render(cell: $0, in: context) }
        }
    }
    
    private static func render(cell: CollageCell, in context: UIGraphicsRendererContext) {
        let rect = cell.relativeFrame.absolutePosition(in: context.format.bounds)
        
        if let image = cell.image, let cropedImage = cropImage(image, toRect: cell.imageVisibleRect) {
            cropedImage.draw(in: rect)
        } else {
            cell.color.setFill()
            context.fill(rect)
        }
        
        UIColor.collageBorder.setStroke()
        context.stroke(rect)
    }
    
    private static func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect) -> UIImage? {
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: cutImageRef)
    }
}
