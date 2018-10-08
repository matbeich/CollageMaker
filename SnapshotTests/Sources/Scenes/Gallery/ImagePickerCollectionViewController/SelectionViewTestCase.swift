//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import FBSnapshotTestCase
import XCTest

class SelectionViewTestCase: FBSnapshotTestCase {
    var selectionView: SelectionView!

    override func setUp() {
        super.setUp()
        recordMode = false

        selectionView = SelectionView(frame: CGRect(origin: .zero, size: CGSize(width: 75, height: 75)))
    }

    override func tearDown() {
        selectionView = nil

        super.tearDown()
    }

    func testSelectionViewIsAlwaysRound() {
        selectionView.layer.cornerRadius = 0
        FBSnapshotVerifyView(selectionView)
    }
}
