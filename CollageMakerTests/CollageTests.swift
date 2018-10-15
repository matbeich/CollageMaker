//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import Photos
import UIKit
import XCTest

class BundleClass {}

class CollageTests: XCTestCase {
    func testCollageCantDeleteLastCell() {
        let collage = Collage()
        collage.splitSelectedCell(by: .horizontal)
        collage.splitSelectedCell(by: .horizontal)

        collage.deleteAllCells()
        collage.deleteSelectedCell()

        XCTAssertFalse(collage.isEmpty)
    }

    func testCellSizeIsInBounds() {
        let collage = Collage()
        let cell = collage.selectedCell

        cell.changeRelativeFrame(with: 20, with: .right)

        XCTAssertTrue(cell.isAllowed(cell.relativeFrame))
    }

    func testCollageIsAlwaysFullsized() {
        var collage = Collage()
        let cell = CollageCell(color: .blue, relativeFrame: .fullsized)
        let secondCell = CollageCell(color: .blue, relativeFrame: .fullsized)

        collage = Collage(cells: [cell, secondCell])

        XCTAssertTrue(collage.isFullsized)
    }

    func testCanDeleteAllImages() {
        let image = UIImage.test

        let cell = CollageCell(color: .red, image: image, relativeFrame: .leftFullHeightHalfWidth)
        let cell2 = CollageCell(color: .red, image: image, relativeFrame: .rightFullHeightHalfWidth)
        let collage = Collage(cells: [cell, cell2])

        collage.deleteImages()

        XCTAssertTrue(collage.images.isEmpty)
    }

    func testCopyIsEquatable() {
        let collage = Collage()

        guard let copy = collage.copy() as? Collage else {
            XCTAssertTrue(false)

            return
        }

        XCTAssertEqual(collage, copy)
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
        let collage = Collage(cells: [cell, cell2])
        let frameBeforeChanging = collage.selectedCell.relativeFrame

        collage.changeSizeOfSelectedCell(grip: .left, value: 0.3)

        XCTAssertNotEqual(frameBeforeChanging, collage.selectedCell.relativeFrame)
    }

    func testFillsCellsWithImages() {
        let image = UIImage.test
        let images = Array(0 ... 10).compactMap { _ in image }

        let cell = CollageCell(color: .red, relativeFrame: .leftFullHeightHalfWidth)
        let cell2 = CollageCell(color: .red, relativeFrame: .rightFullHeightHalfWidth)
        let collage = Collage(cells: [cell, cell2])

        collage.deleteImages()
        collage.fillWithImages(images)

        XCTAssertFalse(collage.images.isEmpty)
    }

    func testFillsCellsWithAbstractPhotos() {
        let image = UIImage.test
        let abstractPhoto = AbstractPhoto(photo: image, asset: PHAsset())
        let testAbstractPhotos = Array(0 ... 10).map { _ in abstractPhoto }

        let cell = CollageCell(color: .red, relativeFrame: .leftFullHeightHalfWidth)
        let cell2 = CollageCell(color: .red, relativeFrame: .rightFullHeightHalfWidth)
        let collage = Collage(cells: [cell, cell2])

        collage.deleteImages()
        collage.fill(with: testAbstractPhotos)

        XCTAssertTrue(!collage.images.isEmpty && !collage.assets.isEmpty)
    }
}

private extension Collage {
    var isEmpty: Bool {
        return cells.isEmpty
    }

    func deleteAllCells() {
        while cells.count > 1 {
            deleteSelectedCell()
        }
    }

    var images: [UIImage] {
        return cells.compactMap { $0.image }
    }

    var assets: [PHAsset] {
        return cells.compactMap { $0.photoAsset }
    }
}
