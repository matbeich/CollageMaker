//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit

protocol CollageViewControllerDelegate: AnyObject {
    func collageViewControllerPlusButtonTapped(_ controller: CollageViewController)
    func collageViewController(_ controller: CollageViewController, didDeleteCellView cellView: CollageCellView)
    func collageViewController(_ controller: CollageViewController, didRestoreCellView cellView: CollageCellView)
}

class CollageViewController: CollageBaseViewController {
    weak var delegate: CollageViewControllerDelegate?

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

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(changeSize(with:)))
        panGestureRecognizer.delegate = self

        collageView.delegate = self

        view.addSubview(collageView)
        view.addGestureRecognizer(panGestureRecognizer)
    }

    func saveCellsVisibleRect() {
        collageView.setCellsVisibleRect()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collageView.frame = view.bounds

        if shouldBeUpdated {
            updateCollage()
            shouldBeUpdated = false
        }
    }

    func deleteSelectedCell() {
        guard collage.canDeleteCells else {
            return
        }

        saveCellsVisibleRect()
        collage.delete(selectedCellView.collageCell)
        delegate?.collageViewController(self, didDeleteCellView: selectedCellView)
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

            let translation = recognizer.translation(in: view).normalized(for: view.bounds.size)
            recognizer.setTranslation(.zero, in: view)

            let sizeChange = grip.axis == .horizontal ? translation.y : translation.x

            collage.changeSize(cell: selectedCellView.collageCell, grip: grip, value: sizeChange)

        case .ended, .cancelled:
            selectedGripPosition = nil

        default: break
        }
    }

    func updateCollage() {
        if isViewLoaded {
            collageView.collage = collage
        }
    }

    private let collageView = CollageView()
    private var shouldBeUpdated: Bool = true
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

extension CGPoint {
    func normalized(for size: CGSize) -> CGPoint {
        return CGPoint(x: x / size.width, y: y / size.height)
    }
}
