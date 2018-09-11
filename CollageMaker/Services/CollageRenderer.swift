//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class CollageRenderer {
    
    static func renderImage(from collage: Collage, with size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            collage.cells.forEach { render(cell: $0, in: context) }
        }
    }
    
    private static func render(cell: CollageCell, in context: UIGraphicsRendererContext) {
        let rect = cell.relativeFrame.absolutePosition(in: context.format.bounds)
        
        if let image = cell.image, let croped = cropImage(image, toRect: cell.imageVisibleRect) {
            croped.draw(in: rect)
            print(rect)
        } else {
            cell.color.setFill()
            context.fill(rect)
        }
        
        UIColor.collageBorder.setStroke()
        context.stroke(rect)
    }
    
    
    static func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect) -> UIImage? {
  
        let cropZone = CGRect(x: cropRect.origin.x * 0.5,
                              y: cropRect.origin.y,
                              width: cropRect.size.width,
                              height: cropRect.size.height)
        
//         print(cropZone)
//        print(inputImage.size)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
            else {
                return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
}
