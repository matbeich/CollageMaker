//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Utils

enum SharingError: Error {
    case photoLibraryAccessDenied
}

protocol ShareScreenViewControllerDelegate: AnyObject {
    func shareScreenViewControllerDidCancel(_ controller: ShareScreenViewController)
    func shareScreenViewController(_ controller: ShareScreenViewController, didShareCollageImage image: UIImage, withError error: SharingError?)
}

class ShareScreenViewController: CollageBaseViewController {
    weak var delegate: ShareScreenViewControllerDelegate?

    var thumbnailIsSet: Bool {
        return thumbnailImageView.image != nil
    }

    init(collage: Collage,
         authService: PhotoAuthService = PhotoAuthService(),
         photoLibrary: PhotoLibraryType = PhotoLibrary(),
         collageRenderer: CollageRenderer = CollageRenderer()) {
        self.authService = authService
        self.photoLibrary = photoLibrary
        self.collageRenderer = collageRenderer
        self.collage = collage
        self.shareFooter = ShareScreenFooter(destinations: [.photos, .messages, .instagram, .other])

        super.init(nibName: nil, bundle: nil)

        setThumbnail()
        prepareHightResolutionImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(thumbnailImageView)
        view.addSubview(shareFooter)

        setup()
        makeConstraints()
    }

    @objc private func cancel() {
        delegate?.shareScreenViewControllerDidCancel(self)
    }

    private func setup() {
        shareFooter.delegate = self

        navBarItem.left = NavigationBarButtonItem(icon: R.image.close_btn(), target: self, action: #selector(cancel))
        navBarItem.title = "Share"

        view.backgroundColor = .white
    }

    private func makeConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }

            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(thumbnailImageView.snp.width)
        }

        shareFooter.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(thumbnailImageView.snp.bottom)
        }
    }

    private func shareToDestination(destination: ShareDestination) {
        guard let image = collageImage else {
            return
        }

        let content = ShareContent()
        content.item = image
        content.userCaption = hashtag

        switch destination {
        case .instagram:
            shareToInstagram(content: content)
        case .messages:
            shareViaMessage(content: content)
        case .other:
            shareToOther(content: content)
        case .photos:
            saveToPhotos(content: content)
        }
    }

    private func saveToPhotos(content: ShareContent, completion: ((Bool, PHAsset?) -> Void)? = nil) {
        guard let image = content.item as? UIImage else {
            return
        }

        photoLibrary.add(image) { [weak self] succes, asset in
            guard let `self` = self else {
                return
            }
            Alerts.popUpMessageAlert("Saved to photos", duration: 0.75, in: self)
            self.currentImageAsset = asset

            completion?(succes, asset)
        }
    }

    private func shareViaMessage(content: ShareContent) {
        Pigeon.shared.shareToMessages(content, in: self, with: nil)
    }

    private func shareToOther(content: ShareContent) {
        let settings = ActivityShareSettings()
        Pigeon.shared.share(content, in: self, from: view.frame, settings: settings, with: nil)
    }

    private func shareToInstagram(content: ShareContent) {
        let completion: (Bool, PHAsset?) -> Void = { [weak self] succes, asset in
            guard let `self` = self else {
                return
            }

            if succes, let asset = asset {
                self.openInstagram(withAssetId: asset.localIdentifier)
            } else {
                Alerts.popUpMessageAlert("Something went wrong", duration: 0.8, in: self)
            }
        }

        guard
            let currentImageAsset = currentImageAsset,
            let asset = photoLibrary.assetFor(localIdentifier: currentImageAsset.localIdentifier),
            currentImageAsset == asset
        else {
            saveToPhotos(content: content, completion: completion)
            return
        }

        openInstagram(withAssetId: currentImageAsset.localIdentifier)
    }

    private func openInstagram(withAssetId assetId: String) {
        guard let shareURL = URL(string: "instagram://library?LocalIdentifier=\(assetId)") else {
            return
        }

        Utils.Application.redirect(to: shareURL)
    }

    private func setThumbnail() {
        collageRenderer.renderAsyncImage(from: collage, with: CGSize(width: 400, height: 400), borders: false) { [weak self] image in
            if self?.thumbnailImageView.image == nil { self?.setThumbnailImage(image, animated: true) }
        }
    }

    private func prepareHightResolutionImage() {
        collageRenderer.renderAsyncImage(from: collage, with: CGSize(width: 1200, height: 1200), borders: false) { [weak self] image in
            self?.collageImage = image
        }
    }

    private func setThumbnailImage(_ image: UIImage?, animated: Bool) {
        thumbnailImageView.image = image

        if animated {
            thumbnailImageView.alpha = 0.3
            UIView.animate(withDuration: 0.3) { self.thumbnailImageView.alpha = 1.0 }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private var collageImage: UIImage? {
        didSet {
            setThumbnailImage(collageImage, animated: thumbnailIsSet ? false : true)
        }
    }

    private var collage: Collage
    private var hashtag: String?
    private var currentImageAsset: PHAsset?
    private let thumbnailImageView = UIImageView()
    private let shareFooter: ShareScreenFooter
    private let authService: PhotoAuthService
    private let photoLibrary: PhotoLibraryType
    private let collageRenderer: CollageRenderer
}

extension ShareScreenViewController: ShareScreenFooterDelegate {
    func shareScreenFooter(_ footer: ShareScreenFooter, shareToolbar: ShareToolbar, didSelectDestination destination: ShareDestination) {
        EventTracker.shared.track(.share(destination: destination))
        shareToDestination(destination: destination)
    }

    func shareScreenFooter(_ footer: ShareScreenFooter, didTappedHashtag hashtag: String) {
        self.hashtag = hashtag
        Alerts.popUpMessageAlert("Hashtag copied to clipboard", duration: 0.75, in: self)
    }
}
