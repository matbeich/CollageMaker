//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

protocol CollageViewControllerDelegate: AnyObject {
    func collageViewController(_ controller: CollageViewController, changed cellsCount: Int)
}

class CollageViewController: UIViewController {
    
    weak var delegate: CollageViewControllerDelegate?
    
    var collage: Collage = Collage() {
        didSet {
            updateCollage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(changeSize(with:)))
        
        collageView.delegate = self
        
        view.addSubview(collageView)
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func saveCellsVisibleRect() {
        collageView.saveCellsVisibleRect()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collageView.frame = view.bounds
        
        if shouldBeUpdated {
            updateCollage()
            shouldBeUpdated = false
        }
    }
    
    func resetCollage() {
        collage.reset()
    }
    
    func deleteSelectedCell() {
        saveCellsVisibleRect()
        collage.deleteSelectedCell()
    }
    
    func addImageToSelectedCell(_ image: UIImage) {
        collage.addImageToSelectedCell(image)
    }
    
    func splitSelectedCell(by axis: Axis) {
        saveCellsVisibleRect()
        collage.splitSelectedCell(by: axis)
    }
    
    @objc private func changeSize(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            selectedGripPosition = collageView.gripPosition(for: recognizer.location(in: view))
            
        case .changed:
            guard let grip = selectedGripPosition else {
                return
            }
            
            let translation = recognizer.translation(in: view).normalized(for: view.bounds.size)
            recognizer.setTranslation(.zero, in: view)
            
            let sizeChange = grip.axis == .horizontal ? translation.y : translation.x
            collage.changeSizeOfSelectedCell(grip: grip, value: sizeChange)
            
        case .ended, .cancelled:
            selectedGripPosition = nil
            
        default: break
        }
    }

     func updateCollage() {
        collage.delegate = self
        
        if isViewLoaded {
            collageView.updateCollage(collage)
        }
    }
    
    private var shouldBeUpdated: Bool = true
    private let collageView = CollageView()
    private var selectedGripPosition: GripPosition?
}


extension CollageViewController: CollageViewDelegate {
    func collageView(_ collageView: CollageView, tapped point: CGPoint) {
        let relativePoint = point.normalized(for: collageView.frame.size)
        
        collage.cell(at: relativePoint).flatMap {
            collage.setSelected(cell: $0)
        }
    }
}

extension CollageViewController: CollageDelegate {
    func collage(_ collage: Collage, didChange cellsCount: Int) {
        delegate?.collageViewController(self, changed: cellsCount)
    }
    
    func collage(_ collage: Collage, didChangeSelected cell: CollageCell) {
        guard let selectedCellView = collageView.collageCellView(with: cell.id) else {
            return
        }
        
        collageView.select(cellView: selectedCellView)
    }
    
    func collage(_ collage: Collage, didUpdate cell: CollageCell) {
        collageView.updateSelectedCellView(with: cell)
    }
    
    func collage(_ collage: Collage, didChangeFramesFor cells: [CollageCell]) {
        saveCellsVisibleRect()
        collageView.updateFrames()
    }
    
    func collageChanged() {
        updateCollage()
    }
}

extension CGPoint {
    func normalized(for size: CGSize) -> CGPoint {
        return CGPoint(x: x / size.width, y: y / size.height)
    }
}
