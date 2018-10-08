//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import FBSnapshotTestCase
@testable import CollageMaker

class RoundCornersGradientButtonTestCase: FBSnapshotTestCase {
    
    var button: RoundCornersGradientButton!
    
    override func setUp() {
        super.setUp()
        recordMode = true
        button = RoundCornersGradientButton(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 150)))
    }
    
    override func tearDown() {
        button = nil
        super.tearDown()
    }
    
    func testButtonWithText() {
        button.setTitle("Only text")
        
        FBSnapshotVerifyView(button)
    }
    
    func testButtonWithTextAndImage() {
        let img = R.image.confirm_btn()
        
        button.setTitle("With checkmark")
        button.setImage(img)
        
        FBSnapshotVerifyView(button)
    }
    
    func testWithImage() {
        let image = UIImage(named: "test_img.png", in: Bundle.init(for: BundleClass.self), compatibleWith: nil)
        button.setImage(image)
        
        FBSnapshotVerifyView(button)
    }
    
    func testButtonWithShadow() {
        button.showShadow = true
        
        FBSnapshotVerifyView(button)
    }
    
    func testbuttonWithoutShadow() {
        button.showShadow = false
        
        FBSnapshotVerifyView(button)
    }
}
