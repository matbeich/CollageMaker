//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos

typealias CollageFramesKit = [RelativeFrame]

class CollageTemplateProvider {
    enum Size {
        case small
        case medium
        case large

        var value: CGSize {
            switch self {
            case .small: return CGSize(width: 100, height: 100)
            case .medium: return CGSize(width: 500, height: 500)
            case .large: return CGSize(width: 1200, height: 1200)
            }
        }
    }

    static func templates(for assets: [PHAsset] = []) -> [CollageTemplate] {
        PhotoLibraryService.cacheImages(for: assets)

        var collagesFramesKit = [CollageFramesKit]()

        switch assets.count {
        case 1:
            collagesFramesKit = RelativeFrame.onePotoFramesKit()
        case 2:
            collagesFramesKit = RelativeFrame.twoPhotosFramesKit()
        case 3:
            collagesFramesKit = RelativeFrame.threePhotosFramesKit()
        case 4:
            collagesFramesKit = RelativeFrame.fourPhotosFramesKit()
        case 5:
            collagesFramesKit = RelativeFrame.fivePhotosFramesKit()
        case 6:
            collagesFramesKit = RelativeFrame.sixPhotosFramesKit()
        case 7:
            collagesFramesKit = RelativeFrame.sevenPhotosFramesKit()
        default:
            return []
        }

        return collagesFramesKit.map { CollageTemplate(frames: $0, assets: assets) }
    }

    static func collage(from template: CollageTemplate, size: Size = .large, callback: @escaping (Collage) -> Void) {
        let cells = template.cellFrames.map { CollageCell(relativeFrame: $0) }
        let collage = Collage(cells: cells)

        collectPhotos(from: template.assets, size: size.value) { photos in
            collage.fill(with: photos)
            callback(collage)
        }
    }

    static func collectPhotos(from assets: [PHAsset], deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat, size: CGSize, callback: @escaping ([UIImage]) -> Void) {
        let group = DispatchGroup()
        var photos: [UIImage?] = Array(repeating: nil, count: assets.count)

        for (index, asset) in assets.enumerated() {
            group.enter()
            PhotoLibraryService.photo(from: asset, deliveryMode: deliveryMode, size: size) { photo in
                photos[index] = photo
                group.leave()
            }
        }

        group.notify(queue: .main) {
            callback(photos.compactMap { $0 })
        }
    }
}

