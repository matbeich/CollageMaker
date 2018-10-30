//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import EarlGrey
import XCTest

class CollageNavigationTest: XCTestCase {
    var robot: CollageNavigationRobot!

    override func setUp() {
        super.setUp()

        robot = CollageNavigationRobot()
    }

    override func tearDown() {
        robot = nil

        super.tearDown()
    }

    func testCollageSceneNavigation() {
        robot.navigateToCollageScene()
    }
}
