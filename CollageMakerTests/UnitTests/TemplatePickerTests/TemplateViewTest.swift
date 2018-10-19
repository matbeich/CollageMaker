//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import EarlGrey
import XCTest

class TemplateViewTest: XCTestCase {
    var robot: TemplatePickerRobot!

    override func setUp() {
        super.setUp()

        robot = TemplatePickerRobot()
    }

    override func tearDown() {
        robot = nil

        super.tearDown()
    }

    func testTemplateViewChangesVisibility() {
        robot.expect(TemplatePickerElements.templateView, isVisible: false)
            .selectAnyImage()
            .expect(TemplatePickerElements.templateView, isVisible: true)
            .deselectAllImages()
            .expect(TemplatePickerElements.templateView, isVisible: false)
    }

    func testCollageSceneOpening() {
        robot.selectAnyImage()
            .expect(TemplatePickerElements.templateView, isVisible: true)
            .selectTemplate(at: 0)
            .expect(CollageSceneElements.collageView, isVisible: true)
    }
}
