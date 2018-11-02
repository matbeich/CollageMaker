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

    var collage: Collage {
        didSet {
            let shouldSetNewCollage = collage.cells.count != oldValue.cells.count ||
                !collage.hasSameImages(with: oldValue)

            if shouldSetNewCollage {
                update(collage)
            } else if !collage.hasSameCellsFrames(with: oldValue) {
                updateFrames()
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
        cellViews.forEach { cellView in
            let frame = cellView.collageCell.relativeFrame.absolutePosition(in: bounds)

            if cellView.frame != frame {
                cellView.frame = frame
            }
        }
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

    @objc private func pointTapped(with recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)

        guard let cell = collageCellView(at: point) else {
            return
        }

        select(cellView: cell)
    }

    private func setup() {
        clipsToBounds = true
        addSubview(cellSelectionView)
        accessibilityIdentifier = Accessibility.View.collageView.id
        cellSelectionView.addTargetToPlusButton(self, action: #selector(buttonTapped), for: .touchUpInside)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pointTapped(with:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    private func updateFrames() {
        cellViews.forEach {
            $0.updateCollageCell(collage.cellWith(id: $0.collageCell.id) ?? $0.collageCell)
            $0.changeFrame(for: bounds)
        }
    }

    private var shouldUpdate = true
    private(set) var gripViews: [GripView] = []
    private(set) var cellViews: [CollageCellView] = []
    private(set) var selectedCellView: CollageCellView
    private let cellSelectionView = CellSelectionView()
}
