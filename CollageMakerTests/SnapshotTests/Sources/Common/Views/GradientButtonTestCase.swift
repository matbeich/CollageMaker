//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import FBSnapshotTestCase
import Foundation

class GradientButtonTestCase: FBSnapshotTestCase {
    var button: GradientButton!

    override func setUp() {
        super.setUp()
        recordMode = false
        button = GradientButton(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 75)))
    }

    override func tearDown() {
        button = nil
        super.tearDown()
    }

    func testButtonWithText() {
        button.setTitle("Only text", for: .normal)

        FBSnapshotVerifyView(button)
    }

    func testButtonWithTextAndImage() {
        let img = R.image.confirm_btn()

        button.setTitle("With checkmark", for: .normal)
        button.setImage(img, for: .normal)

        FBSnapshotVerifyView(button)
    }

    func testWithImage() {
        let image = UIImage.testing
        button.setImage(image, for: .normal)

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
