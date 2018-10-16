//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit

enum CollageError: Error {
    case noRecentlyDeletedCell
}

enum Axis: String {
    case horizontal
    case vertical
}

struct Collage: Equatable {
    static let maximumAllowedCellsCount = 9

    var canDeleteCells: Bool {
        return cells.count > 1
    }

    init(cells: [CollageCell] = []) {
        self.cells = cells
        self.selectedCell = cells.last ?? CollageCell.zeroFrame

        if !isFullsized {
            let initialCell = CollageCell(color: .collagePink, image: R.image.addimg(), relativeFrame: RelativeFrame.fullsized)

            self.cells = [initialCell]
            self.selectedCell = initialCell
        }
    }

    mutating func fillWithImages(_ images: [UIImage]) {
        for (cell, image) in zip(cells, images) {
            addImage(image, to: cell)
        }
    }

    mutating func fill(with abstractPhotos: [AbstractPhoto]) {
        for (cell, abstractPhoto) in zip(cells, abstractPhotos) {
            addImage(abstractPhoto.photo, to: cell)
            addAsset(abstractPhoto.asset, to: cell)
        }
    }

    mutating func deleteImages() {
        cells.forEach { $0.deleteImage() }
    }

    mutating func setSelected(cell: CollageCell) {
        selectedCell = cellWith(id: cell.id) ?? .zeroFrame
    }

    mutating func deleteSelectedCell() {
        guard canDeleteCells else {
            return
        }

        delete(selectedCell)
    }

    mutating func restoreRecentlyDeletedCell() {
        guard canRestoreDeletedCell else {
            return
        }

        restoreCellsBeforeChanging()

        canRestoreDeletedCell = false
        recentlyDeletedCellID = nil
    }

    mutating func splitSelectedCell(by axis: Axis) {
        split(cell: selectedCell, by: axis)
    }

    mutating func addImageToSelectedCell(_ image: UIImage?) {
        addImage(image, to: selectedCell)
    }

    mutating func addAssetToSelectedCell(_ asset: PHAsset?) {
        addAsset(asset, to: selectedCell)
    }

    mutating func changeSizeOfSelectedCell(grip: GripPosition, value: CGFloat) {
        changeSize(of: selectedCell, grip: grip, value: value)
    }

    mutating func delete(_ cell: CollageCell) {
        for position in cell.gripPositions {
            if merge(cell: cell, grip: position, value: position.sideChangeValue(for: cell.relativeFrame)) { break }
        }
    }

    mutating func addImage(_ image: UIImage?, to cell: CollageCell) {
        cell.addImage(image)
    }

    mutating func addAsset(_ asset: PHAsset?, to cell: CollageCell) {
        cell.addPhotoAsset(asset)
    }

    mutating func split(cell: CollageCell, by axis: Axis) {
        let (firstFrame, secondFrame) = cell.relativeFrame.split(axis: axis)

        let firstCell = CollageCell(color: cell.color, image: cell.image, photoAsset: cell.photoAsset, relativeFrame: firstFrame)
        let secondCell = CollageCell(color: .random, image: nil, relativeFrame: secondFrame)

        if firstCell.isAllowed(firstFrame) && secondCell.isAllowed(secondFrame) {
            add(cell: firstCell)
            add(cell: secondCell)
            remove(cell: cell)
            setSelected(cell: secondCell)
        }
    }

    mutating func changeSize(cell: CollageCell, grip: GripPosition, value: CGFloat) {
        changeSize(of: cell, grip: grip, value: value, merging: false)
    }

    private mutating func changeSize(of cell: CollageCell, grip: GripPosition, value: CGFloat, merging: Bool = false) {
        undoStackCells.append(cells)
        calculateCellsNewFrame(cell: cell, grip: grip, value: value)

        let framesAreAllowed = cells.map { $0.isAllowed($0.relativeFrame) }.reduce(true, { $0 && $1 })

        guard isFullsized && framesAreAllowed else {
            restoreCellsBeforeChanging()

            return
        }
    }

    private mutating func restoreCellsBeforeChanging() {
        guard let previousStateCells = undoStackCells.last else {
            return
        }

        cells = previousStateCells
        setSelected(cell: selectedCell)
    }

    private mutating func merge(cell: CollageCell, grip: GripPosition, value: CGFloat) -> Bool {
        undoStackCells.append(cells)
        remove(cell: cell)

        prepareCells(cell: cell, grip: grip, value: value, merging: true)

        calculateCellsNewFrame(cell: cell, grip: grip, value: value, merging: true)

        if isFullsized {
            setSelected(cell: cells.last ?? .zeroFrame)

            return true
        }

        restoreCellsBeforeChanging()
        return false
    }

