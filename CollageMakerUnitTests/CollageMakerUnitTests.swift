//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import XCTest
import EarlGrey
@testable import CollageMaker

class TemplatePickerRobot {
    func selectImage(at index: UInt) {
        if selected.contains(index) {
            return
        }
        
        selected.insert(index)
        image(at: index).perform(grey_tap())
    }
    
    func deselectImage(at index: UInt) {
        image(at: index).perform(grey_tap())
    }
    
    func selectAnyImage() {
        selectImage(at: 0)
    }
    
    func deleteAllImages() {
        selected.forEach(deselectImage)
        selected.removeAll()
    }
    
    var isTemplateViewVisible: Bool {
        return controller.templateViewIsVisible
    }
    
    private func image(at index: UInt) -> GREYInteraction {
        let imageCell = EarlGrey.selectElement(with: grey_accessibilityID("image_picker_cell"))
        return imageCell.atIndex(index)
    }
    
    let controller = TemplatePickerViewController()
    
    private var selected = Set<UInt>()
}

class MyFirstEarlGreyTest: XCTestCase {

    func testPresenceOfKeyWindow() {
        EarlGrey.selectElement(with: grey_keyWindow())
            .assert(grey_sufficientlyVisible())
    }
    
    func testTemplateViewChangesVisibility() {
        let robot = TemplatePickerRobot()
        
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 600)))
        window.rootViewController = robot.controller
        window.makeKeyAndVisible()
   
        // TemplateView is hidden by default
        XCTAssertFalse(robot.isTemplateViewVisible)
        
        robot.selectAnyImage()
        
        // TemplateView appers with selected image
        XCTAssertTrue(robot.isTemplateViewVisible)
        
        robot.deleteAllImages()
        
        // TemplateView is hidden without selected images
        XCTAssertFalse(robot.isTemplateViewVisible)
    }
}
