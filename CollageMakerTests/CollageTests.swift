//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import XCTest

class CollageTests: XCTestCase {
    func testCollageCantDeleteLastCell() {
        let collage = Collage()
        collage.splitSelectedCell(by: .horizontal)
        collage.splitSelectedCell(by: .horizontal)

        collage.deleteAllCells()
        collage.deleteSelectedCell()

        XCTAssertFalse(collage.isEmpty)
    }

    func testCellSizeIsInBounds() {
        let collage = Collage()
        let cell = collage.selectedCell

        cell.changeRelativeFrame(with: 20, with: .right)

        XCTAssertTrue(cell.isAllowed(cell.relativeFrame))
    }

    func testCollageIsAlwaysFullsized() {
        let collage = Collage()
        let cell = CollageCell(color: .blue, relativeFrame: .fullsized)
        let secondCell = CollageCell(color: .blue, relativeFrame: .fullsized)

        collage = Collage(cells: [cell, secondCell])

        XCTAssertTrue(collage.isFullsized)
    }
}

private extension Collage {
    var isEmpty: Bool {
        return cells.isEmpty
    }

    func deleteAllCells() {
        while cells.count > 1 {
            deleteSelectedCell()
        }
    }
}
