//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

enum NavigationControllerElements: RobotElement {
    case back
    case share
    case select
    case close

    var id: String {
        switch self {
        case .back: return Accessibility.NavigationControl.back.id
        case .share: return Accessibility.NavigationControl.share.id
        case .select: return Accessibility.NavigationControl.select.id
        case .close: return Accessibility.NavigationControl.close.id
        }
    }
}

@testable import CollageMaker
import EarlGrey
import XCTest

class CollageSceneScenarioTests: XCTestCase {
    var robot: CollageSceneRobot!

    override func setUp() {
        super.setUp()

        robot = CollageSceneRobot()
    }

    override func tearDown() {
        robot = nil

        super.tearDown()
    }

    func testShareScreenOpening() {
        robot.tap(NavigationControllerElements.share)
            .expect(ShareScreenElements.shareFooter, isVisible: true)
            .tap(NavigationControllerElements.close)
            .expect(CollageSceneElements.collageView, isVisible: true)
    }

    func testSplitHorizontal() {
        robot.splitBy(axis: .horizontal)
    }

    func testSplitVerticalAndAddImage() {
        robot.splitBy(axis: .vertical)
            .addImage()
    }

    func testSplitAndRemoveCell() {
        robot.splitBy(axis: .vertical)
            .deleteCell()
    }
}
