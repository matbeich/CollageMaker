//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import FBSnapshotTestCase

class CollageRendererTestCase: FBSnapshotTestCase {
    var renderer: CollageRenderer!

    override func setUp() {
        super.setUp()
        recordMode = false

        renderer = CollageRenderer()
    }

    override func tearDown() {
        renderer = nil

        super.tearDown()
    }

    func testRendersImageFromCollage() {
        let collage = Collage(cells: [CollageCell(image: UIImage.testingHQ, relativeFrame: .fullsized)])

        let image = renderer.renderImage(from: collage, with: CGSize(width: 500, height: 500), borders: true)
        let imageView = UIImageView(image: image)

        FBSnapshotVerifyView(imageView)
    }
}
