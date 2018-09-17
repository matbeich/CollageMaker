//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//
import UIKit

enum Axis {
    case horizontal
    case vertical
}

protocol CollageDelegate: AnyObject {
    func collageChanged()
    func collage(_ collage: Collage, didChangeSelected cell: CollageCell)
    func collage(_ collage: Collage, didChangeFramesFor cells: [CollageCell])
    func collage(_ collage: Collage, didUpdate cell: CollageCell)
}

class Collage: NSObject, NSCopying {
    
    weak var delegate: CollageDelegate?
    
    init(cells: [CollageCell] = []) {
        self.cells = cells
        self.selectedCell = cells.last ?? CollageCell.zeroFrame
        super.init()
        
        guard isFullsized else {
            let initialCell = CollageCell(color: .collagePink, image: R.image.addimg(), relativeFrame: RelativeFrame.fullsized)
            
            self.cells = [initialCell]
            self.selectedCell = initialCell
            
            return
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let cellsCopy = cells.map { $0.copy() } as? [CollageCell]
        
        return Collage(cells: cellsCopy ?? [])
    }
    
    func fill(with images: [UIImage]) {
        for (cell, image) in zip(cells, images) {
            addImage(image, to: cell)
        }
    }
    
    func deleteImages() {
        cells.forEach { $0.deleteImage() }
    }
    
    func reset() {
        cells.removeAll()
        delegate?.collageChanged()
    }
    
    func setSelected(cell: CollageCell) {
        selectedCell = cellWith(id: cell.id) ?? .zeroFrame
        delegate?.collage(self, didChangeSelected: selectedCell)
    }
    
    func deleteSelectedCell() {
        delete(selectedCell)
    }
    
    func splitSelectedCell(by axis: Axis) {
        split(cell: selectedCell, by: axis)
    }
    
    func addImageToSelectedCell(_ image: UIImage) {
        addImage(image, to: selectedCell)
    }
    
    func changeSizeOfSelectedCell(grip: GripPosition, value: CGFloat) {
        changeSize(of: selectedCell, grip: grip, value: value)
    }
    
    func delete(_ cell: CollageCell) {
        for position in cell.gripPositions {
            if merge(cell: cell, grip: position, value: position.sideChangeValue(for: cell.relativeFrame)) { break}
        }
    }
    
    func addImageToFreeCell(image: UIImage) {
        guard let cell = cells.first(where: { $0.image == nil }) else {
            return
        }
        
        cell.addImage(image)
    }
    
    func addImage(_ image: UIImage, to cell: CollageCell) {
        cell.addImage(image)
        
        delegate?.collage(self, didUpdate: cell)
    }
    
    func split(cell: CollageCell, by axis: Axis) {
        let (firstFrame, secondFrame) = cell.relativeFrame.split(axis: axis)
        
        let firstCell = CollageCell(color: cell.color, image: cell.image, relativeFrame: firstFrame)
        let secondCell = CollageCell(color: .random, image: nil, relativeFrame: secondFrame)
        
        if firstCell.isAllowed(firstFrame) && secondCell.isAllowed(secondFrame) {
            add(cell: firstCell)
            add(cell: secondCell)
            remove(cell: cell)
            setSelected(cell: secondCell)
            
            delegate?.collageChanged()
        }
    }
    
    func changeSize(cell: CollageCell, grip: GripPosition, value: CGFloat) {
        changeSize(of: cell, grip: grip, value: value, merging: false)
    }
    
    private func changeSize(of cell: CollageCell, grip: GripPosition, value: CGFloat, merging: Bool = false) {
        cellsBeforeChanging = cells.map { $0.copy() } as? [CollageCell] ?? []
        calculateCellsNewFrame(cell: cell, grip: grip, value: value)
        
        let permisionsToChangePosition = cells.map { $0.isAllowed($0.relativeFrame) }.reduce (true, { $0 && $1 })
        
        guard isFullsized && permisionsToChangePosition else {
            restoreCellsBeforeChanging()
            delegate?.collageChanged()
            
            return
        }
        
        delegate?.collage(self, didChangeFramesFor: cells)
    }
    
    private func restoreCellsBeforeChanging() {
        cells = cellsBeforeChanging
        setSelected(cell: selectedCell)
    }

    private func merge(cell: CollageCell, grip: GripPosition, value: CGFloat, merging: Bool = false) -> Bool {
        cellsBeforeChanging = cells.map { $0.copy() } as? [CollageCell] ?? []
        remove(cell: cell)
        
        calculateCellsNewFrame(cell: cell, grip: grip, value: value, merging: true)
        
        if isFullsized {
            delegate?.collageChanged()
            setSelected(cell: cells.last ?? .zeroFrame)
            
            return true
        } else {
            restoreCellsBeforeChanging()
            
            return false
        }
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
    
    var selectedCell: CollageCell
    private(set) var cells: [CollageCell]
    private var cellsBeforeChanging: [CollageCell] = []
    private var recentlyDeleted: CollageCell?
}


extension Collage {
    
    var isFullsized: Bool {
        let collageArea = RelativeFrame.fullsized.area
        let cellsArea = cells.map { $0.relativeFrame.area }.reduce(0.0, { $0 + $1 })
        let cellsInBounds = cells.map { $0.relativeFrame.isInBounds(.fullsized) }.reduce(true, {$0 && $1 })
        
        return cellsInBounds && collageArea.isApproximatelyEqual(to: cellsArea)
    }

    func contains(cell: CollageCell) -> Bool {
        return cells.contains(cell)
    }
    
    func maxFrameCell() -> CollageCell? {
        return cells.sorted { $1.relativeFrame.area > $0.relativeFrame.area }.first
    }
    
    func randomCell() -> CollageCell? {
        let random = Int(arc4random_uniform(UInt32(cells.count)))
        
        return cells[random]
    }
    
    func cellWith(id: UUID) -> CollageCell? {
        return cells.first(where: { $0.id == id })
    }
    
    func cell(at relativePoint: CGPoint) -> CollageCell? {
        return cells.first(where: { $0.relativeFrame.contains(relativePoint) })
    }
    
    func check(_ gripPosition: GripPosition, in cell: CollageCell) -> Bool {
        return cell.gripPositions.contains(gripPosition)
    }
    
    static func ==(lhs: Collage, rhs: Collage) -> Bool {
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
        recentlyDeleted = cell
        cells = cells.filter { $0.id != cell.id }
    }
    
    private func update(cell: CollageCell) {
        remove(cell: cell)
        add(cell: cell)
    }
    
    private func cellsLayingOnLine(with cell: CollageCell, gripPosition: GripPosition) -> [CollageCell] {
        return cells.filter { $0.belongsToParallelLine(on: gripPosition.axis, with: gripPosition.centerPoint(in: cell)) }
    }
    
    private func cellIntersected(with cell: CollageCell, gripPosition: GripPosition) -> [CollageCell] {
        return cells.filter({ $0 != cell }).compactMap { (newcell) -> CollageCell? in
            return newcell.relativeFrame.intersects(rect2: cell.relativeFrame, on: gripPosition) ? newcell : nil
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
