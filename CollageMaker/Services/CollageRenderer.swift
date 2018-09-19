//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class CollageRenderer {
    
    static func renderImage(from collage: Collage, with size: CGSize, callback: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
             let image = (renderImage(from: collage, with: size))
            
            DispatchQueue.main.async {
                callback(image)
            }
        }
    }
    
    static func renderImage(from collage: Collage, with size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            collage.cells.forEach { render(cell: $0, in: context) }
            UIColor.collageBorder.setStroke()
            context.stroke(CGRect(origin: .zero, size: size))
        }
    }
    
    private static func render(cell: CollageCell, in context: UIGraphicsRendererContext) {
        let rect = cell.relativeFrame.absolutePosition(in: context.format.bounds)
        
        if let image = cell.image?.updateImageOrientionUpSide(), let cropedImage = cropImage(image, toRect: cell.imageVisibleRect) {
            cropedImage.draw(in: rect)
        } else {
            cell.color.setFill()
            context.fill(rect)
        }
    }
    
    private static func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect) -> UIImage? {
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropRect) else {
            return nil
        }
    
        return UIImage(cgImage: cutImageRef)
    }
}

extension UIImage {
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        draw(in: CGRect(origin: .zero, size: size))
        
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        
        return nil
    }
}
