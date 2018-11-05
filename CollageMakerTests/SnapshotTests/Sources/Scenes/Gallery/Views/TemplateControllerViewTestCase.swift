//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import FBSnapshotTestCase
import XCTest

class TemplateControllerViewTestCase: FBSnapshotTestCase {
    var templateView: TemplatesView!

    override func setUp() {
        super.setUp()
        recordMode = false

        templateView = TemplatesView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 200)))
    }

    override func tearDown() {
        templateView = nil

        super.tearDown()
    }

    func testTemplateViewWithHeader() {
        templateView.setHeaderText("Test")

        FBSnapshotVerifyView(templateView)
    }

    func testTemplateViewWithoutHeader() {
        templateView.setHeaderText(nil)

        FBSnapshotVerifyView(templateView)
    }
}
