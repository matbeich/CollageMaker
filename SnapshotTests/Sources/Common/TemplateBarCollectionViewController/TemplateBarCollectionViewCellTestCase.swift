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
        recordMode = true
    
        cell.layoutIfNeeded()
    }
    
    override func tearDown() {
        cell = nil
        super.tearDown()
    }
    
    func testCellShowImage() {
        
        FBSnapshotVerifyView(cell)
    }
}
