//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

class CustomInsetsGridLayout: UICollectionViewFlowLayout {
    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        scrollDirection = .vertical
        minimumInteritemSpacing = 2
        minimumLineSpacing = 2
        sectionInset = insets
    }

    var width: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }

        return (collectionView.bounds.width - 2 * 5) / 4
    }

    override var itemSize: CGSize {
        get {
            return CGSize(width: width, height: width)
        }
        set {
        }
    }

    private var insets: UIEdgeInsets
}
