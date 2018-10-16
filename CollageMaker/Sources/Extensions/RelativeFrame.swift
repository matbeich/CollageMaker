//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
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

    func stretchedLeft(with value: CGFloat) -> RelativeFrame {
        return RelativeFrame(origin: CGPoint(x: origin.x + value, y: origin.y), size: CGSize(width: width - value, height: height))
    }

    func stretchedRight(with value: CGFloat) -> RelativeFrame {
        return RelativeFrame(origin: origin, size: CGSize(width: width + value, height: height))
    }

    func stretchedUp(with value: CGFloat) -> RelativeFrame {
        return RelativeFrame(origin: CGPoint(x: origin.x, y: origin.y + value), size: CGSize(width: width, height: height - value))
    }

    func stretchedDown(with value: CGFloat) -> RelativeFrame {
        return RelativeFrame(origin: origin, size: CGSize(width: width, height: height + value))
    }

    func normalizedToAllowed() -> RelativeFrame {
        let normalizedWidth = min(1.0, max(0.2, width))
        let normalizedHeight = min(1.0, max(0.2, height))

        return RelativeFrame(origin: origin, size: CGSize(width: normalizedWidth, height: normalizedHeight))
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
        switch gripPosition.axis {
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

    static let leftFullHeightThirtyThreeWidth = RelativeFrame(x: 0, y: 0, width: 0.33, height: 1)
    static let centerFullHeightThirtyThreeWidth = RelativeFrame(x: 0.33, y: 0, width: 0.33, height: 1)
    static let rightFullHeightThirtyThreeWidth = RelativeFrame(x: 0.66, y: 0, width: 0.34, height: 1)
    static let topFullWidthThirtyThreeHeight = RelativeFrame(x: 0, y: 0, width: 1, height: 0.33)
    static let centerFullWidthThirtyThreeHeight = RelativeFrame(x: 0, y: 0.33, width: 1, height: 0.33)
    static let bottomFullWidthThirtyThreeHeight = RelativeFrame(x: 0, y: 0.66, width: 1, height: 0.34)

    static let topLeftThirtyThreeHeightThirtyThreeWidth = RelativeFrame(x: 0, y: 0, width: 0.33, height: 0.33)
    static let topCenterThirtyThreeHeightThirtyThreeWidth = RelativeFrame(x: 0.33, y: 0, width: 0.33, height: 0.33)
    static let topRightThirtyThreeHeightThirtyThreeWidth = RelativeFrame(x: 0.66, y: 0, width: 0.34, height: 0.33)
    static let centerLeftThirtyThreeHeightThirtyThreeWidth = RelativeFrame(x: 0, y: 0.33, width: 0.33, height: 0.33)
    static let centerThirtyThreeHeightThirtyThreeWidth = RelativeFrame(x: 0.33, y: 0.33, width: 0.33, height: 0.33)
    static let centerRightThirtyThreeHeightThirtyThreeWidth = RelativeFrame(x: 0.66, y: 0.33, width: 0.34, height: 0.33)
    static let bottomLeftThirtyThreeHeightThirtyThreeWidth = RelativeFrame(x: 0, y: 0.66, width: 0.33, height: 0.34)
    static let bottomCenterThirtyThreeHeightThirtyThreeWidth = RelativeFrame(x: 0.33, y: 0.66, width: 0.33, height: 0.34)
    static let bottomRightThirtyThreeHeightThirtyThreeWidth = RelativeFrame(x: 0.66, y: 0.66, width: 0.34, height: 0.34)

    static let topFullWidthTwentyFiveHeight = RelativeFrame(x: 0, y: 0, width: 1, height: 0.25)
    static let secondFullWidthTwentyFiveHeight = RelativeFrame(x: 0, y: 0.25, width: 1, height: 0.25)
    static let thirdFullWidthTwentyFiveHeight = RelativeFrame(x: 0, y: 0.5, width: 1, height: 0.25)
    static let bottomFullWidthTwentyFiveHeight = RelativeFrame(x: 0, y: 0.75, width: 1, height: 0.25)

    static let leftFullHeightTwentyFiveHeight = RelativeFrame(x: 0, y: 0, width: 0.25, height: 1)
    static let secondFullHeightTwentyFiveHeight = RelativeFrame(x: 0.25, y: 0, width: 0.25, height: 1)
    static let thirdFullHeightTwentyFiveHeight = RelativeFrame(x: 0.5, y: 0, width: 0.25, height: 1)
    static let rightFullHeightTwentyFiveHeight = RelativeFrame(x: 0.75, y: 0, width: 0.25, height: 1)

    static let topLeftTwentyFiveWidthHalfHeight = RelativeFrame(x: 0, y: 0, width: 0.25, height: 0.5)
    static let topCenterFirstTwentyFiveWidthHalfHeight = RelativeFrame(x: 0.25, y: 0, width: 0.25, height: 0.5)
    static let topCenterSecondTwentyFiveWidthHalfHeight = RelativeFrame(x: 0.5, y: 0, width: 0.25, height: 0.5)
    static let topRightTwentyFiveWidthHalfHeight = RelativeFrame(x: 0.75, y: 0, width: 0.25, height: 0.5)
    static let bottomLeftTwentyFiveWidthHalfHeight = RelativeFrame(x: 0, y: 0.5, width: 0.25, height: 0.5)
    static let bottomCenterFirstTwentyFiveWidthHalfHeight = RelativeFrame(x: 0.25, y: 0.5, width: 0.25, height: 0.5)
    static let bottomCenterSecondTwentyFiveWidthHalfHeight = RelativeFrame(x: 0.5, y: 0.5, width: 0.25, height: 0.5)
    static let bottomRightTwentyFiveWidthHalfHeight = RelativeFrame(x: 0.75, y: 0.5, width: 0.25, height: 0.5)
    static let centerHalfWidthFullHeight = RelativeFrame(x: 0.25, y: 0, width: 0.5, height: 1)

    static let topLeftHalfHeightThirtyThreeWidth = RelativeFrame(x: 0, y: 0, width: 0.33, height: 0.5)
    static let topCenterHalfHeightThirtyThreeWidth = RelativeFrame(x: 0.33, y: 0, width: 0.33, height: 0.5)
    static let topRightHalfHeightThirtyThreeWidth = RelativeFrame(x: 0.66, y: 0, width: 0.34, height: 0.5)
    static let bottomLeftHalfHeightThirtyThreeWidth = RelativeFrame(x: 0, y: 0.5, width: 0.33, height: 0.5)
    static let bottomCenterHalfHeightThirtyThreeWidth = RelativeFrame(x: 0.33, y: 0.5, width: 0.33, height: 0.5)
    static let bottomRightHalfHeightThirtyThreeWidth = RelativeFrame(x: 0.66, y: 0.5, width: 0.34, height: 0.5)

    static let bottomLeftSixtySevenHeightThirtyThreeWidth = RelativeFrame(x: 0, y: 0.33, width: 0.33, height: 0.67)
    static let bottomCenterSixtySevenHeightThirtyThreeWidth = RelativeFrame(x: 0.33, y: 0.33, width: 0.33, height: 0.67)
    static let bottomRightSixtySevenHeightThirtyThreeWidth = RelativeFrame(x: 0.66, y: 0.33, width: 0.34, height: 0.67)

    static let topLeftSixtySevenHeightThirtyThreeWidth = RelativeFrame(x: 0, y: 0, width: 0.33, height: 0.66)
    static let topCenterSixtySevenHeightThirtyThreeWidth = RelativeFrame(x: 0.33, y: 0, width: 0.33, height: 0.66)
    static let topRightSixtySevenHeightThirtyThreeWidth = RelativeFrame(x: 0.66, y: 0, width: 0.34, height: 0.66)
}
