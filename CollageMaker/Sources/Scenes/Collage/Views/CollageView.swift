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
    
    var isModifyingCellViews: Bool = false

    var collage: Collage {
        didSet {
            let shouldSetNewCollage = collage.cells.count != oldValue.cells.count ||
                !collage.hasSameImages(with: oldValue) ||
                isModifyingCellViews

            if shouldSetNewCollage {
                update(collage)
                print("update collage")
            } else if !collage.hasSameCellsFrames(with: oldValue) {
                updateFrames()
                print("update frames")
            }
        }
    }

    init(frame: CGRect = .zero, collage: Collage = Collage()) {
        self.selectedCellView = cellViews.last ?? CollageCellView(collageCell: .zeroFrame, frame: .zero)
        self.collage = collage
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutCellsIfNeeded()
    }

    func saveCellsVisibleFrames() {
        cellViews.forEach {
            collage.updateImageVisibleRect($0.imageVisibleRect, in: $0.collageCell)
        }
    }

    func layoutCellsIfNeeded() {
        if isModifyingCellViews {
            return
        }

        cellViews.forEach { cellView in
            let frame = cellView.collageCell.relativeFrame.absolutePosition(in: bounds)

            if cellView.frame != frame {
                cellView.frame = frame
            }
        }
    }

    func highlightCellView(_ cellView: CollageCellView) {
        guard let cellView = cellViews.first(where: { $0 == cellView }) else {
            return
        }

        cellView.frame = cellView.frame.applying(CGAffineTransform(scaleX: 0.8, y: 0.8))
        bringSubview(toFront: cellView)
        bringSubview(toFront: cellSelectionView)
    }

    func intersectedCellView(with cellView: CollageCellView) -> CollageCellView? {
        return cellViews.first(where: { $0 != cellView && ($0.frame.intersection(cellView.frame).area / $0.frame.area) > 0.3 })
    }

    func restorePositionOf(_ cellView: CollageCellView) {
        guard let cellView = cellViews.first(where: { $0 == cellView }) else {
            return
        }

        cellView.frame = cellView.collageCell.relativeFrame.absolutePosition(in: bounds)
    }

    func update(_ collage: Collage) {
        cellViews.forEach { $0.removeFromSuperview() }
        cellViews = collage.cells.map { CollageCellView(collageCell: $0, frame: $0.relativeFrame.absolutePosition(in: self.bounds)) }
        cellViews.forEach { addSubview($0) }

        bringSubview(toFront: cellSelectionView)

        if let cell = collageCellView(with: selectedCellView.collageCell.id) {
            select(cellView: cell)
        } else {
            select(cellView: cellViews.last ?? CollageCellView())
        }
    }

    func select(cellView: CollageCellView) {
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

    @objc private func buttonTapped() {
        delegate?.collageViewPlusButtonTapped(self)
    }

    private func setup() {
        clipsToBounds = true
        addSubview(cellSelectionView)
        accessibilityIdentifier = Accessibility.View.collageView.id
        cellSelectionView.addTargetToPlusButton(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    private func updateFrames() {
        cellViews.forEach {
            $0.updateCollageCell(collage.cellWith(id: $0.collageCell.id) ?? $0.collageCell)
            $0.changeFrame(for: bounds)
        }
    }

    private(set) var gripViews: [GripView] = []
    private(set) var cellViews: [CollageCellView] = []
    private(set) var selectedCellView: CollageCellView
    private let cellSelectionView = CellSelectionView()
}
