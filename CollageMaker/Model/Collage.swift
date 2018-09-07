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
    func collage(_ collage: Collage, changed state: CollageState)
    func collage(_ collage: Collage, updated cell: CollageCell)
}

class Collage: NSObject, NSCopying {
   
    weak var delegate: CollageDelegate?
    
    init(cells: [CollageCell] = []) {
        self.cells = cells
        self.selectedCell = cells.last ?? CollageCell.zeroFrame
        super.init()
        
        cells.forEach { initialState.cellsRelativeFrames[$0] = $0.relativeFrame }
        initialState.selectedCell = selectedCell
        
        guard isFullsized else {
            let initialCell = CollageCell(color: .collagePink, image: R.image.addimg(), relativeFrame: RelativeFrame.fullsized)
            
            self.cells = [initialCell]
            self.selectedCell = initialCell
            initialState = CollageState(cellsRelativeFrames: [initialCell: initialCell.relativeFrame], selectedCell: initialCell)
            
            return
        }
    }
    
    func setSelected(cell: CollageCell) {
        guard selectedCell.id != cell.id else {
            return
        }
        
        selectedCell = cells.first(where: { $0.id == cell.id }) ?? CollageCell.zeroFrame
        
        delegate?.collage(self, didChangeSelected: selectedCell)
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
    
    func deleteSelectedCell() {
        for position in selectedCell.gripPositions {
            if changeSelectedCellSize(grip: position, value: position.sideChangeValue(for: selectedCell.relativeFrame), merging: true) { break }
        }
    }
    
    func addImageToSelectedCell(_ image: UIImage) {
        selectedCell.addImage(image)
        update(cell: selectedCell)
        
        delegate?.collage(self, updated: selectedCell)
    }
    
    func reset() {
        cells.removeAll()
        delegate?.collageChanged(to: self)
    }
    
    @discardableResult
    func changeSelectedCellSize(grip: GripPosition, value: CGFloat, merging: Bool = false) -> Bool {
        let changingCells = affectedCells(with: grip, merging: merging)
        
        guard changingCells.count > 0, check(grip, in: selectedCell) else {
            return false
        }
        
        var startState = cells.map { $0.copy() } as? [CollageCell]
     
        changingCells.forEach {
            let changeGrip = $0.gripPositionRelativeTo(cell: selectedCell, grip)
            calculatePosition(of: $0, for: value, with: changeGrip)
        }
        
        if merging { remove(cell: selectedCell) }
        
        let permisionsToChangePosition = cells.map { $0.isAllowed($0.relativeFrame) }
        let shouldUpdate = isFullsized && permisionsToChangePosition.reduce (true, { $0 && $1 })
        
        guard shouldUpdate else {
            cells = startState!
            delegate?.collageChanged(to: self)
            
            return false
        }
        
        delegate?.collageChanged(to: self)
        
        return true
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
    private var initialState = CollageState()
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

    private func calculatePosition(of cell: CollageCell, for value: CGFloat, with gripPosition: GripPosition) {
        guard check(gripPosition, in: cell) else {
            return
        }
     
        switch gripPosition {
        case .left:
            cell.relativeFrame.origin.x += value
            cell.relativeFrame.size.width -= value
        case .right:
            cell.relativeFrame.size.width += value
        case .top:
            cell.relativeFrame.origin.y += value
            cell.relativeFrame.size.height -= value
        case .bottom:
            cell.relativeFrame.size.height += value
        }
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
