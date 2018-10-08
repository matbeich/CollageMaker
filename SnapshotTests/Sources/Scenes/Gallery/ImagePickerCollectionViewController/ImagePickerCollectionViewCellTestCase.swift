//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import FBSnapshotTestCase
import XCTest

class ImagePickerCollectionViewCellTestCase: FBSnapshotTestCase {
    var cell: ImagePickerCollectionViewCell!

    override func setUp() {
        super.setUp()
        recordMode = false

        let image = UIImage.test

        cell = ImagePickerCollectionViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
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
