//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit
import Utils

enum Axis: String {
    case horizontal
    case vertical
}

struct Collage {
    static let maximumAllowedCellsCount = 9

    var canDeleteCells: Bool {
        return cells.count > 1
    }

    init(cells: [CollageCell] = []) {
        self.cells = cells

        if !isFullsized {
            let initialCell = CollageCell(color: .random, image: nil, relativeFrame: RelativeFrame.fullsized)

            self.cells = [initialCell]
        }
    }

    mutating func delete(_ cell: CollageCell) {
        for position in cell.gripPositions {
            if merge(cell: cell, grip: position, value: position.sideChangeValue(for: cell.relativeFrame)) { break }
        }
    }

    mutating func fill(with abstractPhotos: [AbstractPhoto]) {
        for (cell, abstractPhoto) in zip(cells, abstractPhotos) {
            add(abstractPhoto, to: cell)
        }
    }

    mutating func split(cell: CollageCell, by axis: Axis) {
        guard cells.contains(cell) else {
            return
        }

        let (firstFrame, secondFrame) = cell.relativeFrame.split(axis: axis)
        let firstCell = CollageCell(color: cell.color, image: cell.image, photoAsset: cell.photoAsset, relativeFrame: firstFrame)
        let secondCell = CollageCell(color: .random, image: nil, relativeFrame: secondFrame)

        if firstCell.isAllowed(firstFrame) && secondCell.isAllowed(secondFrame) {
            add(cell: firstCell)
            add(cell: secondCell)
            remove(cell: cell)
        }
    }

    mutating func changeSize(cell: CollageCell, grip: GripPosition, value: CGFloat) {
        changeSize(of: cell, grip: grip, value: value)
    }

    mutating func add(_ abstractPhoto: AbstractPhoto, to cell: CollageCell) {
        guard cells.contains(cell) else {
            return
        }

        var newCell = cell
        newCell.image = abstractPhoto.photo
        newCell.photoAsset = abstractPhoto.asset
        newCell.imageVisibleFrame = .zero

        update(with: newCell)
    }

    mutating func updateImageVisibleRect(_ rect: CGRect, in cell: CollageCell) {
        var newCell = cell
        newCell.imageVisibleFrame = rect

        update(with: newCell)
    }

    private mutating func update(with cell: CollageCell) {
        remove(cell: cell)
        add(cell: cell)
    }

    private mutating func changeSize(of cell: CollageCell, grip: GripPosition, value: CGFloat, merging: Bool = false) {
        undoStackCells.append(cells)

        changeCellsFrameAffectedFor(cell: cell, grip: grip, value: value, merging: merging)
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
        undoStackCells = Array(undoStackCells.dropLast())
    }

    private mutating func merge(cell: CollageCell, grip: GripPosition, value: CGFloat) -> Bool {
        undoStackCells.append(cells)
        remove(cell: cell)
        changeCellsFrameAffectedFor(cell: cell, grip: grip, value: value, merging: true)

        if isFullsized { return true }

        restoreCellsBeforeChanging()
        return false
    }

    private mutating func changeCellsFrameAffectedFor(cell: CollageCell, grip: GripPosition, value: CGFloat, merging: Bool = false) {
        let changingCells = affectedWithChangeOf(cell: cell, with: grip, merging: merging)

        guard changingCells.count > 0, check(grip, in: cell) else {
            return
        }

        changingCells.forEach { changingCell in
            remove(cell: changingCell)

            let changeGrip = changingCell.gripPositionRelativeTo(cell: cell, grip)
            let frame = measureRelativeFrame(for: changingCell, with: value, at: changeGrip)
            var newCell = changingCell

            newCell.relativeFrame = frame

            add(cell: newCell)
        }
    }

    private func measureRelativeFrame(for cell: CollageCell, with value: CGFloat, at gripPosition: GripPosition) -> RelativeFrame {
        switch gripPosition {
        case .left: return cell.relativeFrame.stretchedLeft(with: value).normalizedToAllowed()
        case .right: return cell.relativeFrame.stretchedRight(with: value).normalizedToAllowed()
        case .top: return cell.relativeFrame.stretchedUp(with: value).normalizedToAllowed()
        case .bottom: return cell.relativeFrame.stretchedDown(with: value).normalizedToAllowed()
        }
    }

    private var undoStackCells: [[CollageCell]] = []
    private(set) var cells: [CollageCell]
}

extension Collage {
    var isFullsized: Bool {
        let collageArea = RelativeFrame.fullsized.area
        let cellsArea = cells.map { $0.relativeFrame.area }.reduce(0.0, { $0 + $1 })
        let cellsInBounds = cells.map { $0.relativeFrame.isInBounds(.fullsized) }.reduce(true, { $0 && $1 })

        return cellsInBounds && collageArea.isApproximatelyEqual(to: cellsArea)
    }

    var randomCell: CollageCell? {
        let randomIndex = Int(arc4random_uniform(UInt32(cells.count)))
        return cells[randomIndex]
    }

    private mutating func add(cell: CollageCell) {
        if !cells.contains(cell) {
            cells.append(cell)
        }
    }

    private mutating func remove(cell: CollageCell) {
        guard let index = cells.firstIndex(of: cell) else {
            return
        }

        cells.remove(at: index)
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

    private func cellsLayingOnLine(with cell: CollageCell, gripPosition: GripPosition) -> [CollageCell] {
        return cells.filter { $0.belongsToParallelLine(on: gripPosition.axis, with: gripPosition.centerPoint(in: cell)) }
    }

    private func cellIntersected(with cell: CollageCell, gripPosition: GripPosition) -> [CollageCell] {
        return cells.filter { $0 != cell && $0.relativeFrame.intersects(rect2: cell.relativeFrame, on: gripPosition) }
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

extension Collage: Equatable, Hashable {
    var hashValue: Int {
        return cells.reduce(0, { $0.hashValue ^ $1.hashValue }) &* 21873
    }

    static func == (lhs: Collage, rhs: Collage) -> Bool {
        let leftPictures = lhs.cells.compactMap { $0.image }
        let rightPictures = rhs.cells.compactMap { $0.image }

        return lhs.cells == rhs.cells && leftPictures == rightPictures
    }
}
