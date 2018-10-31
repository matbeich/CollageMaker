//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import Photos
import UIKit
import XCTest

class CollageRendererTests: XCTestCase {
    var collage: Collage!
    var renderer: CollageRenderer!
    var templateProvider: CollageTemplateProvider!

    override func setUp() {
        super.setUp()

        let assets = Array(1 ... 9).map { _ in PHAsset() }

        templateProvider = CollageTemplateProvider(photoLibrary: MockPhotoLibrary(quality: .high))
        renderer = CollageRenderer()

        if let template = templateProvider.templates(for: assets).first {
            templateProvider.collage(from: template) { [weak self] in self?.collage = $0 }
        } else {
            collage = Collage(cells: [.zeroFrame])
        }

        collage.cells.forEach { collage.updateImageVisibleRect(CGRect(origin: .zero, size: $0.image?.size ?? .zero), in: $0) }
    }

    override func tearDown() {
        collage = nil
        renderer = nil
        templateProvider = nil

        super.tearDown()
    }

    func testRendererPerformance() {
        measure {
            _ = renderer.renderImage(from: collage, with: CGSize(width: 1300, height: 1300), borders: true)
        }
    }
}
