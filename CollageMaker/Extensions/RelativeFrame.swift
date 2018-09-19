//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit

extension CGRect {
    var area: CGFloat {
        return width * height
    }
}

extension RelativeFrame {
    
    func absolutePosition(in rect: CGRect) -> CGRect {
        return CGRect(x: origin.x * rect.width,
                      y: origin.y * rect.height,
                      width: width * rect.width,
                      height: height * rect.height)
    }
    
    static var fullsized: RelativeFrame {
        return RelativeFrame(x: 0, y: 0, width: 1, height: 1)
    }
    
    var isFullsized: Bool {
        return self == RelativeFrame.fullsized
    }
    
    mutating func stretchLeft(with value: CGFloat) {
        origin.x += value
        size.width -= value
    }
    
    mutating func stretchRight(with value: CGFloat) {
        size.width += value
    }
    
    mutating func stretchUp(with value: CGFloat) {
        origin.y += value
        size.height -= value
    }
    
    mutating func stretchDown(with value: CGFloat) {
        size.height += value
    }
    
    mutating func normalizeValueToAllowed() {
        size.width = max(0.2, width)
        size.height = max(0.2, height)
        
        size.width = min(1.0, width)
        size.height = min(1.0, height)
    }
    
    func split(axis: Axis) -> (RelativeFrame, RelativeFrame) {
        switch axis {
        case .vertical:
            return (RelativeFrame(origin: origin, size: CGSize(width: size.width / 2, height: size.height)),
                    RelativeFrame(origin: CGPoint(x: origin.x + size.width / 2, y: origin.y), size: CGSize(width: size.width / 2, height: size.height)))
        case .horizontal:
            return (RelativeFrame(origin: origin, size: CGSize(width: size.width, height: size.height / 2)),
                    RelativeFrame(origin: CGPoint(x: origin.x, y: origin.y + size.height / 2), size: CGSize(width: size.width, height: size.height / 2)))
        }
    }
    
    func isInBounds(_ bounds: CGRect) -> Bool {
        return maxY.isLessOrApproximatelyEqual(to: bounds.maxY)
            && maxX.isLessOrApproximatelyEqual(to: bounds.maxX)
            && minX.isGreaterOrApproximatelyEqual(to: bounds.minX)
            && minY.isGreaterOrApproximatelyEqual(to: bounds.minY)
    }
    
    func intersects(rect2: CGRect, on gripPosition: GripPosition) -> Bool {
        switch  gripPosition.axis {
        case .vertical:
            let isInHeightBounds = minY.isGreaterOrApproximatelyEqual(to: rect2.minY) && maxY.isLessOrApproximatelyEqual(to: rect2.maxY)
            
            if gripPosition == .left {
                return isInHeightBounds && maxX.isApproximatelyEqual(to: rect2.minX) ? true : false
            } else {
                return isInHeightBounds && minX.isApproximatelyEqual(to: rect2.maxX) ? true : false
            }
            
        case .horizontal:
            let isInWidthBounds = minX.isGreaterOrApproximatelyEqual(to: rect2.minX) && maxX.isLessOrApproximatelyEqual(to: rect2.maxX)
            
            if gripPosition == .top {
                return isInWidthBounds && maxY.isApproximatelyEqual(to: rect2.minY) ? true : false
            } else {
                return isInWidthBounds && minY.isApproximatelyEqual(to: rect2.maxY) ? true : false
            }
        }
    }
    
    func equallyIntersects(rect2: CGRect, on gripPosition: GripPosition) -> Bool {
        let isEqual = gripPosition.axis == .vertical ? height.isApproximatelyEqual(to: rect2.height) : width.isApproximatelyEqual(to: rect2.width)
        
        return intersects(rect2: rect2, on: gripPosition) && isEqual
    }
}

extension RelativeFrame {
    
    static let leftFullHeightHalfWidth = RelativeFrame(x: 0, y: 0, width: 0.5, height: 1)
    static let rightFullHeightHalfWidth = RelativeFrame(x: 0.5, y: 0, width: 0.5, height: 1)
    static let topHalfHeightFullWidth = RelativeFrame(x: 0, y: 0, width: 1, height: 0.5)
    static let bottomHalfHeightFullWidth = RelativeFrame(x: 0, y: 0.5, width: 1, height: 0.5)
    static let topRightHalfWidthHalfHeight = RelativeFrame(x: 0.5, y: 0, width: 0.5, height: 0.5)
    static let topLeftHalfWidthHalfHeight = RelativeFrame(x: 0, y: 0, width: 0.5, height: 0.5)
    static let bottomRightHalfWidthHalfHeight = RelativeFrame(x: 0.5, y: 0.5, width: 0.5, height: 0.5)
    static let bottomLeftHalfWidthHalfHeight = RelativeFrame(x: 0, y: 0.5, width: 0.5, height: 0.5)
    static let leftFullHeightThirtyThreePercentWidth = RelativeFrame(x: 0, y: 0, width: 0.33, height: 1)
    static let centerFullHeightThirtyThreePercentWidth = RelativeFrame(x: 0.33, y: 0, width: 0.33, height: 1)
    static let rightFullHeightThirtyThreePercentWidth = RelativeFrame(x: 0.66, y: 0, width: 0.34, height: 1)
    static let topFullWidthThirtyThreePercentHeight = RelativeFrame(x: 0, y: 0, width: 1, height: 0.33)
    static let centerFullWidthThirtyThreePercentHeight = RelativeFrame(x: 0, y: 0.33, width: 1, height: 0.33)
    static let bottomFullWidthThirtyThreePercentHeight = RelativeFrame(x: 0, y: 0.66, width: 1, height: 0.34)
}
