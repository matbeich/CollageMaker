//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import XCTest
import FBSnapshotTestCase
import Photos
@testable import CollageMaker

class TemplateBarCollectionViewCellTestCase: FBSnapshotTestCase {
    
    var cell: TemplateBarCollectionViewCell!
    
    override func setUp() {
        super.setUp()
        recordMode = false
        cell = TemplateBarCollectionViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
    
        cell.layoutIfNeeded()
    }
    
    override func tearDown() {
        cell = nil
        super.tearDown()
    }
    
    func testCellShowImage() {
        let image = UIImage(named: "test_img.png", in: Bundle.init(for: BundleClass.self), compatibleWith: nil)
        cell.collageImage = image
        
        FBSnapshotVerifyView(cell)
    }
}
