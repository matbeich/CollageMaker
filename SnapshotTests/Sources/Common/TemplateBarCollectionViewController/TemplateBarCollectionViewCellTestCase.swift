//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import FBSnapshotTestCase
import Photos
import XCTest

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
        let image = UIImage.test
        cell.collageImage = image

        FBSnapshotVerifyView(cell)
    }
}
