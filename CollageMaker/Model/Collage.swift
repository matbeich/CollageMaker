//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//
import UIKit

enum Axis {
    case horizontal
    case vertical
}

protocol CollageDelegate: AnyObject {
    func collageChanged(to collage: Collage)
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
    
    func reset() {
        cells.removeAll()
        delegate?.collageChanged(to: self)
    }
    
    func setSelected(cell: CollageCell) {
        selectedCell = cellWith(id: cell.id) ?? .zeroFrame
        delegate?.collage(self, didChangeSelected: selectedCell)
    }
    
    func deleteSelectedCell() {
        for position in selectedCell.gripPositions {
            if merge(grip: position, value: position.sideChangeValue(for: selectedCell.relativeFrame)) { break }
        }
    }
    
    func addImageToSelectedCell(_ image: UIImage) {
        selectedCell.addImage(image)
        update(cell: selectedCell)
        
        delegate?.collage(self, didUpdate: selectedCell)
    }
    
    func splitSelectedCell(by axis: Axis) {
        let (firstFrame, secondFrame) = selectedCell.relativeFrame.split(axis: axis)
        
        let firstCell =  CollageCell(color: selectedCell.color, image: selectedCell.image, relativeFrame: firstFrame)
        let secondCell = CollageCell(color: .random, image: nil, relativeFrame: secondFrame)
        
        if firstCell.isAllowed(firstFrame) && secondCell.isAllowed(secondFrame) {
            add(cell: firstCell)
            add(cell: secondCell)
            remove(cell: selectedCell)
            setSelected(cell: secondCell)
            
            delegate?.collageChanged(to: self)
        }
    }
    
    func changeSize(grip: GripPosition, value: CGFloat, merging: Bool = false) {
        calculateCellsNewFrame(grip: grip, value: value)
        guard isFullsized else {
            cells.forEach { $0.setLastProperRelativeFrame() }
            return
        }
        
        delegate?.collage(self, didChangeFramesFor: cells)
    }
    
    private func merge(grip: GripPosition, value: CGFloat, merging: Bool = false) -> Bool {
        lastProperCells = cells.map { $0.copy() } as? [CollageCell]
        remove(cell: selectedCell)
        
        calculateCellsNewFrame(grip: grip, value: value, merging: true)
        
        if isFullsized {
            delegate?.collageChanged(to: self)
            setSelected(cell: cells.last ?? .zeroFrame)
            return true
        } else {
            cells = lastProperCells ?? []
            setSelected(cell: selectedCell)
        
            return false
        }
    }
    
    private func cellWith(id: UUID) -> CollageCell? {
        return cells.first(where: { $0.id == id })
    }
    
    private func calculateCellsNewFrame(grip: GripPosition, value: CGFloat, merging: Bool = false) {
        let changingCells = affectedCells(with: grip, merging: merging)
        
        guard changingCells.count > 0, check(grip, in: selectedCell) else {
            return
        }
        
        changingCells.forEach {
            let changeGrip = $0.gripPositionRelativeTo(cell: selectedCell, grip)
            $0.changeRelativeFrame(for: value, with: changeGrip)
            $0.calculateGripPositions()
        }
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
    
    func copy(with zone: NSZone? = nil) -> Any {
        let cellsCopy = cells.map { $0.copy() } as? [CollageCell]
        
        return Collage(cells: cellsCopy ?? [])
    }
    
    var selectedCell: CollageCell
    private(set) var cells: [CollageCell]
    private var lastProperCells: [CollageCell]? = []
    private var recentlyDeleted: CollageCell?
}


extension Collage {
    
    var isFullsized: Bool {
        let collageArea = RelativeFrame.fullsized.area
        let cellsArea = cells.map { $0.relativeFrame.area }.reduce(0.0, { $0 + $1 })
        let cellsInBounds = cells.map { $0.relativeFrame.isInBounds(.fullsized) }.reduce(true, {$0 && $1 })
        
        return cellsInBounds && collageArea.isApproximatelyEqual(to: cellsArea)
    }
    
    func cell(at relativePoint: CGPoint) -> CollageCell? {
        return cells.first(where: { $0.relativeFrame.contains(relativePoint) })
    }
    
    static func ==(lhs: Collage, rhs: Collage) -> Bool {
        return lhs.cells == rhs.cells
    }
    
    private func check(_ gripPosition: GripPosition, in cell: CollageCell) -> Bool {
        return cell.gripPositions.contains(gripPosition)
    }
    
    private func cellsLayingOnLine(with gripPosition: GripPosition) -> [CollageCell] {
        return cells.filter { $0.belongsToParallelLine(on: gripPosition.axis, with: gripPosition.centerPoint(in: selectedCell)) }
    }
    
    private func cellIntersected(with gripPosition: GripPosition) -> [CollageCell] {
        return cells.filter({ $0 != selectedCell }).compactMap { (cell) -> CollageCell? in
            return cell.relativeFrame.intersects(rect2: selectedCell.relativeFrame, on: gripPosition) ? cell : nil
        }
    }
    
    private func affectedCells(with grip: GripPosition, merging: Bool) -> [CollageCell] {
        var changingCells: [CollageCell]
        
        if merging {
            changingCells = cellIntersected(with: grip)
        } else {
            let intersectedCells = Set(cellIntersected(with: grip))
            let layingOnLineCells = Set(cellsLayingOnLine(with: grip))
            
            changingCells = Array(layingOnLineCells.intersection(intersectedCells))
            
            if changingCells.count == 1, let firstCell = changingCells.first, firstCell.relativeFrame.equallyIntersects(rect2: selectedCell.relativeFrame, on: grip) {
                changingCells.append(selectedCell)
            } else {
                changingCells = cellsLayingOnLine(with: grip)
            }
        }
        
        return changingCells
    }
}
