//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import XCTest

class CollageMakerUITests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
   
    func testShareFinishedCollage() {
        
        let app = XCUIApplication()
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.tap()
        element.children(matching: .other).element(boundBy: 1).collectionViews.cells.children(matching: .other).element.tap()
        app.buttons["share btn"].tap()
        element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).tap()
    }
  
}
