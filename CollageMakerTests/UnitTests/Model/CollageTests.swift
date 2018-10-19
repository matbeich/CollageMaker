//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import Photos
import UIKit
import XCTest

class BundleClass {}

class CollageTests: XCTestCase {
    func testCollageIsAlwaysFullsized() {
        var collage = Collage()
        let cell = CollageCell(color: .blue, relativeFrame: .fullsized)
        let secondCell = CollageCell(color: .blue, relativeFrame: .fullsized)

        collage = Collage(cells: [cell, secondCell])

        XCTAssertTrue(collage.isFullsized)
    }

    func testGetCellWithAsset() {
        let asset = PHAsset()
        let image = UIImage.test
        let cell = CollageCell(color: .red, photoAsset: asset, relativeFrame: .leftFullHeightHalfWidth)
        let cell2 = CollageCell(color: .red, image: image, relativeFrame: .rightFullHeightHalfWidth)
        let collage = Collage(cells: [cell, cell2])

        let cellForAsset = collage.cellWith(asset: asset)

        XCTAssertEqual(cell, cellForAsset)
    }

    func testGetCellWithID() {
        let image = UIImage.test
        let cell = CollageCell(color: .red, relativeFrame: .leftFullHeightHalfWidth)
        let cell2 = CollageCell(color: .red, image: image, relativeFrame: .rightFullHeightHalfWidth)
        let collage = Collage(cells: [cell, cell2])

        let testID = cell.id
        let cellForID = collage.cellWith(id: testID)

        XCTAssertEqual(cell, cellForID)
    }

    func testCellSizeChanges() {
        let cell = CollageCell(color: .red, relativeFrame: .leftFullHeightHalfWidth)
        let cell2 = CollageCell(color: .red, relativeFrame: .rightFullHeightHalfWidth)
        var collage = Collage(cells: [cell, cell2])
        let frameBeforeChanging = cell.relativeFrame

        collage.changeSize(cell: cell, grip: .right, value: 0.2)

        XCTAssertNotEqual(frameBeforeChanging, collage.cellWith(id: cell.id)?.relativeFrame)
    }

    func testFillsCellsWithAbstractPhotos() {
        let image = UIImage.test
        let abstractPhoto = AbstractPhoto(photo: image, asset: PHAsset())
        let testAbstractPhotos = Array(0 ... 10).map { _ in abstractPhoto }

        let cell = CollageCell(color: .red, relativeFrame: .leftFullHeightHalfWidth)
        let cell2 = CollageCell(color: .red, relativeFrame: .rightFullHeightHalfWidth)
        var collage = Collage(cells: [cell, cell2])

        collage.fill(with: testAbstractPhotos)

        XCTAssertTrue(!collage.images.isEmpty && !collage.assets.isEmpty)
    }
}

private extension Collage {
    var isEmpty: Bool {
        return cells.isEmpty
    }

    var images: [UIImage] {
        return cells.compactMap { $0.image }
    }

    var assets: [PHAsset] {
        return cells.compactMap { $0.photoAsset }
    }
}
