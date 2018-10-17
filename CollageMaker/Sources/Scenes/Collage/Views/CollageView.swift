//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

protocol CollageViewDelegate: AnyObject {
    func collageViewPlusButtonTapped(_ collageView: CollageView)
}

class CollageView: UIView {
    weak var delegate: CollageViewDelegate?

    var collage: Collage? {
        didSet {
            guard let collage = collage else {
                return
            }

            collage == oldValue ? updateFrames() : updateCollage(collage)
        }
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    func saveCellsVisibleRect() {
        cellViews.forEach { collage?.updateImageVisibleRect($0.imageVisibleRect, in: $0.collageCell) }
    }

    func updateFrames() {
        guard let collage = collage else {
            return
        }

        cellViews.forEach {
            $0.updateCollageCell(collage.cellWith(id: $0.collageCell.id) ?? $0.collageCell)
            $0.changeFrame(to: $0.collageCell.relativeFrame.absolutePosition(in: self.bounds)) }
    }

    func updateCollage(_ collage: Collage) {
        cellViews.forEach { $0.removeFromSuperview() }
        cellViews = collage.cells.map { CollageCellView(collageCell: $0, frame: $0.relativeFrame.absolutePosition(in: self.bounds)) }
        cellViews.forEach { addSubview($0) }

        bringSubview(toFront: cellSelectionView)

        if let id = selectedCellView?.collageCell.id, let cell = collageCellView(with: id) {
            select(cellView: cell)
        } else {
            selectedCellView = nil
            cellSelectionView.hidePlusButton()
        }
    }

    func select(cellView: CollageCellView?) {
        selectedCellView = cellView

        guard let selectedCellView = selectedCellView else {
            return
        }

        cellSelectionView.gripPositions = selectedCellView.collageCell.gripPositions
        selectedCellView.collageCell.image == nil ? cellSelectionView.showPlusButton() : cellSelectionView.hidePlusButton()

        cellSelectionView.snp.remakeConstraints { make in
            make.edges.equalTo(selectedCellView)
        }
    }

    func collageCellView(with id: UUID) -> CollageCellView? {
        return cellViews.first(where: { $0.collageCell.id == id })
    }

    func gripPosition(at point: CGPoint) -> GripPosition? {
        let tapPoint = convert(point, to: cellSelectionView)

        return cellSelectionView.gripPosition(at: tapPoint)
    }

    func gripPosition(in rect: CGRect) -> GripPosition? {
        return cellSelectionView.gripPosition(in: rect)
    }

    private func setup() {
        clipsToBounds = true
        addSubview(cellSelectionView)
        cellSelectionView.addTargetToPlusButton(self, action: #selector(test), for: .touchUpInside)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pointTapped(with:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func test() {
        delegate?.collageViewPlusButtonTapped(self)
    }

    @objc private func pointTapped(with recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        let relativePoint = point.normalized(for: frame.size)

        selectedCell = collage?.cell(at: relativePoint)

        guard let cell = collageCellView(with: selectedCell?.id ?? UUID()) else {
            return
        }

        selectedCellView = cell
        select(cellView: selectedCellView)
    }

    private var selectedCell: CollageCell?
    private(set) var gripViews: [GripView] = []
    private(set) var cellViews: [CollageCellView] = []
    private(set) var selectedCellView: CollageCellView?
    private let cellSelectionView = CellSelectionView()
}
