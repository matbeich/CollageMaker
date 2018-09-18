//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import SnapKit

class TemplateBarCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var collageTemplate: CollageTemplate? {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        collageTemplate = nil
    }
    
    func update() {
        guard let collageTemplate = collageTemplate else {
            return
        }
        
        CollageTemplateProvider.collage(from: collageTemplate) { collage in
            let collageView = CollageView(frame: CGRect(origin: .zero, size: collageTemplate.size.value))
            collageView.updateCollage(collageTemplate.collage)
            collageView.saveCellsVisibleRect()

            DispatchQueue.global().async { [weak self] in
                let image = CollageRenderer.renderImage(from: collage, with: collageTemplate.size.value)
                
                DispatchQueue.main.async {
                    if collage == collageTemplate.collage {
                        self?.imageView.image = image
                    }
                }
            }
        }
    }
    
    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }
    }
    
    private let imageView = UIImageView()
}