    private func prepareCells(cell: CollageCell, grip: GripPosition, value: CGFloat, merging: Bool = false) {
        let changingCells = affectedWithChangeOf(cell: cell, with: grip, merging: merging)

        guard changingCells.count > 0, check(grip, in: cell) else {
            return
        }
    }

    private func calculateCellsNewFrame(cell: CollageCell, grip: GripPosition, value: CGFloat, merging: Bool = false) {
        let changingCells = affectedWithChangeOf(cell: cell, with: grip, merging: merging)

        guard changingCells.count > 0, check(grip, in: cell) else {
            return
        }

        changingCells.forEach {
            let changeGrip = $0.gripPositionRelativeTo(cell: cell, grip)
            let frame = measureRelativeFrame(for: $0, with: value, with: grip)
            $0.re
            $0.calculateGripPositions()
        }
    }

    func measureRelativeFrame(for cell: CollageCell, with value: CGFloat, with gripPosition: GripPosition) -> RelativeFrame {
        switch gripPosition {
        case .left: return cell.relativeFrame.stretchedLeft(with: value).normalizedToAllowed()
        case .right: return cell.relativeFrame.stretchedRight(with: value).normalizedToAllowed()
        case .top: return cell.relativeFrame.stretchedUp(with: value).normalizedToAllowed()
        case .bottom: return cell.relativeFrame.stretchedDown(with: value).normalizedToAllowed()
        }
    }

    private var recentlyDeletedCellID: UUID?
    private var undoStackCells: [[CollageCell]] = []
    private(set) var cells: [CollageCell]
    private(set) var selectedCell: CollageCell
    private(set) var canRestoreDeletedCell: Bool = false
}

extension Collage {
    var isFullsized: Bool {
        let collageArea = RelativeFrame.fullsized.area
        let cellsArea = cells.map { $0.relativeFrame.area }.reduce(0.0, { $0 + $1 })
        let cellsInBounds = cells.map { $0.relativeFrame.isInBounds(.fullsized) }.reduce(true, { $0 && $1 })

        return cellsInBounds && collageArea.isApproximatelyEqual(to: cellsArea)
    }

    func cellWith(id: UUID) -> CollageCell? {
        return cells.first(where: { $0.id == id })
    }

    func cellWith(asset: PHAsset) -> CollageCell? {
        return cells.first(where: { $0.photoAsset?.localIdentifier == asset.localIdentifier })
    }

    func cell(at relativePoint: CGPoint) -> CollageCell? {
        return cells.first(where: { $0.relativeFrame.contains(relativePoint) })
    }

    func check(_ gripPosition: GripPosition, in cell: CollageCell) -> Bool {
        return cell.gripPositions.contains(gripPosition)
    }

    static func == (lhs: Collage, rhs: Collage) -> Bool {
        let leftPictures = lhs.cells.compactMap { $0.image }
        let rightPictures = rhs.cells.compactMap { $0.image }

        return lhs.cells == rhs.cells && leftPictures == rightPictures
    }

    private mutating func add(cell: CollageCell) {
        if !cells.contains(cell) {
            cells.append(cell)
        }
    }

    private mutating func remove(cell: CollageCell) {
        cells = cells.filter { $0.id != cell.id }
    }

    private func cellsLayingOnLine(with cell: CollageCell, gripPosition: GripPosition) -> [CollageCell] {
        return cells.filter { $0.belongsToParallelLine(on: gripPosition.axis, with: gripPosition.centerPoint(in: cell)) }
    }

    private func cellIntersected(with cell: CollageCell, gripPosition: GripPosition) -> [CollageCell] {
        return cells.filter({ $0 != cell }).compactMap { (newcell) -> CollageCell? in
            newcell.relativeFrame.intersects(rect2: cell.relativeFrame, on: gripPosition) ? newcell : nil
        }
    }

    private func affectedWithChangeOf(cell: CollageCell, with grip: GripPosition, merging: Bool) -> [CollageCell] {
        var changingCells: [CollageCell]

        if merging {
            changingCells = cellIntersected(with: cell, gripPosition: grip)
        } else {
            let intersectedCells = Set<CollageCell>(cellIntersected(with: cell, gripPosition: grip))
            let layingOnLineCells = Set<CollageCell>(cellsLayingOnLine(with: cell, gripPosition: grip))

            changingCells = Array(layingOnLineCells.intersection(intersectedCells))

            if changingCells.count == 1, let firstCell = changingCells.first, firstCell.relativeFrame.equallyIntersects(rect2: cell.relativeFrame, on: grip) {
                changingCells.append(cell)
            } else {
                changingCells = cellsLayingOnLine(with: cell, gripPosition: grip)
            }
        }

        return changingCells
    }
}
