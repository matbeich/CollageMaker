//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import EarlGrey
import XCTest

class ShareScreenScenarioTests: XCTestCase {
    var robot: ShareScreenRobot!

    override func setUp() {
        super.setUp()

        robot = ShareScreenRobot()
    }

    override func tearDown() {
        robot = nil

        super.tearDown()
    }

    func testSharesToCorrectDestination() {
        5.times { robot.shareTo(destination: randomDestination()) }
    }

    func randomDestination() -> ShareDestination {
        let random = arc4random_uniform(4)

        switch random {
        case 0: return .instagram
        case 1: return .photos
        case 2: return .other
        default: return .messages
        }
    }
}
