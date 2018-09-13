//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import SnapKit

protocol CollageViewDelegate: AnyObject {
    func collageView(_ collageView: CollageView, tapped point: CGPoint)
}

class CollageView: UIView {
    
    weak var delegate: CollageViewDelegate?
    
    init() {
        super.init(frame: .zero)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pointTapped(with:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        showGrips()
    }
 
    func updateFrames() {
        cellViews.forEach{ $0.changeFrame(to: $0.collageCell.relativeFrame.absolutePosition(in: self.bounds)) }
        gripViews.forEach { $0.layout() }
    }
    
    func updateCollage(_ collage: Collage) {
        subviews.forEach { $0.removeFromSuperview() }
        
        cellViews = collage.cells.map { CollageCellView(collageCell: $0, frame: $0.relativeFrame.absolutePosition(in: self.bounds)) }
        cellViews.forEach { addSubview($0) }
        
        if let cell = collageCellView(with: collage.selectedCell.id) {
            select(cellView: cell)
        }
    }
    
    func updateSelectedCellView(with collageCell: CollageCell) {
        selectedCellView.updateCollageCell(collageCell)
    }
    
    func select(cellView: CollageCellView) {
        selectedCellView.layer.borderWidth = 0
        selectedCellView = cellView
        selectedCellView.layer.borderWidth = 2
        selectedCellView.layer.borderColor = UIColor.brightLavender.cgColor
    
        showGrips()
    }
    
    func collageCellView(with id: UUID) -> CollageCellView? {
        return cellViews.first(where: { $0.collageCell.id == id })
    }
    
    func gripPosition(in frame: CGRect) -> GripPosition? {
        return gripViews.first { $0.frame.intersects(frame) }?.position
    }
    
    private func showGrips() {
        gripViews.forEach { $0.removeFromSuperview() }
        gripViews = []
        
        selectedCellGripPositions?.forEach(layoutGripView(for: ))
    }
    
    private func layoutGripView(for position: GripPosition) {
        let gripView = GripView(with: position, in: selectedCellView)
        
        addSubview(gripView)
        gripViews.append(gripView)
    }
    
    @objc private func pointTapped(with recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        
        delegate?.collageView(self, tapped: point)
    }
    
    private var selectedCellGripPositions: Set<GripPosition>? {
        return selectedCellView.collageCell.gripPositions
    }
    
    private var collage: Collage?
    private(set) var gripViews: [GripView] = []
    private(set) var cellViews: [CollageCellView] = []
    private(set) var selectedCellView = CollageCellView(collageCell: .zeroFrame, frame: .zero)
}
