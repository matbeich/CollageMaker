//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit

typealias RelativeFrame = CGRect

class CollageCell: NSObject, NSCopying {
    var color: UIColor
    var imageVisibleRect: RelativeFrame = .zero

    func copy(with zone: NSZone? = nil) -> Any {
        return CollageCell(color: color, image: image, photoAsset: photoAsset, relativeFrame: relativeFrame, id: id, imageVisibleRect: imageVisibleRect)
    }

    init(color: UIColor = .random, image: UIImage? = nil, photoAsset: PHAsset? = nil, relativeFrame: RelativeFrame) {
        self.color = color
        self.image = image
        self.photoAsset = photoAsset
        self.id = UUID()

        super.init()
        self.relativeFrame = isAllowed(relativeFrame) ? relativeFrame : RelativeFrame.zero

        if let image = image {
            self.imageVisibleRect = self.relativeFrame.absolutePosition(in: CGRect(origin: .zero, size: image.size))
        }

        calculateGripPositions()
    }

    private convenience init(color: UIColor, image: UIImage?, photoAsset: PHAsset?, relativeFrame: CGRect, id: UUID, imageVisibleRect: RelativeFrame) {
        self.init(color: color, image: image, relativeFrame: relativeFrame)
        self.id = id
        self.imageVisibleRect = imageVisibleRect
    }

    func changeRelativeFrame(with value: CGFloat, with gripPosition: GripPosition) {
        guard isAllowed(relativeFrame) else {
            return
        }

        switch gripPosition {
        case .left: relativeFrame.stretchLeft(with: value)
        case .right: relativeFrame.stretchRight(with: value)
        case .top: relativeFrame.stretchUp(with: value)
        case .bottom: relativeFrame.stretchDown(with: value)
        }

        relativeFrame.normalizeValueToAllowed()
    }

    func deleteImage() {
        self.image = nil
    }

    func addImage(_ image: UIImage?) {
        self.image = image
        imageVisibleRect = .zero
    }

    func calculateGripPositions() {
        gripPositions.removeAll()

        guard relativeFrame.isFullsized == false else {
            return
        }

        if relativeFrame.minX > .allowableAccuracy { gripPositions.insert(.left) }
        if relativeFrame.minY > .allowableAccuracy { gripPositions.insert(.top) }
        if abs(relativeFrame.maxX - 1) > .allowableAccuracy { gripPositions.insert(.right) }
        if abs(relativeFrame.maxY - 1) > .allowableAccuracy { gripPositions.insert(.bottom) }

        relativeFrame.normalizeValueToAllowed()
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
        return lhs.id == rhs.id
    }

    private(set) var id: UUID
    private(set) var image: UIImage?
    private(set) var photoAsset: PHAsset?
    private(set) var relativeFrame = RelativeFrame.zero
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
