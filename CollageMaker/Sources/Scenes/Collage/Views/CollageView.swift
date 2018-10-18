//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

protocol CollageViewDelegate: AnyObject {
    func collageView(_ collageView: CollageView, tapped point: CGPoint)
    func collageViewPlusButtonTapped(_ collageView: CollageView)
}

class CollageView: UIView {
    weak var delegate: CollageViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    func saveCellsVisibleRect() {
        cellViews.forEach { $0.saveVisibleRect() }
    }

    func updateFrames() {
        cellViews.forEach { $0.changeFrame(to: $0.collageCell.relativeFrame.absolutePosition(in: self.bounds)) }
    }

    func updateCollage(_ collage: Collage) {
        cellViews.forEach { $0.removeFromSuperview() }
        cellViews = collage.cells.map { CollageCellView(collageCell: $0, frame: $0.relativeFrame.absolutePosition(in: self.bounds)) }
        cellViews.forEach { addSubview($0) }

        bringSubview(toFront: cellSelectionView)

        if let cell = collageCellView(with: collage.selectedCell.id) {
            select(cellView: cell)
        }
    }

    func updateSelectedCellView(with collageCell: CollageCell) {
        selectedCellView.updateCollageCell(collageCell)
        selectedCellView.collageCell.image == nil ? cellSelectionView.showPlusButton() : cellSelectionView.hidePlusButton()
    }

    func select(cellView: CollageCellView) {
        selectedCellView = cellView
        cellSelectionView.gripPositions = selectedCellView.collageCell.gripPositions
        cellView.collageCell.image == nil ? cellSelectionView.showPlusButton() : cellSelectionView.hidePlusButton()

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
        delegate?.collageView(self, tapped: point)
    }

    private var collage: Collage?
    private let cellSelectionView = CellSelectionView()
    private(set) var gripViews: [GripView] = []
    private(set) var cellViews: [CollageCellView] = []
    private(set) var selectedCellView = CollageCellView(collageCell: .zeroFrame, frame: .zero)
}
