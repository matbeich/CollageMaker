//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit

protocol CollageViewControllerDelegate: AnyObject {
    func collageViewControllerPlusButtonTapped(_ controller: CollageViewController)
    func collageViewControllerDidRestoreCells(_ controller: CollageViewController)
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

        registerForPreviewing(with: self, sourceView: collageView)

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(changeSize(with:)))
        panGestureRecognizer.delegate = self

        collageView.delegate = self
        collageView.collage = collage

        view.addSubview(collageView)
        view.addGestureRecognizer(panGestureRecognizer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collageView.frame = view.bounds
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

    private var savedCollage: Collage?
    private var selectedGripPosition: GripPosition?
}

extension CollageViewController: CollageViewDelegate {
    func collageViewPlusButtonTapped(_ collageView: CollageView) {
        delegate?.collageViewControllerPlusButtonTapped(self)
    }
}

extension CollageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard collageView.gripPosition(at: gestureRecognizer.location(in: view)) != nil else {
            return false
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
