//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

final class CellSelectionView: UIView {
    var gripPositions: Set<GripPosition> = [] {
        didSet {
            updateGripViews()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: .zero)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gripViews.forEach(layoutGripView(_:))
        borderLayer.frame = bounds
        borderLayer.path = CGPath(rect: bounds, transform: nil)
        plusButton.center = convert(center, from: superview)
    }

    func gripPosition(at point: CGPoint) -> GripPosition? {
        let sortedGrips = gripViews.sorted { $0.frame.center.distance(to: point) < $1.frame.center.distance(to: point) }

        if let checkPoint = sortedGrips.first?.frame.center, checkPoint.distance(to: point) < CGFloat(30.0) {
            return sortedGrips.first?.position
        } else {
            return nil
        }
    }

    func gripPosition(in frame: CGRect) -> GripPosition? {
        return gripViews.first { $0.frame.intersects(frame) }?.position
    }

    func addTargetToPlusButton(_ target: Any?, action: Selector, for event: UIControlEvents) {
        plusButton.addTarget(target, action: action, for: event)
    }

    func showPlusButton() {
        plusButton.center = plusButton.convert(center, from: superview)
        plusButton.bounds.size = CGSize(width: 50, height: 50)

        addSubview(plusButton)
        isUserInteractionEnabled = true
    }

    func hidePlusButton() {
        plusButton.removeFromSuperview()
        isUserInteractionEnabled = false
    }

    func showGrips() {
        updateGripViews()
    }

    func hideGrips() {
        gripViews.forEach { $0.removeFromSuperview() }
    }

    private func setup() {
        layer.addSublayer(borderLayer)
    }

    private func updateGripViews() {
        gripViews.forEach { $0.removeFromSuperview() }
        gripViews = gripPositions.map(GripView.init(with:))
        gripViews.forEach(addSubview)
    }

    func layoutGripView(_ gripView: GripView) {
        let verticalSize = CGSize(width: 6, height: bounds.height / 3)
        let horizontalSize = CGSize(width: bounds.width / 3, height: 6)

        switch gripView.position {
        case .left:
            gripView.center = CGPoint(x: 0, y: bounds.midY)
            gripView.bounds.size = verticalSize
        case .right:
            gripView.center = CGPoint(x: bounds.width, y: bounds.midY)
            gripView.bounds.size = verticalSize
        case .top:
            gripView.center = CGPoint(x: bounds.midX, y: 0)
            gripView.bounds.size = horizontalSize
        case .bottom:
            gripView.center = CGPoint(x: bounds.midX, y: bounds.height)
            gripView.bounds.size = horizontalSize
        }
    }

    private var gripViews: [GripView] = []
    private let borderLayer = CAShapeLayer.cellBorder
    private let plusButton = PlusButton()
}

private extension CAShapeLayer {
    static var cellBorder: CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.brightLavender.cgColor
        layer.lineWidth = 2
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }
}
