//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import XCTest
@testable import CollageMaker

class CollageTests: XCTestCase {
    
    var collage: Collage!
    
    override func setUp() {
        super.setUp()
        
        collage = Collage()
    }
    
    override func tearDown() {
        collage = nil
        
        super.tearDown()
    }
    
    func testCollageCantDeleteLastCell() {
        while collage.cells.count != 1 {
            collage.deleteSelectedCell()
        }
        
        collage.deleteSelectedCell()
        XCTAssertEqual(collage.cells.count, 1)
    }
    
    func testCellSizeIsInBounds() {
        let cellUnderTest = collage.selectedCell
        
        cellUnderTest.changeRelativeFrame(for: 20, with: .right)
        
        XCTAssertTrue(cellUnderTest.isAllowed(cellUnderTest.relativeFrame))
    }
    
    func testCollageIsAlwaysFullsized() {
        let cell = CollageCell(color: .blue, relativeFrame: .fullsized)
        let secondCell = CollageCell(color: .blue, relativeFrame: .fullsized)
        
        collage = Collage(cells: [cell, secondCell])
       
        XCTAssertTrue(collage.isFullsized)
    }
}
