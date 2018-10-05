//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import XCTest
import FBSnapshotTestCase
@testable import CollageMaker


class AttributedTextLabelTestCase: FBSnapshotTestCase {
    
    var attributedLabel: AttributedTextLabel!
    
    override func setUp() {
        super.setUp()
        recordMode = false
        attributedLabel = AttributedTextLabel(text: "Testing", frame: CGRect(origin: .zero, size: CGSize(width: 400, height: 200)))
    }
    
    override func tearDown() {
        attributedLabel = nil
        super.tearDown()
    }
    
    func testCanAddAttributes() {
        attributedLabel.text = "Testing label"
        attributedLabel.addAttributes(attrs: [.foregroundColor: UIColor.brightLavender], to: "label")
        
        FBSnapshotVerifyView(attributedLabel)
    }
}
