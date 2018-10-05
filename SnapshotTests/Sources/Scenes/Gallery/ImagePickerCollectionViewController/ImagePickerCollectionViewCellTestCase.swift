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
        let image = UIImage(named: "test_img.png", in: Bundle(for: BundleClass.self), compatibleWith: nil)
        cell.image = image
    }
    
    override func tearDown() {
        cell = nil
        
        super.tearDown()
    }
    
    func testCellWithImageIsSelected() {
        cell.cellSelected = true
        
        FBSnapshotVerifyView(cell)
    }
    
    func testCellWithImageIsDeselected() {
        cell.cellSelected = false
        
        FBSnapshotVerifyView(cell)
    }
    
    func testCellIsEmpty() {
        cell.image = nil
        
        FBSnapshotVerifyView(cell)
    }
    
}
