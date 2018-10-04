//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import XCTest
import FBSnapshotTestCase
@testable import CollageMaker

class ImagePickerCollectionViewCellTestCase: FBSnapshotTestCase {
    
    var cell: ImagePickerCollectionViewCell!
    
    override func setUp() {
        super.setUp()
        recordMode = false
        cell = ImagePickerCollectionViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
    }
    
    override func tearDown() {
        cell = nil
        
        super.tearDown()
    }
    
    func testEmptyCellIsSelected() {
        cell.cellSelected = true
        
        FBSnapshotVerifyView(cell)
    }
    
    func testEmptyCellIsDeselected() {
        cell.cellSelected = false
        
        FBSnapshotVerifyView(cell)
    }
    
    func testCellShowsImage() {
        let image = UIImage(named: "test_img.png", in: Bundle.init(for: BundleClass.self), compatibleWith: nil)
        cell.image = image
        
        FBSnapshotVerifyView(cell)
    }
    
}
