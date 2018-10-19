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
        self.selectedCellView = cellViews.last ?? CollageCellView(collageCell: .zeroFrame, frame: .zero)
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

        if let cell = collageCellView(with: selectedCellView.collageCell.id) {
            select(cellView: cell)
        } else {
            select(cellView: cellViews.last)
        }
    }

    func select(cellView: CollageCellView?) {
        guard let cellView = cellView else {
            return
        }

        selectedCellView = cellView
        cellSelectionView.gripPositions = selectedCellView.collageCell.gripPositions
        selectedCellView.collageCell.image == nil ? cellSelectionView.showPlusButton() : cellSelectionView.hidePlusButton()

        cellSelectionView.snp.remakeConstraints { make in
            make.edges.equalTo(selectedCellView)
        }
    }

    func collageCellView(at point: CGPoint) -> CollageCellView? {
        return cellViews.first(where: { $0.frame.contains(point) })
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
        accessibilityIdentifier = Accessibility.View.collageView.id
        cellSelectionView.addTargetToPlusButton(self, action: #selector(test), for: .touchUpInside)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pointTapped(with:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func test() {
        delegate?.collageViewPlusButtonTapped(self)
    }

    @objc private func pointTapped(with recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)

        guard let cell = collageCellView(at: point) else {
            return
        }

        select(cellView: cell)
    }

    private(set) var gripViews: [GripView] = []
    private(set) var cellViews: [CollageCellView] = []
    private(set) var selectedCellView: CollageCellView
    private let cellSelectionView = CellSelectionView()
}
