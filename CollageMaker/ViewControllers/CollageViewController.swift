//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

protocol CollageViewControllerDelegate: AnyObject {
    func collageViewController(_ controller: CollageViewController, didSelect cell: CollageCell)
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
        
        updateCollage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collageView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCollage()
    }
    
    func resetCollage() {
        collage.reset()
    }
    
    func deleteSelectedCell() {
        collage.deleteSelectedCell()
    }
    
    func addImageToSelectedCell(_ image: UIImage) {
        collage.addImageToSelectedCell(image)
    }
    
    func splitSelectedCell(by axis: Axis) {
        collage.splitSelectedCell(by: axis)
    }
    
    @objc private func changeSize(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let point = recognizer.location(in: view)
            let frame = CGRect(x: point.x - 20, y: point.y - 20, width: 40, height: 40)
            selectedGripPosition = collageView.gripPosition(in: frame)
            
        case .changed:
            guard let grip = selectedGripPosition else {
                return
            }
            
            let translation = recognizer.translation(in: view).normalized(for: view.bounds.size)
            recognizer.setTranslation(.zero, in: view)
            
            let sizeChange = grip.axis == .horizontal ? translation.y : translation.x
            collage.changeSelectedCellSize(grip: grip, value: sizeChange)
            
        case .ended, .cancelled:
            selectedGripPosition = nil
            
        default: break
        }
    }

    private func updateCollage() {
        collage.delegate = self
        
        if isViewLoaded {
            collageView.setCollage(collage)
        }
    }
    
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
    
    func collageChanged(to collage: Collage) {
        self.collage = collage
    }
    
    func collage(_ collage: Collage, changed state: CollageState) {
        collageView.changeFrames(from: state)
    }
    
    func collage(_ collage: Collage, updated cell: CollageCell) {
        collageView.updateSelectedCellView(with: cell)
    }
    
    func collage(_ collage: Collage, didChangeSelected cell: CollageCell) {
        guard let selectedCellView = collageView.collageCellView(with: cell.id) else {
            return
        }
        
        collageView.select(cellView: selectedCellView)
    }
}

extension CGPoint {
    func normalized(for size: CGSize) -> CGPoint {
        return CGPoint(x: x / size.width, y: y / size.height)
    }
}
