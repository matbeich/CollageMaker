//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import XCTest
import EarlGrey

class MyFirstEarlGreyTest: XCTestCase {
    
    func testExample() {
        // Your test actions and assertions will go here.
    }
    
    func testPresenceOfKeyWindow() {
        EarlGrey.selectElement(with: grey_keyWindow())
            .assert(grey_sufficientlyVisible())
    }
    
    func testImagePickerIsVisible() {
        EarlGrey.selectElement(with: grey_)
    }
}