fileprivate extension RelativeFrame {
    static func onePotoFramesKit() -> [CollageFramesKit] {
        return [[.fullsized]]
    }

    static func twoPhotosFramesKit() -> [CollageFramesKit] {
        return [
            [.leftFullHeightHalfWidth, .rightFullHeightHalfWidth],
            [.topHalfHeightFullWidth, .bottomHalfHeightFullWidth]
        ]
    }

    static func threePhotosFramesKit() -> [CollageFramesKit] {
        return [
            [.leftFullHeightHalfWidth, .topRightHalfWidthHalfHeight, .bottomRightHalfWidthHalfHeight],
            [.topLeftHalfWidthHalfHeight, .bottomLeftHalfWidthHalfHeight, .rightFullHeightHalfWidth],
            [.topHalfHeightFullWidth, .bottomLeftHalfWidthHalfHeight, .bottomRightHalfWidthHalfHeight],
            [.bottomHalfHeightFullWidth, .topLeftHalfWidthHalfHeight, .topRightHalfWidthHalfHeight],
            [.leftFullHeightThirtyThreeWidth, .centerFullHeightThirtyThreeWidth, .rightFullHeightThirtyThreeWidth],
            [.topFullWidthThirtyThreeHeight, .centerFullWidthThirtyThreeHeight, .bottomFullWidthThirtyThreeHeight]
        ]
    }

    static func fourPhotosFramesKit() -> [CollageFramesKit] {
        return [
            [topLeftHalfWidthHalfHeight, topRightHalfWidthHalfHeight, bottomLeftHalfWidthHalfHeight, bottomRightHalfWidthHalfHeight],
            [topFullWidthTwentyFiveHeight, secondFullWidthTwentyFiveHeight, thirdFullWidthTwentyFiveHeight, bottomFullWidthTwentyFiveHeight],
            [leftFullHeightTwentyFiveHeight, secondFullHeightTwentyFiveHeight, thirdFullHeightTwentyFiveHeight, rightFullHeightTwentyFiveHeight],
            [leftFullHeightTwentyFiveHeight, secondFullHeightTwentyFiveHeight, topRightHalfWidthHalfHeight, bottomRightHalfWidthHalfHeight],
            [topLeftHalfWidthHalfHeight, bottomLeftHalfWidthHalfHeight, thirdFullHeightTwentyFiveHeight, rightFullHeightTwentyFiveHeight],
            [topFullWidthTwentyFiveHeight, secondFullWidthTwentyFiveHeight, bottomLeftHalfWidthHalfHeight, bottomRightHalfWidthHalfHeight],
            [topLeftHalfWidthHalfHeight, topRightHalfWidthHalfHeight, thirdFullWidthTwentyFiveHeight, bottomFullWidthTwentyFiveHeight]
        ]
    }

    static func fivePhotosFramesKit() -> [CollageFramesKit] {
        return [
            [
                .topLeftTwentyFiveWidthHalfHeight, .bottomLeftTwentyFiveWidthHalfHeight,
                .centerHalfWidthFullHeight, .topRightTwentyFiveWidthHalfHeight, .bottomRightTwentyFiveWidthHalfHeight
            ],
            [
                .topLeftHalfHeightThirtyThreeWidth, .topCenterHalfHeightThirtyThreeWidth, .topRightHalfHeightThirtyThreeWidth,
                .bottomLeftHalfWidthHalfHeight, .bottomRightHalfWidthHalfHeight
            ],
            [
                .topLeftHalfWidthHalfHeight, .topRightHalfWidthHalfHeight, .bottomLeftHalfHeightThirtyThreeWidth,
                .bottomCenterHalfHeightThirtyThreeWidth, .bottomRightHalfHeightThirtyThreeWidth
            ]
        ]
    }

    static func sixPhotosFramesKit() -> [CollageFramesKit] {
        return [
            [
                .topLeftHalfHeightThirtyThreeWidth, .topCenterHalfHeightThirtyThreeWidth, .topRightHalfHeightThirtyThreeWidth, .bottomLeftHalfHeightThirtyThreeWidth, .bottomCenterHalfHeightThirtyThreeWidth, .bottomRightHalfHeightThirtyThreeWidth
            ],
            [
                .topLeftThirtyThreeHeightThirtyThreeWidth, .topCenterThirtyThreeHeightThirtyThreeWidth, .topRightThirtyThreeHeightThirtyThreeWidth,
                .bottomLeftSixtySevenHeightThirtyThreeWidth, .bottomCenterSixtySevenHeightThirtyThreeWidth, .bottomRightSixtySevenHeightThirtyThreeWidth
            ],
            [
                .topLeftSixtySevenHeightThirtyThreeWidth, topCenterSixtySevenHeightThirtyThreeWidth, .topRightSixtySevenHeightThirtyThreeWidth,
                .bottomLeftThirtyThreeHeightThirtyThreeWidth, .bottomCenterThirtyThreeHeightThirtyThreeWidth, .bottomRightThirtyThreeHeightThirtyThreeWidth
            ]
        ]
    }

    static func sevenPhotosFramesKit() -> [CollageFramesKit] {
        return [
            [
                .topLeftThirtyThreeHeightThirtyThreeWidth, .topCenterThirtyThreeHeightThirtyThreeWidth, .topRightThirtyThreeHeightThirtyThreeWidth,
                .centerFullWidthThirtyThreeHeight, .bottomLeftThirtyThreeHeightThirtyThreeWidth, .bottomCenterThirtyThreeHeightThirtyThreeWidth, .bottomRightThirtyThreeHeightThirtyThreeWidth
            ],
            [
                .topLeftThirtyThreeHeightThirtyThreeWidth, .topCenterThirtyThreeHeightThirtyThreeWidth, .topRightThirtyThreeHeightThirtyThreeWidth,
                .centerLeftThirtyThreeHeightThirtyThreeWidth, .centerThirtyThreeHeightThirtyThreeWidth, .centerRightThirtyThreeHeightThirtyThreeWidth,
                .bottomFullWidthThirtyThreeHeight
            ],
            [
                topFullWidthThirtyThreeHeight,
                centerLeftThirtyThreeHeightThirtyThreeWidth, centerThirtyThreeHeightThirtyThreeWidth, centerRightThirtyThreeHeightThirtyThreeWidth,
                bottomLeftThirtyThreeHeightThirtyThreeWidth, bottomCenterThirtyThreeHeightThirtyThreeWidth, bottomRightThirtyThreeHeightThirtyThreeWidth
            ]
        ]
    }
}
