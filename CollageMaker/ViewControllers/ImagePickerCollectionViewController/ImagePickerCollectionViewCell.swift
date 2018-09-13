//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Photos

class ImagePickerCollectionViewCell: UICollectionViewCell {
    
    var photoAsset: PHAsset? {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    private func update() {
        if let asset = photoAsset {
            PhotoLibraryService.photo(for: asset, size: bounds.size) { [weak self] in
               self?.imageView.image = $0
            }
        }
    }
    
    private let imageView = UIImageView()
}
