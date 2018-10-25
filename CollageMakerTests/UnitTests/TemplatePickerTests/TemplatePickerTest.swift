//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import EarlGrey
import XCTest

class TemplatePickerTest: XCTestCase {
    var robot: TemplatePickerRobot!

    override func setUp() {
        super.setUp()

        robot = TemplatePickerRobot()
    }

    override func tearDown() {
        robot = nil

        super.tearDown()
    }

    func testTemplatePickerCantSelectMoreCells() {

    }
}
