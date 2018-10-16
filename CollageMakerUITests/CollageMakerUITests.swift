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
    
    func testExample() {
        let app = XCUIApplication()
        let element2 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        let element = element2.children(matching: .other).element(boundBy: 0)
        element.collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.tap()
        element2.children(matching: .other).element(boundBy: 1).collectionViews.cells.children(matching: .other).element.tap()
        element2.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element(boundBy: 1).tap()
        element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .button).element.tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.tap()
        app.buttons["share btn"].tap()
    }
    
    func testShareToInstagram() {
        let app = XCUIApplication()
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.tap()
        element.children(matching: .other).element(boundBy: 1).collectionViews.cells.children(matching: .other).element.tap()
        app.buttons["share btn"].tap()
        element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).tap()
        app.buttons["close btn"].tap()
        app.buttons["back btn"].tap()
    }
    
    func testNavigationBarAnimation() {
                
    }
}
