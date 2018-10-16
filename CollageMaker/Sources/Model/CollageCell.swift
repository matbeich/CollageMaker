//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit

typealias RelativeFrame = CGRect

struct CollageCell: Equatable, Hashable {
    var color: UIColor
    var imageVisibleRect: RelativeFrame = .zero

    init(color: UIColor = .random, image: UIImage? = nil, photoAsset: PHAsset? = nil, relativeFrame: RelativeFrame) {
        self.color = color
        self.image = image
        self.photoAsset = photoAsset
        self.relativeFrame = isAllowed(relativeFrame) ? relativeFrame : RelativeFrame.zero

        if let image = image {
            self.imageVisibleRect = self.relativeFrame.absolutePosition(in: CGRect(origin: .zero, size: image.size))
        }

        calculateGripPositions()
    }

    mutating func calculateGripPositions() {
        gripPositions.removeAll()

        guard relativeFrame.isFullsized == false else {
            return
        }

        if relativeFrame.minX > .allowableAccuracy { gripPositions.insert(.left) }
        if relativeFrame.minY > .allowableAccuracy { gripPositions.insert(.top) }
        if abs(relativeFrame.maxX - 1) > .allowableAccuracy { gripPositions.insert(.right) }
        if abs(relativeFrame.maxY - 1) > .allowableAccuracy { gripPositions.insert(.bottom) }
    }

    func belongsToParallelLine(on axis: Axis, with point: CGPoint) -> Bool {
        if axis == .horizontal {
            return point.y.isApproximatelyEqual(to: relativeFrame.minY) || point.y.isApproximatelyEqual(to: relativeFrame.maxY)
        } else {
            return point.x.isApproximatelyEqual(to: relativeFrame.minX) || point.x.isApproximatelyEqual(to: relativeFrame.maxX)
        }
    }

    func gripPositionRelativeTo(cell: CollageCell, _ gripPosition: GripPosition) -> GripPosition {
        guard cell != self else {
            return gripPosition
        }

        if gripPosition.axis == .horizontal {
            return self.relativeFrame.midY < gripPosition.centerPoint(in: cell).y ? .bottom : .top
        } else {
            return self.relativeFrame.midX < gripPosition.centerPoint(in: cell).x ? .right : .left
        }
    }

    func isAllowed(_ relativeFrame: RelativeFrame) -> Bool {
        guard relativeFrame.isInBounds(.fullsized) else {
            return false
        }

        return min(relativeFrame.width, relativeFrame.height).isGreaterOrApproximatelyEqual(to: 0.2) ? true : false
    }

    static func == (lhs: CollageCell, rhs: CollageCell) -> Bool {
        return lhs.hashValue == rhs.hashValue &&
            lhs.relativeFrame == rhs.relativeFrame &&
            lhs.gripPositions == rhs.gripPositions
    }

    var image: UIImage?
    var photoAsset: PHAsset?
    var relativeFrame = RelativeFrame.zero
    private(set) var gripPositions: Set<GripPosition> = []
}

extension CollageCell {
    static var zeroFrame: CollageCell {
        return CollageCell(color: .black, relativeFrame: .zero)
    }
}

enum GripPosition {
    case top
    case bottom
    case left
    case right

    var axis: Axis {
        switch self {
        case .left, .right: return .vertical
        case .top, .bottom: return .horizontal
        }
    }

    func centerPoint(in cell: CollageCell) -> CGPoint {
        switch self {
        case .left: return CGPoint(x: cell.relativeFrame.minX, y: cell.relativeFrame.midY)
        case .right: return CGPoint(x: cell.relativeFrame.maxX, y: cell.relativeFrame.midY)
        case .top: return CGPoint(x: cell.relativeFrame.midX, y: cell.relativeFrame.minY)
        case .bottom: return CGPoint(x: cell.relativeFrame.midX, y: cell.relativeFrame.maxY)
        }
    }

    func sideChangeValue(for position: RelativeFrame) -> CGFloat {
        switch self {
        case .left:
            return position.width
        case .right:
            return -position.width
        case .top:
            return position.height
        case .bottom:
            return -position.height
        }
    }
}
