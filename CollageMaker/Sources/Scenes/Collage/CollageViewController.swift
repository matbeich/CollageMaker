//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import SnapKit
import UIKit

protocol CollageViewControllerDelegate: AnyObject {
    func collageViewControllerPlusButtonTapped(_ controller: CollageViewController)
    func collageViewControllerDidRestoreCells(_ controller: CollageViewController)
    func collageViewControllerDidStartModifyingCellViews(_ controller: CollageViewController)
    func collageViewControllerDidEndModifyingCellViews(_ controller: CollageViewController)
    func collageViewController(_ controller: CollageViewController, didDeleteCellView cellView: CollageCellView)
}

class CollageViewController: CollageBaseViewController {
    weak var delegate: CollageViewControllerDelegate?

    let collageView = CollageView()

    var collage: Collage {
        get {
            return collageView.collage
        }
        set {
            collageView.collage = newValue
        }
    }

    var selectedCellView: CollageCellView {
        return collageView.selectedCellView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        view.addSubview(collageView)
        view.addGestureRecognizer(panGestureRecognizer)
        view.addGestureRecognizer(longPressRecognizer)
        view.addGestureRecognizer(tapGestureRecognizer)
        view.addGestureRecognizer(dragGestureRecognizer)

        collageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func saveCellsVisibleRect() {
        collageView.saveCellsVisibleFrames()
    }

    func undo() {
        if let collage = savedCollage {
            collageView.collage = collage
            collageView.update(collage)
            delegate?.collageViewControllerDidRestoreCells(self)
            savedCollage = nil
        }
    }

    func deleteSelectedCell() {
        guard collage.canDeleteCells else {
            return
        }

        delegate?.collageViewController(self, didDeleteCellView: selectedCellView)
        saveCellsVisibleRect()
        savedCollage = collage
        collage.delete(selectedCellView.collageCell)
    }

    func addAbstractPhotoToSelectedCell(_ abstractPhoto: AbstractPhoto) {
        collage.add(abstractPhoto, to: selectedCellView.collageCell)
    }

    func splitSelectedCell(by axis: Axis) {
        saveCellsVisibleRect()
        collage.split(cell: selectedCellView.collageCell, by: axis)
    }

    private func setup() {
        registerForPreviewing(with: self, sourceView: collageView)

        panGestureRecognizer.addTarget(self, action: #selector(changeSize(with:)))
        panGestureRecognizer.canBePrevented(by: dragGestureRecognizer)
        panGestureRecognizer.delegate = self

        longPressRecognizer.addTarget(self, action: #selector(recognizeLongPress(with:)))
        longPressRecognizer.minimumPressDuration = 0.7
        longPressRecognizer.delegate = self

        tapGestureRecognizer.addTarget(self, action: #selector(pointTapped(with:)))
        tapGestureRecognizer.delegate = self

        dragGestureRecognizer.addTarget(self, action: #selector(drag(with:)))
        dragGestureRecognizer.delegate = self

        collageView.delegate = self
        collageView.collage = collage
    }

    @objc private func drag(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            let translation = recognizer.translation(in: collageView)
            recognizer.setTranslation(.zero, in: collageView)

            selectedCellView.frame.origin = CGPoint(x: collageView.selectedCellView.frame.origin.x + translation.x,
                                                    y: collageView.selectedCellView.frame.origin.y + translation.y)

            if let cellView = collageView.collageCellViewIntersected(with: selectedCellView) {
                if highlightedView != cellView {
                    highlightedView?.selected = false
                    highlightedView = cellView
                    highlightedView?.selected = true
                }
            } else {
                highlightedView?.selected = false
                highlightedView = nil
            }
        case .ended, .cancelled, .failed:
            collageView.restorePositionOf(selectedCellView)

            if let highlightedCell = highlightedView {
                highlightedCell.selected = false
                collage.switchCell(selectedCellView.collageCell, with: highlightedCell.collageCell)
            }

            collageView.isModifyingCellViews = false
            delegate?.collageViewControllerDidEndModifyingCellViews(self)
        default: break
        }
    }

    @objc private func recognizeLongPress(with recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            guard let cellView = collageView.collageCellView(at: recognizer.location(in: collageView)) else {
                return
            }

            longPressHappened = true
            collageView.isModifyingCellViews = true
            collageView.select(cellView: cellView)
            collageView.highlightCellView(selectedCellView)
            delegate?.collageViewControllerDidStartModifyingCellViews(self)

        case .ended, .cancelled, .failed:
            longPressHappened = false
            collageView.restorePositionOf(selectedCellView)

        default: break
        }
    }

    @objc private func changeSize(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            selectedGripPosition = collageView.gripPosition(at: recognizer.location(in: view))

        case .changed:
            guard let grip = selectedGripPosition else {
                return
            }

            saveCellsVisibleRect()
            let translation = recognizer.translation(in: view).normalized(for: view.bounds.size)
            recognizer.setTranslation(.zero, in: view)

            let sizeChange = grip.axis == .horizontal ? translation.y : translation.x

            collage.changeSize(cell: selectedCellView.collageCell, grip: grip, value: sizeChange)

        case .ended, .cancelled:
            selectedGripPosition = nil

        default: break
        }
    }

    @objc private func pointTapped(with recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: collageView)

        guard let cell = collageView.collageCellView(at: point) else {
            return
        }

        collageView.select(cellView: cell)
    }

    private var longPressHappened: Bool = false
    private var savedCollage: Collage?
    private var selectedGripPosition: GripPosition?
    private var highlightedView: CollageCellView?
    private let panGestureRecognizer = UIPanGestureRecognizer()
    private let dragGestureRecognizer = UIPanGestureRecognizer()
    private let tapGestureRecognizer = UITapGestureRecognizer()
    private let longPressRecognizer = UILongPressGestureRecognizer()
}

extension CollageViewController: CollageViewDelegate {
    func collageViewPlusButtonTapped(_ collageView: CollageView) {
        delegate?.collageViewControllerPlusButtonTapped(self)
    }
}

extension CollageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == longPressRecognizer && otherGestureRecognizer == dragGestureRecognizer {
            return true
        }

        guard collageView.gripPosition(at: gestureRecognizer.location(in: view)) != nil else {
            return false
        }

        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == dragGestureRecognizer {
            return longPressHappened
        }

        return true
    }
}

extension CollageViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let cellView = collageView.collageCellView(at: location),
            let img = cellView.collageCell.image
        else {
            return nil
        }

        collageView.select(cellView: cellView)
        previewingContext.sourceRect = cellView.frame
        let previewController = PreviewViewController(image: img)
        previewController.delegate = self

        return previewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true)
    }
}

extension CollageViewController: PreviewViewControllerDelegate {
    func previewViewController(_ controller: PreviewViewController, didChooseAction action: PreviewViewController.Action) {
        controller.dismiss(animated: true)

        if action == .delete {
            deleteSelectedCell()
        }
    }
}

extension CGPoint {
    func normalized(for size: CGSize) -> CGPoint {
        return CGPoint(x: x / size.width, y: y / size.height)
    }
}
