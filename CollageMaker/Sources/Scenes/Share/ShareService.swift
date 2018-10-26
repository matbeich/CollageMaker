//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import UIKit
import Utils

typealias SavePhotoCompletion = (Bool, PHAsset?) -> Void

protocol ShareServiceType {
    func shareToMessages(_ content: Shareable, in controller: UIViewController, with completion: ShareCompletion?)
    func shareToInstagram(_ content: Shareable, in controller: UIViewController, with completion: ShareCompletion?)
    func saveToPhotos(_ content: Shareable, in controller: UIViewController, with completion: SavePhotoCompletion?)
}

final class ShareService: ShareServiceType {

    init(photoLibrary: PhotoLibraryType = PhotoLibrary()) {
        self.photoLibrary = photoLibrary
    }

    func shareToMessages(_ content: Shareable, in controller: UIViewController, with completion: ShareCompletion?) {
        Pigeon.shared.shareToMessages(content, in: controller, with: completion)
    }

    func shareToInstagram(_ content: Shareable, in controller: UIViewController, with completion: ShareCompletion?) {
        let completion: (Bool, PHAsset?) -> Void = { [weak self] succes, asset in
            guard let `self` = self else {
                return
            }

            if succes, let asset = asset {
                self.openInstagram(withAssetId: asset.localIdentifier)
            } else {
                Alerts.popUpMessageAlert("Something went wrong", duration: 0.8, in: controller)
            }
        }

        guard
            let currentImageAsset = currentImageAsset,
            let asset = photoLibrary.assetFor(localIdentifier: currentImageAsset.localIdentifier),
            currentImageAsset == asset
        else {
            saveToPhotos(content, in: controller, with: completion)
            return
        }

        openInstagram(withAssetId: currentImageAsset.localIdentifier)
    }

    internal func saveToPhotos(_ content: Shareable, in controller: UIViewController, with completion: SavePhotoCompletion?) {
        guard let image = content.item as? UIImage else {
            return
        }

        photoLibrary.add(image) { [weak self] succes, asset in
            guard let `self` = self else {
                return
            }

            Alerts.popUpMessageAlert("Saved to photos", duration: 0.75, in: controller)
            self.currentImageAsset = asset

            completion?(succes, asset)
        }
    }

    private func openInstagram(withAssetId assetId: String) {
        guard let shareURL = URL(string: "instagram://library?LocalIdentifier=\(assetId)") else {
            return
        }

        Utils.Application.redirect(to: shareURL)
    }

    private var currentImageAsset: PHAsset?
    private let photoLibrary: PhotoLibraryType
}
