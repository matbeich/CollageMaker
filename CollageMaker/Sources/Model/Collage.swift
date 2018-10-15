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

protocol CollageDelegate: AnyObject {
    func collageChanged(_ collage: Collage)
    func collage(_ collage: Collage, didRemoveCell cell: CollageCell)
    func collage(_ collage: Collage, didChangeSelectedCell cell: CollageCell)
    func collage(_ collage: Collage, didChangeFramesForCells cells: [CollageCell])
    func collage(_ collage: Collage, didUpdateCell cell: CollageCell)
    func collage(_ collage: Collage, didRestoreCell cell: CollageCell?, withError error: CollageError?)
}

class Collage: NSObject, NSCopying {
    static let maximumAllowedCellsCount = 9

    var canDeleteCells: Bool {
        return cells.count > 1
    }

    weak var delegate: CollageDelegate?

    init(cells: [CollageCell] = []) {
        self.cells = cells
        self.selectedCell = cells.last ?? CollageCell.zeroFrame
        super.init()

        if !isFullsized {
            let initialCell = CollageCell(color: .collagePink, image: R.image.addimg(), relativeFrame: RelativeFrame.fullsized)

            self.cells = [initialCell]
            self.selectedCell = initialCell
        }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let cellsCopy = cells.map { $0.copy() } as? [CollageCell]

        return Collage(cells: cellsCopy ?? [])
    }

    func fillWithImages(_ images: [UIImage]) {
        for (cell, image) in zip(cells, images) {
            addImage(image, to: cell)
        }
    }

    func fill(with abstractPhotos: [AbstractPhoto]) {
        for (cell, abstractPhoto) in zip(cells, abstractPhotos) {
            addImage(abstractPhoto.photo, to: cell)
            addAsset(abstractPhoto.asset, to: cell)
        }
    }

    func deleteImages() {
        cells.forEach { $0.deleteImage() }
    }

    func setSelected(cell: CollageCell) {
        selectedCell = cellWith(id: cell.id) ?? .zeroFrame
        delegate?.collage(self, didChangeSelectedCell: selectedCell)
    }

    func deleteSelectedCell() {
        guard canDeleteCells else {
            return
        }

        cellsBeforeChanging = cells.compactMap { $0.copy() as? CollageCell }
        canRestoreDeletedCell = true
        recentlyDeletedCellID = selectedCell.id

        delete(selectedCell)
    }

    func restoreRecentlyDeletedCell() {
        guard canRestoreDeletedCell, let id = recentlyDeletedCellID else {
            delegate?.collage(self, didRestoreCell: nil, withError: .noRecentlyDeletedCell)

            return
        }

        restoreCellsBeforeChanging()
        delegate?.collage(self, didRestoreCell: cellWith(id: id), withError: nil)

        canRestoreDeletedCell = false
        recentlyDeletedCellID = nil
    }

    func splitSelectedCell(by axis: Axis) {
        split(cell: selectedCell, by: axis)
    }

    func addImageToSelectedCell(_ image: UIImage?) {
        addImage(image, to: selectedCell)
    }

    func addAssetToSelectedCell(_ asset: PHAsset?) {
        addAsset(asset, to: selectedCell)
    }

    func changeSizeOfSelectedCell(grip: GripPosition, value: CGFloat) {
        changeSize(of: selectedCell, grip: grip, value: value)
    }

    func delete(_ cell: CollageCell) {
        for position in cell.gripPositions {
            if merge(cell: cell, grip: position, value: position.sideChangeValue(for: cell.relativeFrame)) { break }
        }
    }

    func addImage(_ image: UIImage?, to cell: CollageCell) {
        cell.addImage(image)

        delegate?.collage(self, didUpdateCell: cell)
    }

    func addAsset(_ asset: PHAsset?, to cell: CollageCell) {
        cell.addPhotoAsset(asset)
    }

    func split(cell: CollageCell, by axis: Axis) {
        let (firstFrame, secondFrame) = cell.relativeFrame.split(axis: axis)

        let firstCell = CollageCell(color: cell.color, image: cell.image, photoAsset: cell.photoAsset, relativeFrame: firstFrame)
        let secondCell = CollageCell(color: .random, image: nil, relativeFrame: secondFrame)

        if firstCell.isAllowed(firstFrame) && secondCell.isAllowed(secondFrame) {
            add(cell: firstCell)
            add(cell: secondCell)
            remove(cell: cell)
            setSelected(cell: secondCell)

            delegate?.collageChanged(self)
        }
    }

    func changeSize(cell: CollageCell, grip: GripPosition, value: CGFloat) {
        changeSize(of: cell, grip: grip, value: value, merging: false)
    }

    private func changeSize(of cell: CollageCell, grip: GripPosition, value: CGFloat, merging: Bool = false) {
        cellsBeforeChanging = cells.map { $0.copy() } as? [CollageCell] ?? []
        calculateCellsNewFrame(cell: cell, grip: grip, value: value)

        let framesAreAllowed = cells.map { $0.isAllowed($0.relativeFrame) }.reduce(true, { $0 && $1 })

        guard isFullsized && framesAreAllowed else {
            restoreCellsBeforeChanging()
            delegate?.collageChanged(self)

            return
        }

        delegate?.collage(self, didChangeFramesForCells: cells)
    }

    private func restoreCellsBeforeChanging() {
        cells = cellsBeforeChanging
        setSelected(cell: selectedCell)
    }

    private func merge(cell: CollageCell, grip: GripPosition, value: CGFloat) -> Bool {
        cellsBeforeChanging = cells.map { $0.copy() } as? [CollageCell] ?? []
        remove(cell: cell)

        calculateCellsNewFrame(cell: cell, grip: grip, value: value, merging: true)

        if isFullsized {
            delegate?.collage(self, didRemoveCell: cell)
            setSelected(cell: cells.last ?? .zeroFrame)

            return true
        }

        restoreCellsBeforeChanging()
        return false
    }

    private func calculateCellsNewFrame(cell: CollageCell, grip: GripPosition, value: CGFloat, merging: Bool = false) {
        let changingCells = affectedWithChangeOf(cell: cell, with: grip, merging: merging)

        guard changingCells.count > 0, check(grip, in: cell) else {
            return
        }

        changingCells.forEach {
            let changeGrip = $0.gripPositionRelativeTo(cell: cell, grip)
            $0.changeRelativeFrame(with: value, with: changeGrip)
            $0.calculateGripPositions()
        }
    }

    private var recentlyDeletedCellID: UUID?
    private var cellsBeforeChanging: [CollageCell] = []
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

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Collage else {
            return false
        }

        return self == object
    }

    static func == (lhs: Collage, rhs: Collage) -> Bool {
        let leftPictures = lhs.cells.compactMap { $0.image }
        let rightPictures = rhs.cells.compactMap { $0.image }

        return lhs.cells == rhs.cells && leftPictures == rightPictures
    }

    private func add(cell: CollageCell) {
        if !cells.contains(cell) {
            cells.append(cell)
        }
    }

    private func remove(cell: CollageCell) {
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
            let intersectedCells = Set(cellIntersected(with: cell, gripPosition: grip))
            let layingOnLineCells = Set(cellsLayingOnLine(with: cell, gripPosition: grip))

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
