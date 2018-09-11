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
        collage.splitSelectedCell(by: .horizontal)
        collage.splitSelectedCell(by: .horizontal)
        collage.splitSelectedCell(by: .vertical)
        
        while collage.cells.count != 1 {
            collage.deleteSelectedCell()
        }
        
        collage.deleteSelectedCell()
        XCTAssertEqual(collage.cells.count, 1)
    }
    
    func testCellSizeIsInBounds() {
        let cell = collage.selectedCell
        cell.changeRelativeFrame(with: 20, with: .right)
        
        XCTAssertTrue(cell.isAllowed(cell.relativeFrame))
    }
    
    func testCollageIsAlwaysFullsized() {
        let cell = CollageCell(color: .blue, relativeFrame: .fullsized)
        let secondCell = CollageCell(color: .blue, relativeFrame: .fullsized)
        
        collage = Collage(cells: [cell, secondCell])
       
        XCTAssertTrue(collage.isFullsized)
    }
}
